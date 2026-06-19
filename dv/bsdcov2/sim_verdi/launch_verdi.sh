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
  -uvm \
  -simType NC \
  -uvmDebug \
  -ntb_opts uvm \
  -f /home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/uvm/core_ibex/ibex_dv_defines.f \
  -f /home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/uvm/core_ibex/ibex_dv.f \
  -f /home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/bsdcov1/bsdcov_run/iter1/bsdproj/results/bsdcov.f \
  -top core_ibex_tb_top \
  $IBEX_PARAMS \
  -ssf \
/home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/bsdcov1/bsdcov_run/iter1/sim_genbin1/fsdb/genbin1.fsdb
#/home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/bsdcov1/bsdcov_run/common_init/runs/latest/fsdb/common_init.fsdb
# /home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/bsdcov1/cpu_init/runs/latest/fsdb/init_only.fsdb
# /home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/bsdcov1/bsdcov_run/iter1/sim_genbin/fsdb/genbin.fsdb