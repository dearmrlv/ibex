#!/bin/bash

IBEX_PARAMS="\
  -pvalue+ibex_top.RV32E=0 \
  -pvalue+ibex_top.RV32M=ibex_pkg::RV32MSingleCycle \
  -pvalue+ibex_top.RV32B=ibex_pkg::RV32BOTEarlGrey \
  -pvalue+ibex_top.RV32ZC=ibex_pkg::RV32ZcaZcbZcmp \
  -pvalue+ibex_top.RegFile=ibex_pkg::RegFileFF \
  -pvalue+ibex_top.BranchTargetALU=1 \
  -pvalue+ibex_top.WritebackStage=1 \
  -pvalue+ibex_top.ICache=1 \
  -pvalue+ibex_top.ICacheECC=1 \
  -pvalue+ibex_top.ICacheScramble=1 \
  -pvalue+ibex_top.ICacheTweakInfection=0 \
  -pvalue+ibex_top.BranchPredictor=0 \
  -pvalue+ibex_top.DbgTriggerEn=1 \
  -pvalue+ibex_top.SecureIbex=1 \
  -pvalue+ibex_top.PMPEnable=1 \
  -pvalue+ibex_top.PMPGranularity=0 \
  -pvalue+ibex_top.PMPNumRegions=16 \
  -pvalue+ibex_top.MHPMCounterNum=10 \
  -pvalue+ibex_top.MHPMCounterWidth=32 \
  -pvalue+ibex_top.DbgHwBreakNum=1 \
  -pvalue+ibex_top.DmBaseAddr=32'h1A110000 \
  -pvalue+ibex_top.DmAddrMask=32'h00000FFF \
  -pvalue+ibex_top.DmHaltAddr=32'h80000000 \
  -pvalue+ibex_top.DmExceptionAddr=32'h80000008 \
  -pvalue+ibex_top.BootAddr=32'h80000000 \
"

/home/lvzhengyang/workspace/synopsys/verdi/verdi-raw \
  -2012 \
  -f dut.f \
  -f env.f \
  -f /home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/bsdcov_whole_mc/runs/smoke_baseline_500_seed1688_mc_fix/big_proj/results/bsdcov.f \
  -top ibex_top \
  $IBEX_PARAMS \
  -ssf \
/home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/bsdcov_whole_mc/runs/smoke_baseline_500_seed1688_mc_fix/fml/traces_fsdb.bsd_cov_region_asserts/multi_cex/round_03_hunt/532._wb_stage_9ea2ab83df.AST_BSDCOV_ibex_wb_stage_9ea2ab83df_R_unique_004.Ht.10.fsdb
# /home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/bsdcov/fml/jgproject/traces_fsdb.bsd_cov_region_asserts/4.gions_stall_mem_stall_multdiv_stall_branch_stall_jump_c815.AST_BSDCOV_stall_mem_stall_multdiv_stall_branch_stall_jump_c815_R_unique_010.Ht.6.fsdb
