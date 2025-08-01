// verilog_lint: waive-start line-length
// verilog_lint: waive-start always-comb

module Ctrl_Unit (
    input wire [5:0] op_code,
    input wire [5:0] funct,
    input wire [4:0] rt,
    input wire zero, gt, lt,
    output reg [1:0] reg_dst,
    output reg reg_write,
    output reg wr_data_src,
    output reg [1:0] alu_src,
    output reg [3:0] alu_op,
    output reg [1:0] to_reg,
    output reg [1:0] mem_data_size,
    output reg mem_write,
    output reg [1:0] lo_src,
    output reg [1:0] hi_src,
    output reg hi_write,
    output reg lo_write,
    output reg [1:0] pc_src,
    output reg div_en,
    output reg mult_en,
    output reg [1:0] sign_extend,
    output reg unsigned_instr
);

always@(*) begin
    // R-type instructions
    if (~|op_code) begin
        // Default values
        reg_dst = 2'b01; reg_write = 1; wr_data_src = 0; alu_src = 0; alu_op = 4'b1111; to_reg = 2'b10; mem_data_size = 2'b10;
        mem_write = 0; lo_src = 0; hi_src = 0; lo_write = 0; hi_write = 0; pc_src = 2'b10; div_en = 0; mult_en = 0;
        sign_extend = 2'b01; unsigned_instr = 1'b0;

        case (funct)
            6'b000000: alu_op = 4'b0000;  // SLL (Shift Left Logical)
            6'b000010: alu_op = 4'b0001;  // SRL (Shift Right Logical)
            6'b000011: alu_op = 4'b0010;  // SRA (Shift Right Arithmetic)
            6'b000100: alu_op = 4'b0011;  // SLLV (Shift Left Logical Variable)
            6'b000110: alu_op = 4'b0100;  // SRLV (Shift Right Logical Variable)
            6'b000111: alu_op = 4'b0101;  // SRAV (Shift Right Arithmetic Variable)

            // JR (Jump Register)
            6'b001000: begin
                reg_write = 1'b0; pc_src = 2'b11;
            end

            // JALR (Jump and Link Register)
            6'b001001: begin
                reg_write = 1'b1; pc_src = 2'b11; reg_dst = 2'b10; wr_data_src = 1'b1;
            end

            // MFHI (Move From HI)
            6'b010000: begin
                to_reg = 2'b00;
            end

            // MTHI (Move To HI)
            6'b010001: begin
                hi_write = 1'b1; reg_write = 1'b0;
            end

            // MFLO (Move From LO)
            6'b010010: begin
                to_reg = 2'b01;
            end

            // MTLO (Move To LO)
            6'b010011: begin
                lo_write = 1'b1; reg_write = 1'b0;
            end

            // MULT (Multiply)
            6'b011000: begin
                mult_en = 1'b1; hi_src = 2'b01; lo_src = 2'b01; hi_write = 1'b1; lo_write = 1'b1;
            end

            // MULTU (Multiply Unsigned)
            6'b011001: begin
                mult_en = 1'b1; hi_src = 2'b01; lo_src = 2'b01; hi_write = 1'b1; lo_write = 1'b1; unsigned_instr = 1'b1;
            end

            // DIV (Divide)
            6'b011010: begin
                div_en = 1'b1; hi_src = 2'b10; lo_src = 2'b10; hi_write = 1'b1; lo_write = 1'b1;
            end

            // DIVU (Divide Unsigned)
            6'b011011: begin
                div_en = 1'b1; hi_src = 2'b10; lo_src = 2'b10; hi_write = 1'b1; lo_write = 1'b1; unsigned_instr = 1'b1;
            end

            6'b100000: alu_op = 4'b0110;  // ADD (Add)
            // ADDU (Add Unsigned)
            6'b100001: begin
                alu_op = 4'b0110;   unsigned_instr = 1'b1;
            end
            6'b100010: alu_op = 4'b0111;  // SUB (Subtract)
            // SUBU (Subtract Unsigned)
            6'b100011: begin
                alu_op = 4'b0111;   unsigned_instr = 1'b1;
            end
            6'b100100: alu_op = 4'b1000;  // AND (Bitwise AND)
            6'b100101: alu_op = 4'b1001;  // OR (Bitwise OR)
            6'b100110: alu_op = 4'b1010;  // XOR (Bitwise XOR)
            6'b100111: alu_op = 4'b1011;  // NOR (Bitwise NOR)
            6'b101010: alu_op = 4'b1100;  // SLT (Set on Less Than)
            // SLTU (Set on Less Than Unsigned)
            6'b101011: begin
                alu_op = 4'b1100;
                unsigned_instr = 1'b1;
            end

            default: begin
                reg_dst = 2'b01; reg_write = 1; wr_data_src = 0; alu_src = 0; alu_op = 4'b1111; to_reg = 2'b10; mem_data_size = 2'b10;
                mem_write = 0; lo_src = 0; hi_src = 0; lo_write = 0; hi_write = 0; pc_src = 2'b10; div_en = 0; mult_en = 0;
                sign_extend = 2'b01; unsigned_instr = 1'b0;
            end
        endcase
    end
    else if (op_code == 6'b011100) begin  // MUL (Multiply output in 32-bit)
        alu_op = 4'b1101; reg_dst = 2'b01; reg_write = 1; wr_data_src = 0; alu_src = 0; to_reg = 2'b10; mem_data_size = 2'b10;
        mem_write = 0; lo_src = 0; hi_src = 0; lo_write = 0; hi_write = 0; pc_src = 2'b10; div_en = 0; mult_en = 0;
        sign_extend = 2'b01; unsigned_instr = 1'b0;
    end
    else begin
        reg_dst = 2'b00; reg_write = 1; wr_data_src = 0; alu_src = 0; alu_op = 4'b1111; to_reg = 2'b10; mem_data_size = 2'b10;
        mem_write = 0; lo_src = 0; hi_src = 0; lo_write = 0; hi_write = 0; pc_src = 2'b10; div_en = 0; mult_en = 0;
        sign_extend = 2'b01; unsigned_instr = 1'b0;

        case (op_code)
            // branch less than zero/branch greater than or equal to zero
            6'b000001: begin
                if (rt == 5'b00000) begin  // branch less than zero
                    alu_src = 2'b10; alu_op = 4'b0111; pc_src = (lt) ? 2'b00: 2'b10; reg_write = 0;
                end
                else begin // branch greater than or equal to zero
                    alu_src = 2'b10; alu_op = 4'b0111; pc_src = (gt || zero) ? 2'b00: 2'b10; reg_write = 0;
                end
            end
            // Jump
            6'b000010: begin
                pc_src = 2'b01; reg_write = 0;
            end
            // Jump and Link
            6'b000011: begin
                pc_src = 2'b01; reg_write = 1; reg_dst = 2'b10; wr_data_src = 1'b1;
            end
            // Branch if equal
            6'b000100: begin
                alu_op = 4'b0111; pc_src = zero ? 2'b00: 2'b10; reg_write = 0;
            end
            // Branch if not equal
            6'b000101: begin
                alu_op = 4'b0111; pc_src = zero ? 2'b10: 2'b00; reg_write = 0;
            end
            // branch if less than or equal to zero
            6'b000110: begin
                alu_op = 4'b0111; alu_src = 2'b10; pc_src = (lt || zero) ? 2'b00: 2'b10; reg_write = 0;
            end
            // branch if greater than zero
            6'b000111: begin
                alu_op = 4'b0111; alu_src = 2'b10; pc_src = gt ? 2'b00: 2'b10; reg_write = 0;
            end

            // Add Immediate
            6'b001000: begin
                alu_src = 2'b01; reg_write = 1; alu_op = 4'b0110; to_reg = 2'b10;
            end
            // Add Immediate Unsigned
            6'b001001: begin
                alu_src = 2'b01; reg_write = 1; alu_op = 4'b0110; to_reg = 2'b10; unsigned_instr = 1'b1;
            end
            // Set less than immediate
            6'b001010: begin
                alu_src = 2'b01; reg_write = 1; alu_op = 4'b1100; to_reg = 2'b10;
            end
            // Set less than immediate unsigned
            6'b001011: begin
                alu_src = 2'b01; reg_write = 1; alu_op = 4'b1100; to_reg = 2'b10; unsigned_instr = 1'b1;
            end
            // AND Immediate
            6'b001100: begin
                alu_src = 2'b01; reg_write = 1; alu_op = 4'b1000; to_reg = 2'b10; sign_extend = 2'b00;
            end
            // OR Immediate
            6'b001101: begin
                alu_src = 2'b01; reg_write = 1; alu_op = 4'b1001; to_reg = 2'b10; sign_extend = 2'b00;
            end
            // XOR Immediate
            6'b001110: begin
                alu_src = 2'b01; reg_write = 1; alu_op = 4'b1010; to_reg = 2'b10; sign_extend = 2'b00;
            end

            // Load Upper Immediate
            6'b001111: begin
                reg_write = 1; alu_src = 2'b01; sign_extend = 2'b10; to_reg = 2'b10; alu_op = 4'b1111; // to pass SrcB from ALU
            end

            // Load byte
            6'b100000: begin
                reg_write = 1; alu_src = 2'b01; alu_op = 4'b0110; to_reg = 2'b11; mem_write = 0; mem_data_size = 2'b00;
            end
            // Load halfword
            6'b100001: begin
                reg_write = 1; alu_src = 2'b01; alu_op = 4'b0110; to_reg = 2'b11; mem_write = 0; mem_data_size = 2'b01;
            end
            // Load Word
            6'b100011: begin
                reg_write = 1; alu_src = 2'b01; alu_op = 4'b0110; to_reg = 2'b11; mem_write = 0; mem_data_size = 2'b10;
            end
            // Load byte unsigned
            6'b100100: begin
                reg_write = 1; alu_src = 2'b01; alu_op = 4'b0110; to_reg = 2'b11; mem_write = 0; mem_data_size = 2'b00; sign_extend = 2'b00;
            end
            // Load halfword unsigned
            6'b100101: begin
                reg_write = 1; alu_src = 2'b01; alu_op = 4'b0110; to_reg = 2'b11; mem_write = 0; mem_data_size = 2'b01; sign_extend = 2'b00;
            end
            // Store byte
            6'b101000: begin
                reg_write = 0; alu_src = 2'b01; alu_op = 4'b0110; to_reg = 2'b11; mem_write = 1; mem_data_size = 2'b00;
            end
            // Store halfword
            6'b101001: begin
                reg_write = 0; alu_src = 2'b01; alu_op = 4'b0110; to_reg = 2'b11; mem_write = 1; mem_data_size = 2'b01;
            end
            // Store Word
            6'b101011: begin
                reg_write = 0; alu_src = 2'b01; alu_op = 4'b0110; to_reg = 2'b11; mem_write = 1; mem_data_size = 2'b10;
            end

            // Default
            default: begin
                reg_dst = 2'b00; reg_write = 1; wr_data_src = 0; alu_src = 0; alu_op = 4'b1111; to_reg = 2'b10; mem_data_size = 2'b10;
                mem_write = 0; lo_src = 0; hi_src = 0; lo_write = 0; hi_write = 0; pc_src = 2'b10; div_en = 0; mult_en = 0;
                sign_extend = 2'b01; unsigned_instr = 1'b0;
            end
        endcase
    end
end

endmodule
