module bsdcov_instr_gen_runtime_ctrl;

  string control_path;
  int applied_epoch = -999999999;

  initial begin
    if (!$value$plusargs("bsdcov_runtime_control=%s", control_path)) begin
      control_path = "";
      $display("BSDCOV_RUNTIME_CTRL no +bsdcov_runtime_control plusarg");
    end else begin
      $display("BSDCOV_RUNTIME_CTRL control=%0s", control_path);
    end

    apply_control_file();
    forever begin
      #1ns;
      apply_control_file();
    end
  end

  task automatic apply_control_file();
    int fd;
    int code;
    int epoch;
    string bin_path;
    logic [31:0] last_addr;
    logic [31:0] stop_pc;
    logic [31:0] stop_instruction;

    if (control_path == "") begin
      return;
    end

    fd = $fopen(control_path, "r");
    if (!fd) begin
      return;
    end

    code = $fscanf(fd, "%d\n%s\n%h\n%h\n%h\n",
                   epoch, bin_path, last_addr, stop_pc, stop_instruction);
    $fclose(fd);
    if (code != 5 || epoch == applied_epoch) begin
      return;
    end

    instr_gen_runtime_imem_pkg::load_bin(bin_path);
    instr_gen_runtime_imem_pkg::set_last_addr(last_addr);
    core_ibex_tb_top.u_bsdcov_instr_gen_eval_stop.bsdcov_arm_epoch(
        stop_pc, stop_instruction);
    applied_epoch = epoch;
    $display("BSDCOV_RUNTIME_CTRL applied epoch=%0d bin=%0s last_addr=0x%08x stop_pc=0x%08x stop_instruction=0x%08x",
             epoch, bin_path, instr_gen_runtime_imem_pkg::last_addr,
             stop_pc, stop_instruction);
  endtask

endmodule
