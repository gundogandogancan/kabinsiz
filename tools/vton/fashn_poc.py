"""ADR-017 L1 research PoC: FASHN VTON 1.5 on a Mac, offline, without the human parser.

Research only (RESEARCH_ONLY in V35_LICENSE_GATE). Never run on a user's photo; never commit outputs that
show a real person. Inputs are FASHN's own Apache example images or Kabinsiz OWNED_ORIGINAL assets.

    PYTHONPATH=<fashn repo>/src:tools/vton/stubs <venv>/bin/python -I tools/vton/fashn_poc.py \
        --weights ~/research/fashn-weights --person P.png --garment G.png --category tops \
        --steps 30 --device mps --dtype bf16 --out out.png
"""
import argparse
import json
import platform
import time

import numpy as np
import torch
from PIL import Image

import fashn_vton.tryon_mmdit as mmdit
from einops import rearrange
from fashn_vton import TryOnPipeline


def _rope_cpu64(pos, dim, theta):
    """Same maths as upstream `rope`, but in float64 on the CPU: Apple MPS has no float64.
    The angles are then moved to the model's device as float32 (upstream also returns float32)."""
    assert dim % 2 == 0
    device = pos.device
    p = pos.detach().cpu().double()
    scale = torch.arange(0, dim, 2, dtype=torch.float64) / dim
    omega = 1.0 / (theta**scale)
    out = torch.einsum("...n,d->...nd", p, omega)
    out = torch.stack([torch.cos(out), -torch.sin(out), torch.sin(out), torch.cos(out)], dim=-1)
    out = rearrange(out, "b n d (i j) -> b n d i j", i=2, j=2)
    return out.float().to(device)


mmdit.rope = _rope_cpu64


class ParserFreePipeline(TryOnPipeline):
    """TryOnPipeline that never loads or calls the human parser."""

    def __init__(self, weights_dir, device, dtype):
        self._want_dtype = dtype
        super().__init__(weights_dir=weights_dir, device=device)

    def _setup_tryon_model(self):
        super()._setup_tryon_model()
        self.inference_dtype = self._want_dtype
        self.tryon_model.to(self.device, dtype=self.inference_dtype)

    def _setup_hp_model(self):
        class _NoParse:
            def predict(self, img):  # parse map is unused when masking is disabled
                return np.zeros(img.shape[:2], dtype=np.uint8)
        self.hp_model = _NoParse()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--weights", required=True)
    ap.add_argument("--person", required=True)
    ap.add_argument("--garment", required=True)
    ap.add_argument("--category", default="tops", choices=["tops", "bottoms", "one-pieces"])
    ap.add_argument("--photo-type", default="flat-lay", choices=["flat-lay", "model"])
    ap.add_argument("--steps", type=int, default=30)
    ap.add_argument("--device", default="mps")
    ap.add_argument("--dtype", default="bf16", choices=["fp32", "fp16", "bf16"])
    ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--out", required=True)
    a = ap.parse_args()
    if a.photo_type != "flat-lay":
        raise SystemExit("Only flat-lay: a model-photo garment would need the blocked parser for masking.")
    dtype = {"fp32": torch.float32, "fp16": torch.float16, "bf16": torch.bfloat16}[a.dtype]

    t0 = time.perf_counter()
    pipe = ParserFreePipeline(a.weights, a.device, dtype)
    load_s = time.perf_counter() - t0

    person = Image.open(a.person).convert("RGB")
    garment = Image.open(a.garment).convert("RGB")
    # Warm-up (first MPS kernels compile) is excluded from the timed run.
    pipe(person, garment, category=a.category, garment_photo_type="flat-lay", num_timesteps=2,
         segmentation_free=True, seed=a.seed)
    if a.device == "mps":
        torch.mps.synchronize()
    t1 = time.perf_counter()
    out = pipe(person, garment, category=a.category, garment_photo_type="flat-lay", num_timesteps=a.steps,
               segmentation_free=True, seed=a.seed)
    if a.device == "mps":
        torch.mps.synchronize()
    run_s = time.perf_counter() - t1
    out.images[0].save(a.out)
    report = {
        "steps": a.steps, "device": a.device, "dtype": a.dtype, "load_s": round(load_s, 1),
        "generate_s": round(run_s, 1), "s_per_step": round(run_s / a.steps, 2),
        "output_size": list(out.images[0].size), "torch": torch.__version__,
        "machine": platform.machine(), "mac": platform.mac_ver()[0],
        "peak_mps_gb": round(torch.mps.driver_allocated_memory() / 2**30, 2) if a.device == "mps" else None,
    }
    print(json.dumps(report))


if __name__ == "__main__":
    main()
