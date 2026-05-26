analyze -sv12 \
  -f dut.f \
  fv_env/ibex_top.constraint.sv

elaborate -top ibex_top
clock clk_i
reset ~rst_ni

prove -all
