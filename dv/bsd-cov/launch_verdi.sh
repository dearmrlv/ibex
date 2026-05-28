#!/bin/bash

/home/lvzhengyang/workspace/synopsys/verdi/verdi-raw \
  -2012 \
  -f dut.f \
  -f env.f \
  -top ibex_top \
  -ssf \
./jgproject/traces_fsdb.bsd_cov_region_asserts/8.ibex_top.u_ibex_core.id_stage_i.bsd_cov_ibex_hazard_stall_region_asserts_bind_inst.AST_BSDCOV_R_rf_rd_wb_hz_008.Ht.5.fsdb

