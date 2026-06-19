// Runtime control bridge for BSD-Cov incremental instruction-generation simulation.
//
// Xcelium Tcl task calls are not reliable for arbitrary SystemVerilog tasks in this
// environment, so Tcl only updates a small text file and waits on applied_epoch.
// This module polls that file from HDL and applies the requested TB updates.
module bsdcov_instr_gen_runtime_ctrl;
  string control_path;
  int applied_epoch = -1;

  initial begin
    if (!$value$plusargs("bsdcov_runtime_control=%0s", control_path)) begin
      control_path = "";
    end

    if (control_path != "") begin
      forever begin
        bsdcov_poll_control();
        #1us;
      end
    end
  end

  task automatic bsdcov_poll_control();
    int fd;
    int code;
    int epoch;
    string bin_path;
    logic [31:0] patch_start;
    logic [31:0] last_addr;
    logic [31:0] stop_pc;
    logic [31:0] stop_instruction;

    fd = $fopen(control_path, "r");
    if (!fd) begin
      return;
    end
    code = $fscanf(fd, "%d\n%s\n%h\n%h\n%h\n%h\n",
                   epoch, bin_path, patch_start, last_addr,
                   stop_pc, stop_instruction);
    $fclose(fd);

    if (code != 6 || epoch < 0 || epoch == applied_epoch) begin
      return;
    end

    core_ibex_tb_top.bsdcov_apply_runtime_control(
      bin_path, patch_start, last_addr, stop_pc, stop_instruction);
    applied_epoch = epoch;
    $display("BSDCOV_RUNTIME_APPLIED epoch=%0d bin=%0s patch_start=0x%08x last_addr=0x%08x stop_pc=0x%08x stop_instruction=0x%08x",
             epoch, bin_path, patch_start, last_addr, stop_pc, stop_instruction);
  endtask
endmodule
