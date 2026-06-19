package instr_gen_runtime_imem_pkg;

  localparam logic [31:0] kBootAddr = 32'h8000_0000;
  localparam logic [31:0] kFirstFetchAddr = 32'h8000_0080;

  bit enabled = 1'b0;
  logic [31:0] last_addr = 32'h8000_011c;
  logic [7:0] imem[logic [31:0]];

  function automatic void clear();
    imem.delete();
    enabled = 1'b0;
    last_addr = 32'h8000_011c;
  endfunction

  function automatic void set_last_addr(input logic [31:0] addr);
    last_addr = {addr[31:2], 2'b00};
    enabled = 1'b1;
  endfunction

  function automatic bit in_response_window(input logic [31:0] addr);
    logic [31:0] aligned_addr;
    aligned_addr = {addr[31:2], 2'b00};
    return !enabled ||
           (aligned_addr >= kFirstFetchAddr && aligned_addr <= last_addr);
  endfunction

  function automatic bit read_byte(input logic [31:0] addr,
                                   output logic [7:0] data);
    if (enabled && imem.exists(addr)) begin
      data = imem[addr];
      return 1'b1;
    end
    data = '0;
    return 1'b0;
  endfunction

  task automatic load_bin(input string path,
                          input logic [31:0] base_addr = kBootAddr);
    int fd;
    int code;
    logic [7:0] byte_data;
    logic [31:0] addr;

    imem.delete();
    fd = $fopen(path, "rb");
    if (!fd) begin
      $fatal(1, "BSDCOV_RUNTIME_IMEM cannot open %0s", path);
    end

    addr = base_addr;
    while (!$feof(fd)) begin
      code = $fread(byte_data, fd);
      if (code == 1) begin
        imem[addr] = byte_data;
        addr++;
      end
    end
    $fclose(fd);

    if (addr <= kFirstFetchAddr) begin
      last_addr = 32'h8000_011c;
    end else begin
      last_addr = {addr[31:2], 2'b00} - 32'd4;
    end
    enabled = 1'b1;
    $display("BSDCOV_RUNTIME_IMEM loaded file=%0s bytes=%0d range=0x%08x..0x%08x",
             path, addr - base_addr, kFirstFetchAddr, last_addr);
  endtask

endpackage
