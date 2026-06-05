clear -all

# Make relative paths stable even if JasperGold is launched from another directory.
set fml_dir [file normalize [file dirname [info script]]]
cd $fml_dir

set trace_name  "bsd_cov_region_asserts"
set trace_dir   [file normalize [file join "jgproject" "traces_fsdb.$trace_name"]]
set report_dir  [file normalize [file join "jgproject" "reports"]]

file delete -force $trace_dir
file mkdir $trace_dir
file mkdir $report_dir

puts "INFO: FSDB dir     = $trace_dir"
puts "INFO: report dir   = $report_dir"
puts "INFO: constraints  = fv_env/ibex_top.constraint.sv"
puts "INFO: target set   = AST_BSDCOV_* region assertions"

analyze -sv12 \
  -f dut.f \
  -f ../bsdcovproj/results/bsdcov.f \
  -f env.f

elaborate -top ibex_top \
  -parameter RV32E                 0 \
  -parameter RV32M                 {ibex_pkg::RV32MSingleCycle} \
  -parameter RV32B                 {ibex_pkg::RV32BOTEarlGrey} \
  -parameter RV32ZC                {ibex_pkg::RV32ZcaZcbZcmp} \
  -parameter RegFile               {ibex_pkg::RegFileFF} \
  -parameter BranchTargetALU       1 \
  -parameter WritebackStage        1 \
  -parameter ICache                1 \
  -parameter ICacheECC             1 \
  -parameter ICacheScramble        1 \
  -parameter ICacheTweakInfection  0 \
  -parameter BranchPredictor       0 \
  -parameter DbgTriggerEn          1 \
  -parameter DbgHwBreakNum         1 \
  -parameter SecureIbex            1 \
  -parameter LockstepOffset        1 \
  -parameter PMPEnable             1 \
  -parameter PMPGranularity        0 \
  -parameter PMPNumRegions         16 \
  -parameter MHPMCounterNum        10 \
  -parameter MHPMCounterWidth      32 \
  -parameter DmBaseAddr            {32'h1A110000} \
  -parameter DmAddrMask            {32'h00000FFF} \
  -parameter DmHaltAddr            {32'h80000000} \
  -parameter DmExceptionAddr       {32'h80000008}

clock clk_i
# reset ~rst_ni
set sim_fsdb [file normalize "/home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/bsdcov/sim/runs/run.20260604T081928Z.n1.step100/fsdb/bsdcov_chunk_0000.1.fsdb"]
set sim_dut_hier "core_ibex_tb_top.dut.u_ibex_top"

set_trace_show_reset false

# Just a reminder
# set snapshot_time 123456

reset -clear
reset -sequence -fsdb $sim_fsdb \
  -hier_path $sim_dut_hier \
  -non_resettable_regs 0
# -time $snapshot_time

report -summary -file [file join $report_dir "fpv_setup_summary.$trace_name.txt"] -force

set_prove_dump_trace_type assert
# set_trace_optimization standard
set per_prop_time 300s

set target_props {}
foreach p [get_property_list -include {type assert}] {
  if {[string match "*AST_BSDCOV_*" $p]} {
    lappend target_props $p
  }
}

if {[llength $target_props] == 0} {
  puts "ERROR: no generated BSD-Cov region coverage matched AST_BSDCOV_*"
  exit 1
}

puts "INFO: BSD-Cov region assertion count = [llength $target_props]"

# ----------------------------------------------------------------------
# Multi-CEX configuration
# ----------------------------------------------------------------------
set max_traces_per_prop 10
set max_hunt_rounds     10
set hunt_round_time     300s

set multi_trace_root [file normalize [file join $trace_dir "multi_cex"]]
file delete -force $multi_trace_root
file mkdir $multi_trace_root

# Enable multi-trace storage for each generated assertion.
# assert -set_store_trace supports 0/1/unlimited, not an integer N.
foreach p $target_props {
  assert -set_store_trace unlimited $p
}

proc bsdcov_prop_status {p} {
  set info [get_property_info -list {status} $p]
  return [lindex $info 0]
}

proc bsdcov_prop_num_traces {p} {
  set info [get_property_info -list {num_traces} $p]
  set n [lindex $info 0]
  if {$n eq ""} {
    return 0
  }
  return $n
}

proc bsdcov_prop_trace_ids {p} {
  set info [get_property_info -list {trace_id} $p]
  return [lindex $info 0]
}

proc bsdcov_safe_name {s} {
  regsub -all {[^A-Za-z0-9_.-]} $s "_" out
  return $out
}

# ----------------------------------------------------------------------
# Round 0: normal prove to get the first CEX trace
# ----------------------------------------------------------------------
set prove_trace_dir [file normalize [file join $multi_trace_root "round_00_prove"]]
file mkdir $prove_trace_dir

puts "INFO: multi-CEX round 0: prove initial CEX traces"

prove -property $target_props -asserts -force \
  -per_property_time_limit $per_prop_time \
  -dump_trace \
  -dump_trace_type fsdb \
  -dump_trace_dir $prove_trace_dir

# ----------------------------------------------------------------------
# Rounds 1..N: hunt for additional traces
# ----------------------------------------------------------------------
for {set round 1} {$round <= $max_hunt_rounds} {incr round} {
  set need_more {}

  foreach p $target_props {
    set st [bsdcov_prop_status $p]
    set nt [bsdcov_prop_num_traces $p]

    if {($st eq "cex" || $st eq "ar_cex") && $nt < $max_traces_per_prop} {
      lappend need_more $p
    }
  }

  if {[llength $need_more] == 0} {
    puts "INFO: all CEX properties reached max trace target = $max_traces_per_prop"
    break
  }

  set round_dir [file normalize [file join $multi_trace_root [format "round_%02d_hunt" $round]]]
  file mkdir $round_dir

  puts "INFO: multi-CEX hunt round $round"
  puts "INFO: properties needing more traces = [llength $need_more]"
  puts "INFO: dump dir = $round_dir"

  hunt -clear

  hunt -config -strategy [format "bsdcov_multi_cex_%02d" $round] \
    -mode state_swarm \
    -target_type assert \
    -max_jobs 8 \
    -max_trace_length 300 \
    -seed $round

  hunt -run \
    -strategy [format "bsdcov_multi_cex_%02d" $round] \
    -property $need_more \
    -time_limit $hunt_round_time \
    -force \
    -dump_trace \
    -dump_trace_type fsdb \
    -dump_trace_dir $round_dir

  hunt -report -detailed \
    -start_time \
    -engine_config \
    -engine_stats \
    -sort_by cex
}

# ----------------------------------------------------------------------
# Summary
# ----------------------------------------------------------------------
set trace_summary_file [open [file join $report_dir "trace_summary.$trace_name.tsv"] w]
puts $trace_summary_file "property\tstatus\tnum_traces\ttrace_ids"

foreach p $target_props {
  set st  [bsdcov_prop_status $p]
  set nt  [bsdcov_prop_num_traces $p]
  set tids [bsdcov_prop_trace_ids $p]
  puts $trace_summary_file "$p\t$st\t$nt\t$tids"
}

close $trace_summary_file

report -property $target_props -results -detailed \
  -file [file join $report_dir "fpv_report.$trace_name.txt"] -force

report -property $target_props -csv -include_type \
  -file [file join $report_dir "fpv_report.$trace_name.csv"] -force

set cex_file [open [file join $report_dir "cex_properties.$trace_name.list"] w]
foreach p $target_props {
  set st [get_status $p]
  if {$st eq "cex" || $st eq "ar_cex"} {
    puts $cex_file $p
  }
}
close $cex_file

# exit
