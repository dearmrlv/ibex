# Coverage comparison at instruction_count=2000

Baseline: `baseline_riscvdv_200k_dense_seed888`

Candidate: `bsdcov_guided_hazard_stall_2k`

| Metric | Baseline@2000 | BSD-Cov@2000 | Delta |
|---|---:|---:|---:|
| block | 78.21 | 72.12 | -6.09 |
| branch | 59.55 | 47.59 | -11.96 |
| statement | 79.47 | 73.17 | -6.30 |
| expression | 67.43 | 59.41 | -8.02 |
| toggle | 67.01 | 44.80 | -22.21 |
| statement_dup | 79.47 | 73.17 | -6.30 |
| fsm | 60.87 | 37.68 | -23.19 |
| assertion | 95.90 | 90.26 | -5.64 |
| covergroup | 7.15 | 4.36 | -2.79 |
