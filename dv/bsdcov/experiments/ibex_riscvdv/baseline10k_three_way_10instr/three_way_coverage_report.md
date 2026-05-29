# Baseline10k vs BSD-Cov@10 vs Baseline@10 Coverage Comparison

- Baseline prefix run: `/home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/bsdcov/experiments/ibex_riscvdv/baseline_prefix_10k_seed888`
- BSD-Cov@10 extra run: `/home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/bsdcov/experiments/ibex_riscvdv/bsdcov_instr_seq_extra`
- Baseline@10 extra run: `/home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/bsdcov/experiments/ibex_riscvdv/baseline_extra_10_seed889`
- Prefix instruction count: `10000`
- Extra instruction count: `10`
- Baseline report: `/home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/bsdcov/experiments/ibex_riscvdv/baseline_prefix_10k_seed888/sample_cov/baseline_prefix_10k_seed888/bsd_cov_sample_010000/report/cov_report.txt`
- Baseline10k + BSD-Cov@10 report: `/home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/bsdcov/experiments/ibex_riscvdv/baseline10k_three_way_10instr/merged_cov/baseline10k_plus_bsdcov10/report/cov_report.txt`
- Baseline10k + Baseline@10 report: `/home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/bsdcov/experiments/ibex_riscvdv/baseline10k_three_way_10instr/merged_cov/baseline10k_plus_baseline10/report/cov_report.txt`

## Coverage Comparison

| Metric | Baseline@10k | Baseline@10k + BSD-Cov@10 | Baseline@10k + Baseline@10 | BSD-Cov@10 Delta | Baseline@10 Delta | BSD-Cov Advantage |
|---|---:|---:|---:|---:|---:|---:|
| block | 78.7800 | 78.7900 | 78.7800 | +0.0100 | +0.0000 | +0.0100 |
| branch | 60.5700 | 60.6000 | 60.5700 | +0.0300 | +0.0000 | +0.0300 |
| statement | 80.3700 | 80.3800 | 80.3700 | +0.0100 | +0.0000 | +0.0100 |
| expression | 68.0800 | 68.1100 | 68.0800 | +0.0300 | +0.0000 | +0.0300 |
| toggle | 67.9800 | 67.9800 | 67.9800 | +0.0000 | +0.0000 | +0.0000 |
| statement_dup | 80.3700 | 80.3800 | 80.3700 | +0.0100 | +0.0000 | +0.0100 |
| fsm | 60.8700 | 60.8700 | 60.8700 | +0.0000 | +0.0000 | +0.0000 |
| assertion | 94.6200 | 94.6200 | 94.6200 | +0.0000 | +0.0000 | +0.0000 |
| covergroup | 7.4100 | 7.4100 | 7.4100 | +0.0000 | +0.0000 | +0.0000 |

## Notes

- Baseline@10 generation used `+instr_cnt=10` and `+num_of_sub_program=0` because the default 5 subprogram setting did not emit a valid 10-instruction test.
- Reports are whole-design `ibex_top` structural coverage reports.
