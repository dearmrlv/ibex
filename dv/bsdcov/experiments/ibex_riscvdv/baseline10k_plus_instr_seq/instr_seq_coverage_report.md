# Baseline10k + instr_seq Coverage Comparison

- Baseline prefix run: `designs/ibex/dv/bsdcov/experiments/ibex_riscvdv/baseline_prefix_10k_seed888`
- instr_seq extra run: `/home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/bsdcov/experiments/ibex_riscvdv/bsdcov_instr_seq_extra`
- Prefix instruction count: `10000`
- Extra instruction count: `10`
- Baseline report: `/home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/bsdcov/experiments/ibex_riscvdv/baseline_prefix_10k_seed888/sample_cov/baseline_prefix_10k_seed888/bsd_cov_sample_010000/report/cov_report.txt`
- Merged report: `/home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/bsdcov/experiments/ibex_riscvdv/baseline10k_plus_instr_seq/merged_cov/baseline10k_plus_instr_seq/report/cov_report.txt`

## Included Instruction Sequences

- `designs/ibex/dv/bsd-cov/bsd/instr_seq/AST_BSDCOV_R_rf_rd_wb_hz_003.S`: 2 instructions
- `designs/ibex/dv/bsd-cov/bsd/instr_seq/AST_BSDCOV_R_rf_rd_wb_hz_004.S`: 1 instructions
- `designs/ibex/dv/bsd-cov/bsd/instr_seq/AST_BSDCOV_R_rf_rd_wb_hz_006.S`: 1 instructions
- `designs/ibex/dv/bsd-cov/bsd/instr_seq/AST_BSDCOV_R_rf_rd_wb_hz_008.S`: 1 instructions
- `designs/ibex/dv/bsd-cov/bsd/instr_seq/AST_BSDCOV_R_stall_jump_000.S`: 1 instructions
- `designs/ibex/dv/bsd-cov/bsd/instr_seq/AST_BSDCOV_R_stall_ld_hz_000.S`: 2 instructions
- `designs/ibex/dv/bsd-cov/bsd/instr_seq/AST_BSDCOV_R_stall_ld_hz_001.S`: 2 instructions

## Coverage Delta

| Metric | Baseline10k A | Baseline10k + instr_seq B | Delta |
|---|---:|---:|---:|
| block | 78.7800 | 78.7900 | 0.0100 |
| branch | 60.5700 | 60.6000 | 0.0300 |
| statement | 80.3700 | 80.3800 | 0.0100 |
| expression | 68.0800 | 68.1100 | 0.0300 |
| toggle | 67.9800 | 67.9800 | 0.0000 |
| statement_dup | 80.3700 | 80.3800 | 0.0100 |
| fsm | 60.8700 | 60.8700 | 0.0000 |
| assertion | 94.6200 | 94.6200 | 0.0000 |
| covergroup | 7.4100 | 7.4100 | 0.0000 |
