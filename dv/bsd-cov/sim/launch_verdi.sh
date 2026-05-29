#!/bin/bash

IBEX_PARAMS="\
  -pvalue+core_ibex_tb_top.RV32E=0 \
  -pvalue+core_ibex_tb_top.RV32M=ibex_pkg::RV32MSingleCycle \
  -pvalue+core_ibex_tb_top.RV32B=ibex_pkg::RV32BOTEarlGrey \
  -pvalue+core_ibex_tb_top.RV32ZC=ibex_pkg::RV32ZcaZcbZcmp \
  -pvalue+core_ibex_tb_top.RegFile=ibex_pkg::RegFileFF \
  -pvalue+core_ibex_tb_top.BranchTargetALU=1 \
  -pvalue+core_ibex_tb_top.WritebackStage=1 \
  -pvalue+core_ibex_tb_top.ICache=1 \
  -pvalue+core_ibex_tb_top.ICacheECC=1 \
  -pvalue+core_ibex_tb_top.ICacheScramble=1 \
  -pvalue+core_ibex_tb_top.ICacheTweakInfection=0 \
  -pvalue+core_ibex_tb_top.BranchPredictor=0 \
  -pvalue+core_ibex_tb_top.DbgTriggerEn=1 \
  -pvalue+core_ibex_tb_top.SecureIbex=1 \
  -pvalue+core_ibex_tb_top.PMPEnable=1 \
  -pvalue+core_ibex_tb_top.PMPGranularity=0 \
  -pvalue+core_ibex_tb_top.PMPNumRegions=16 \
  -pvalue+core_ibex_tb_top.MHPMCounterNum=10 \
  -pvalue+core_ibex_tb_top.MHPMCounterWidth=32 \
  -pvalue+core_ibex_tb_top.DbgHwBreakNum=1 \
  -pvalue+core_ibex_tb_top.DmBaseAddr=32'h1A110000 \
  -pvalue+core_ibex_tb_top.DmAddrMask=32'h00000FFF \
  -pvalue+core_ibex_tb_top.DmHaltAddr=32'h80000000 \
  -pvalue+core_ibex_tb_top.DmExceptionAddr=32'h80000008 \
  -pvalue+core_ibex_tb_top.BootAddr=32'h80000000 \
"

LOWRISC_IP_DIR=/home/lvzhengyang/workspace/BSD-Cov/designs/ibex/vendor/lowrisc_ip/ \
PRJ_DIR=/home/lvzhengyang/workspace/BSD-Cov/designs/ibex \
/home/lvzhengyang/workspace/synopsys/verdi/verdi-raw \
  -2012 \
  -f /home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/uvm/core_ibex/ibex_dv_defines.f -f /home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/uvm/core_ibex/ibex_dv.f \
  -f /home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/bsd-cov/sim/out/stall_ld_hz_001/bsd_bind.f \
  -top core_ibex_tb_top \
  $IBEX_PARAMS \
  -ssf \
/home/lvzhengyang/workspace/BSD-Cov/exp/ibex_riscvdv/bsd_cov_sim_stall_ld_hz_001_bind_fsdb_smoke/raw/bsd_cov_sim_stall_ld_hz_001_bind/seed_888/out/run/tests/bsd_cov_sim_stall_ld_hz_001_bind.888/waves.fsdb

#   -f /home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/uvm/core_ibex/ibex_dv_cosim_dpi.f \
