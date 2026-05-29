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
  -f bsd/asserts/bsd_cov_region_asserts.f \
  -f env.f \
  -top ibex_top \
  $IBEX_PARAMS \
  -ssf \
./jgproject/traces_fsdb.bsd_cov_region_asserts/7.ibex_top.u_ibex_core.id_stage_i.bsd_cov_ibex_hazard_stall_region_asserts_bind_inst.AST_BSDCOV_R_stall_ld_hz_001.Ht.7.fsdb

