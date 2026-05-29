# BSD-Cov Baseline Augmentation Suite

Main comparison:

`Coverage(Baseline10k + BSD-CovExtra2k)` vs `Coverage(Baseline10k + BaselineExtra2k)`

Prefix segment identical: True

## Final Whole-Design Coverage

| Metric | Prefix 10k | Baseline-only 12k | Baseline+BSD-Cov 12k | Baseline Extra Gain | BSD-Cov Extra Gain | BSD-Cov Advantage |
|---|---:|---:|---:|---:|---:|---:|
| block | 78.78 | 78.98 | 78.85 | +0.20 | +0.07 | -0.13 |
| branch | 60.57 | 60.91 | 60.71 | +0.34 | +0.14 | -0.20 |
| statement | 80.37 | 80.50 | 80.44 | +0.13 | +0.07 | -0.06 |
| expression | 68.08 | 68.36 | 68.11 | +0.28 | +0.03 | -0.25 |
| toggle | 67.98 | 69.16 | 68.36 | +1.18 | +0.38 | -0.80 |
| statement_dup | 80.37 | 80.50 | 80.44 | +0.13 | +0.07 | -0.06 |
| fsm | 60.87 | 60.87 | 60.87 | +0.00 | +0.00 | +0.00 |
| assertion | 94.62 | 94.62 | 94.62 | +0.00 | +0.00 | +0.00 |
| covergroup | 7.41 | 8.19 | 7.51 | +0.78 | +0.10 | -0.68 |

## Incremental Target-Cone Bins

- Already hit by prefix: 76
- New by baseline extra: 1
- New by BSD-Cov extra: 0
- New by BSD-Cov only: 0
- New by baseline only: 1
- New by both: 0

## Extra-Only Signature Diversity

| Extra Run | Unique Signatures | Entropy | Top1 % | Top5 % | Top10 % |
|---|---:|---:|---:|---:|---:|
| Baseline extra | 49 | 2.66 | 51.05 | 82.28 | 91.36 |
| BSD-Cov extra | 21 | 3.07 | 24.04 | 81.58 | 95.46 |

## CEX / NearRegion / Genseq Gap

- Features where NearRegion positives are present but generated regions/templates are absent: branch_active, div_active, jump_active, load_wait, lsu_wait, mult_active, raw_hazard_rs1, raw_hazard_rs2, stall_branch, stall_jump, stall_multdiv

## Main Diagnosis

- BSD-Cov extra does not improve any whole-design coverage metric over baseline extra.
