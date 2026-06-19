module instr_vld #(
  // OpenTitan-style default:
  //   RV32M = enabled
  //   RV32B = RV32BOTEarlGrey
  parameter bit          RV32M_EN   = 1'b1,
  parameter int unsigned RV32B_MODE = 2
) (
  input  logic [31:0] instr_i,
  output logic        instr_vld
);

  localparam int unsigned RV32B_NONE       = 0;
  localparam int unsigned RV32B_BALANCED   = 1;
  localparam int unsigned RV32B_OTEARLGREY = 2;
  localparam int unsigned RV32B_FULL       = 3;

  localparam bit RV32B_ANY        = (RV32B_MODE != RV32B_NONE);
  localparam bit RV32B_OT_OR_FULL = (RV32B_MODE == RV32B_OTEARLGREY) ||
                                    (RV32B_MODE == RV32B_FULL);
  localparam bit RV32B_FULL_EN    = (RV32B_MODE == RV32B_FULL);

  localparam logic [6:0] OPCODE_LOAD     = 7'h03;
  localparam logic [6:0] OPCODE_MISC_MEM = 7'h0f;
  localparam logic [6:0] OPCODE_OP_IMM   = 7'h13;
  localparam logic [6:0] OPCODE_AUIPC    = 7'h17;
  localparam logic [6:0] OPCODE_STORE    = 7'h23;
  localparam logic [6:0] OPCODE_OP       = 7'h33;
  localparam logic [6:0] OPCODE_LUI      = 7'h37;
  localparam logic [6:0] OPCODE_BRANCH   = 7'h63;
  localparam logic [6:0] OPCODE_JALR     = 7'h67;
  localparam logic [6:0] OPCODE_JAL      = 7'h6f;
  localparam logic [6:0] OPCODE_SYSTEM   = 7'h73;

  function automatic logic load_vld(input logic [31:0] instr);
    begin
      unique case (instr[14:12])
        3'b000, // lb
        3'b001, // lh
        3'b010, // lw
        3'b100, // lbu
        3'b101: // lhu
          load_vld = 1'b1;

        default:
          load_vld = 1'b0;
      endcase
    end
  endfunction

  function automatic logic store_vld(input logic [31:0] instr);
    begin
      unique case (instr[14:12])
        3'b000, // sb
        3'b001, // sh
        3'b010: // sw
          store_vld = 1'b1;

        default:
          store_vld = 1'b0;
      endcase
    end
  endfunction

  function automatic logic branch_vld(input logic [31:0] instr);
    begin
      unique case (instr[14:12])
        3'b000, // beq
        3'b001, // bne
        3'b100, // blt
        3'b101, // bge
        3'b110, // bltu
        3'b111: // bgeu
          branch_vld = 1'b1;

        default:
          branch_vld = 1'b0;
      endcase
    end
  endfunction

  function automatic logic misc_mem_vld(input logic [31:0] instr);
    begin
      // Match Ibex decoder behavior:
      //   funct3 = 000: FENCE, treated as NOP
      //   funct3 = 001: FENCE.I, used to flush IF/prefetch/ICache
      unique case (instr[14:12])
        3'b000,
        3'b001:
          misc_mem_vld = 1'b1;

        default:
          misc_mem_vld = 1'b0;
      endcase
    end
  endfunction

  function automatic logic system_vld(input logic [31:0] instr);
    begin
      system_vld = 1'b0;

      if (instr[14:12] == 3'b000) begin
        unique case (instr[31:20])
          12'h000, // ecall
          12'h001, // ebreak
          12'h302, // mret
          12'h7b2, // dret
          12'h105: begin // wfi
            // Ibex requires rd == x0 and rs1 == x0 for non-CSR SYSTEM instructions.
            system_vld = (instr[11:7] == 5'b0) && (instr[19:15] == 5'b0);
          end

          default: begin
            system_vld = 1'b0;
          end
        endcase
      end else begin
        // CSR instructions accepted by the main decoder:
        //   001: CSRRW
        //   010: CSRRS
        //   011: CSRRC
        //   101: CSRRWI
        //   110: CSRRSI
        //   111: CSRRCI
        //
        // funct3 = 100 is illegal.
        unique case (instr[14:12])
          3'b001,
          3'b010,
          3'b011,
          3'b101,
          3'b110,
          3'b111:
            system_vld = 1'b1;

          default:
            system_vld = 1'b0;
        endcase
      end
    end
  endfunction

  function automatic logic op_imm_vld(input logic [31:0] instr);
    begin
      op_imm_vld = 1'b0;

      unique case (instr[14:12])
        // addi, slti, sltiu, xori, ori, andi
        3'b000,
        3'b010,
        3'b011,
        3'b100,
        3'b110,
        3'b111: begin
          op_imm_vld = 1'b1;
        end

        // slli and RV32B immediate operations
        3'b001: begin
          unique case (instr[31:27])
            // slli: instr[31:25] must be 0000000
            5'b0_0000: begin
              op_imm_vld = (instr[26:25] == 2'b00);
            end

            // sloi
            5'b0_0100: begin
              op_imm_vld = RV32B_OT_OR_FULL;
            end

            // bclri, bseti, binvi
            5'b0_1001,
            5'b0_0101,
            5'b0_1101: begin
              op_imm_vld = RV32B_ANY;
            end

            // shfl immediate
            5'b0_0001: begin
              op_imm_vld = (instr[26] == 1'b0) && RV32B_OT_OR_FULL;
            end

            5'b0_1100: begin
              unique case (instr[26:20])
                // clz, ctz, cpop, sext.b, sext.h
                7'b000_0000,
                7'b000_0001,
                7'b000_0010,
                7'b000_0100,
                7'b000_0101: begin
                  op_imm_vld = RV32B_ANY;
                end

                // crc32.b, crc32.h, crc32.w, crc32c.b, crc32c.h, crc32c.w
                7'b001_0000,
                7'b001_0001,
                7'b001_0010,
                7'b001_1000,
                7'b001_1001,
                7'b001_1010: begin
                  op_imm_vld = RV32B_OT_OR_FULL;
                end

                default: begin
                  op_imm_vld = 1'b0;
                end
              endcase
            end

            default: begin
              op_imm_vld = 1'b0;
            end
          endcase
        end

        // srli/srai and RV32B immediate operations
        3'b101: begin
          if (instr[26]) begin
            // Ibex treats this as fsri-style RV32B encoding.
            op_imm_vld = RV32B_ANY;
          end else begin
            unique case (instr[31:27])
              // srli, srai; instr[26:25] must be 00
              5'b0_0000,
              5'b0_1000: begin
                op_imm_vld = (instr[26:25] == 2'b00);
              end

              // sroi
              5'b0_0100: begin
                op_imm_vld = RV32B_OT_OR_FULL;
              end

              // rori, bexti
              5'b0_1100,
              5'b0_1001: begin
                op_imm_vld = RV32B_ANY;
              end

              // grevi / rev8
              5'b0_1101: begin
                if (RV32B_OT_OR_FULL) begin
                  op_imm_vld = 1'b1;
                end else if (RV32B_MODE == RV32B_BALANCED) begin
                  op_imm_vld = (instr[24:20] == 5'b11000);
                end else begin
                  op_imm_vld = 1'b0;
                end
              end

              // gorci / orc.b
              5'b0_0101: begin
                if (RV32B_OT_OR_FULL) begin
                  op_imm_vld = 1'b1;
                end else if (RV32B_MODE == RV32B_BALANCED) begin
                  op_imm_vld = (instr[24:20] == 5'b00111);
                end else begin
                  op_imm_vld = 1'b0;
                end
              end

              // unshfl
              5'b0_0001: begin
                op_imm_vld = RV32B_OT_OR_FULL;
              end

              default: begin
                op_imm_vld = 1'b0;
              end
            endcase
          end
        end

        default: begin
          op_imm_vld = 1'b0;
        end
      endcase
    end
  endfunction

  function automatic logic op_vld(input logic [31:0] instr);
    begin
      op_vld = 1'b0;

      // Ibex special handling for cmix/cmov/fsl/fsr.
      if ({instr[26], instr[13:12]} == {1'b1, 2'b01}) begin
        op_vld = RV32B_ANY;
      end else begin
        unique case ({instr[31:25], instr[14:12]})
          // RV32I register-register ALU operations
          {7'b000_0000, 3'b000}, // add
          {7'b010_0000, 3'b000}, // sub
          {7'b000_0000, 3'b010}, // slt
          {7'b000_0000, 3'b011}, // sltu
          {7'b000_0000, 3'b100}, // xor
          {7'b000_0000, 3'b110}, // or
          {7'b000_0000, 3'b111}, // and
          {7'b000_0000, 3'b001}, // sll
          {7'b000_0000, 3'b101}, // srl
          {7'b010_0000, 3'b101}: begin // sra
            op_vld = 1'b1;
          end

          // RV32B, accepted for any non-None RV32B mode in Ibex decoder
          {7'b001_0000, 3'b010}, // sh1add
          {7'b001_0000, 3'b100}, // sh2add
          {7'b001_0000, 3'b110}, // sh3add
          {7'b010_0000, 3'b111}, // andn
          {7'b010_0000, 3'b110}, // orn
          {7'b010_0000, 3'b100}, // xnor
          {7'b011_0000, 3'b001}, // rol
          {7'b011_0000, 3'b101}, // ror
          {7'b000_0101, 3'b100}, // min
          {7'b000_0101, 3'b110}, // max
          {7'b000_0101, 3'b101}, // minu
          {7'b000_0101, 3'b111}, // maxu
          {7'b000_0100, 3'b100}, // pack
          {7'b010_0100, 3'b100}, // packu
          {7'b000_0100, 3'b111}, // packh
          {7'b010_0100, 3'b001}, // bclr
          {7'b001_0100, 3'b001}, // bset
          {7'b011_0100, 3'b001}, // binv
          {7'b010_0100, 3'b101}, // bext
          {7'b010_0100, 3'b111}: begin // bfp
            op_vld = RV32B_ANY;
          end

          // RV32B OTEarlGrey or Full
          {7'b011_0100, 3'b101}, // grev
          {7'b001_0100, 3'b101}, // gorc
          {7'b000_0100, 3'b001}, // shfl
          {7'b000_0100, 3'b101}, // unshfl
          {7'b001_0100, 3'b010}, // xperm.n
          {7'b001_0100, 3'b100}, // xperm.b
          {7'b001_0100, 3'b110}, // xperm.h
          {7'b001_0000, 3'b001}, // slo
          {7'b001_0000, 3'b101}, // sro
          {7'b000_0101, 3'b001}, // clmul
          {7'b000_0101, 3'b010}, // clmulr
          {7'b000_0101, 3'b011}: begin // clmulh
            op_vld = RV32B_OT_OR_FULL;
          end

          // RV32B Full only
          {7'b010_0100, 3'b110}, // bdecompress
          {7'b000_0100, 3'b110}: begin // bcompress
            op_vld = RV32B_FULL_EN;
          end

          // RV32M
          {7'b000_0001, 3'b000}, // mul
          {7'b000_0001, 3'b001}, // mulh
          {7'b000_0001, 3'b010}, // mulhsu
          {7'b000_0001, 3'b011}, // mulhu
          {7'b000_0001, 3'b100}, // div
          {7'b000_0001, 3'b101}, // divu
          {7'b000_0001, 3'b110}, // rem
          {7'b000_0001, 3'b111}: begin // remu
            op_vld = RV32M_EN;
          end

          default: begin
            op_vld = 1'b0;
          end
        endcase
      end
    end
  endfunction

  function automatic logic main_decoder_vld(input logic [31:0] instr);
    begin
      main_decoder_vld = 1'b0;

      unique case (instr[6:0])
        OPCODE_JAL: begin
          main_decoder_vld = 1'b1;
        end

        OPCODE_JALR: begin
          main_decoder_vld = (instr[14:12] == 3'b000);
        end

        OPCODE_BRANCH: begin
          main_decoder_vld = branch_vld(instr);
        end

        OPCODE_LOAD: begin
          main_decoder_vld = load_vld(instr);
        end

        OPCODE_STORE: begin
          main_decoder_vld = store_vld(instr);
        end

        OPCODE_LUI,
        OPCODE_AUIPC: begin
          main_decoder_vld = 1'b1;
        end

        OPCODE_OP_IMM: begin
          main_decoder_vld = op_imm_vld(instr);
        end

        OPCODE_OP: begin
          main_decoder_vld = op_vld(instr);
        end

        OPCODE_MISC_MEM: begin
          main_decoder_vld = misc_mem_vld(instr);
        end

        OPCODE_SYSTEM: begin
          main_decoder_vld = system_vld(instr);
        end

        default: begin
          main_decoder_vld = 1'b0;
        end
      endcase
    end
  endfunction

  always_comb begin
    instr_vld = 1'b0;

    // This module is intended for the Ibex main decoder input.
    // Therefore the instruction should already be decompressed and be a normal 32-bit encoding.
    if (instr_i[1:0] == 2'b11) begin
      instr_vld = main_decoder_vld(instr_i);
    end
  end

endmodule