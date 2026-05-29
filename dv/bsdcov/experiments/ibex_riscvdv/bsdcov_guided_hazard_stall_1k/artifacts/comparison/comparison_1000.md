# Coverage comparison at instruction_count=1000

Baseline: `baseline_riscvdv_200k_dense_seed888`

Candidate: `bsdcov_guided_hazard_stall_1k`

| Metric | Baseline@1000 | BSD-Cov@1000 | Delta |
|---|---:|---:|---:|
| block | 77.58 | 72.04 | -5.54 |
| branch | 58.30 | 47.42 | -10.88 |
| statement | 78.75 | 73.08 | -5.67 |
| expression | 66.98 | 59.38 | -7.60 |
| toggle | 65.93 | 43.84 | -22.09 |
| statement_dup | 78.75 | 73.08 | -5.67 |
| fsm | 60.87 | 37.68 | -23.19 |
| assertion | 95.90 | 90.26 | -5.64 |
| covergroup | 6.71 | 4.12 | -2.59 |
