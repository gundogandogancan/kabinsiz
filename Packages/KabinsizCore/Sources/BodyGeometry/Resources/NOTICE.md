# SculptedBody — third-party notice

`SculptedBody.bin` and `SculptedBody.json` are derived data baked by
`scripts/avatar/bake_sculpted_body.py` (ADR-010) from:

- **Anny** — Copyright (C) 2025 NAVER Corporation. Licensed under the Apache License, Version 2.0
  (http://www.apache.org/licenses/LICENSE-2.0). https://github.com/naver/anny
  Commit used: see `provenance.annyCommit` in `SculptedBody.json`.
- **MakeHuman / MPFB2 assets** (base mesh, shape targets, rig) as distributed with Anny — CC0 1.0
  Universal (public domain dedication). https://github.com/makehumancommunity/mpfb2

Only Anny's default `anny` topology was used. The optional `smplx` / `smpl` topologies, which are
licensed for non-commercial use only, were never downloaded or used.

Changes made by Kabinsiz: fixed neutral phenotype, arms lowered, eye/mouth/tongue cavities removed
and closed, face and ears replaced by a smooth faceless head, shape bases quantised to 16 bits.
