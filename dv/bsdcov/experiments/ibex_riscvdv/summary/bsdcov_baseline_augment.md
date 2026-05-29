# BSD-Cov Baseline Augmentation Summary

Summarized suite: `designs/ibex/dv/bsdcov/experiments/ibex_riscvdv/suite_baseline10k_bsdcov2k_templates_v1`

This summary compares `Baseline10k + BSD-CovExtra2k` against `Baseline10k + BaselineExtra2k`.

## Whole-Design Coverage

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

## Incremental Target Bins

- New by BSD-Cov only: 0
- New by baseline only: 1
- New by both: 0

## Extra-Only Signature Diversity

- Baseline extra unique signatures: 49
- BSD-Cov extra unique signatures: 21

## Generation Gap

- NearRegion-present but generated-absent features: branch_active, div_active, jump_active, load_wait, lsu_wait, mult_active, raw_hazard_rs1, raw_hazard_rs2, stall_branch, stall_jump, stall_multdiv

## Checkseq Hit Confirmation

- Checkseq artifact: `designs/ibex/dv/bsdcov/experiments/ibex_riscvdv/bsdcov_extra_2k_baseline10k_templates_v1/artifacts/sequence_check/region_hits.json`
- Available: True
- Selected regions: 26
- Selected regions hit: 0
- Previously unsupported selected-region hits: 0

### Top selected region hits

- none

## Main Diagnosis

- BSD-Cov extra does not improve whole-design coverage over baseline extra in this suite.
- BSD-Cov extra adds no target-cone bins beyond baseline extra.
- Region-driven templates did not hit any previously unsupported selected region; template realization remains the bottleneck.
