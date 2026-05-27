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
  -f bsd/asserts/bsd_cov_region_asserts.f \
  fv_env/ibex_top.constraint.sv

elaborate -top ibex_top -parameter WritebackStage 1
clock clk_i

reset ~rst_ni

report -summary -file [file join $report_dir "fpv_setup_summary.$trace_name.txt"] -force

set_prove_dump_trace_type assert
set per_prop_time 300s

set target_props {}
foreach p [get_property_list -include {type assert}] {
  if {[string match "*AST_BSDCOV_*" $p]} {
    lappend target_props $p
  }
}

if {[llength $target_props] == 0} {
  puts "ERROR: no generated BSD-Cov region assertions matched AST_BSDCOV_*"
  exit 1
}

puts "INFO: BSD-Cov region assertion count = [llength $target_props]"

prove -property $target_props -asserts -force \
  -per_property_time_limit $per_prop_time \
  -dump_trace \
  -dump_trace_type fsdb \
  -dump_trace_dir $trace_dir

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

exit
