"""Stand-in for `fashn_human_parser` so FASHN VTON 1.5 imports WITHOUT the human parser.

The real parser ships SegFormer weights under the NVIDIA Source Code License (non-commercial) and is
BLOCKED for Kabinsiz (ADR-017, V35_LICENSE_GATE). With `segmentation_free=True` and
`garment_photo_type="flat-lay"` the FASHN pipeline never uses a parse map (`disable_masking` returns the
image unchanged), so only label names are needed for a dictionary lookup. These names are ours.
Instantiating the parser is refused on purpose.
"""

CATEGORY_TO_BODY_COVERAGE = {"tops": "upper", "bottoms": "lower", "one-pieces": "full"}
BODY_COVERAGE_TO_LABELS = {"upper": ["top"], "lower": ["bottom"], "full": ["top", "bottom"]}
IDENTITY_LABELS = ["face", "hair"]
LABELS_TO_IDS = {"background": 0, "top": 1, "bottom": 2, "face": 3, "hair": 4}


class FashnHumanParser:  # pragma: no cover - refused by design
    def __init__(self, *args, **kwargs):
        raise RuntimeError("Human parser is BLOCKED (NVIDIA non-commercial). Use segmentation_free + flat-lay.")
