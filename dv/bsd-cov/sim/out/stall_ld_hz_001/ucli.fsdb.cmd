call fsdbDumpfile {"/home/lvzhengyang/workspace/BSD-Cov/exp/ibex_riscvdv/bsd_cov_sim_stall_ld_hz_001_bind_fsdb_smoke/raw/bsd_cov_sim_stall_ld_hz_001_bind/seed_888/out/run/tests/bsd_cov_sim_stall_ld_hz_001_bind.888/waves.fsdb"}
call fsdbDumpvars {0} {core_ibex_tb_top} {"+mda"} {"+struct"} {"+parameter"}
call fsdbDumpSVA
run
quit
