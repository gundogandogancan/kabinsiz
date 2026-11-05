# SculptedBody — third-party notice

`SculptedBody-neutral.*`, `SculptedBody-female.*` and `SculptedBody-male.*` (`.bin` + `.json`) are
derived data baked by `scripts/avatar/bake_sculpted_body.py` (ADR-010, ADR-011) from:

- **Anny** — Copyright (C) 2025 NAVER Corporation. Licensed under the Apache License, Version 2.0
  (http://www.apache.org/licenses/LICENSE-2.0). https://github.com/naver/anny
  Commit used: see `provenance.annyCommit` in each `.json` file.
- **MakeHuman / MPFB2 assets** (base mesh, shape targets, rig) as distributed with Anny — CC0 1.0
  Universal (public domain dedication). https://github.com/makehumancommunity/mpfb2

Only Anny's default `anny` topology was used. The optional `smplx` / `smpl` topologies, which are
licensed for non-commercial use only, were never downloaded or used.

Changes made by Kabinsiz: one fixed phenotype per body template (neutral, female, male), arms lowered,
eye/mouth/tongue cavities removed and closed, face and ears replaced by a smooth faceless head,
nipples, navel and crotch smoothed (covered form), shape bases quantised to 16 bits, and the binary
compressed with raw DEFLATE (format 3).

## Height and weight estimate

The coefficients in `AnthropometricEstimate.swift` (no data rows are shipped) were fitted by
`scripts/avatar/fit_ansur_estimate.py` on the **ANSUR II** working databases (2012 U.S. Army
Anthropometric Survey, U.S. Army Natick Soldier Research, Development and Engineering Center),
approved for unlimited public release. https://www.openlab.psu.edu/ansur2/
Only stature, weight and four girths/breadths were used; no demographic columns.
