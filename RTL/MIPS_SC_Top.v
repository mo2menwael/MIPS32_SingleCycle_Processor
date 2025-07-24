// verilog_lint: waive-start line-length

module MIPS_SC_Top (
    input wire clk,
    input wire rst_n,
    output wire [3:0] led
);

wire [31:0] PC;
wire [31:0] PC_next;
wire [31:0] PC_JTA;
wire [31:0] PC_Plus_4;
wire [31:0] PC_Branch;
wire [31:0] PC_Jump_Register;
wire [31:0] Instr;
wire [31:0] Sign_OR_Zero_Imm;
wire [31:0] rd_data2;
wire [31:0] rd_data1;
wire [31:0] SrcB;
wire [31:0] alu_result;
wire [31:0] mem_rd_data;
wire [31:0] Write_Data;
wire [4:0] Reg_Write_Addr;
wire [3:0] ALU_Control;
wire Zero, GreaterThan, LessThan;
wire wr_data_src, reg_write, mem_write, hi_write, lo_write, DivEn, MultEn, unsigned_instr, overflow;
wire [1:0] pc_src;
wire [1:0] to_reg;
wire [1:0] mem_data_size;
wire [1:0] lo_src;
wire [1:0] hi_src;
wire [1:0] alu_src;
wire [1:0] reg_dst;
wire [1:0] sign_extend;
wire [63:0] div_result;
wire [63:0] mult_result;
wire [31:0] hi_in;
wire [31:0] lo_in;
wire [31:0] hi_out;
wire [31:0] lo_out;

PC_reg pc_reg_inst (
    .clk(clk),
    .rst_n(rst_n),
    .pc_next(PC_next),
    .pc(PC)
);

Instr_Mem instr_mem_inst (
    .pc(PC),
    .instr(Instr)
);

Reg_file reg_file_inst (
    .clk(clk),
    .rst_n(rst_n),
    .rd_addr1(Instr[25:21]),
    .rd_addr2(Instr[20:16]),
    .wr_addr(Reg_Write_Addr),
    .wr_data(Write_Data),
    .wr_en(reg_write),
    .rd_data1(rd_data1),
    .rd_data2(rd_data2)
);

Sign_OR_Zero_Extend sign_or_zero_extend_inst (
    .imm(Instr[15:0]),
    .sign_extend(sign_extend),
    .extended(Sign_OR_Zero_Imm)
);

Ctrl_Unit ctrl_unit_inst (
    .op_code(Instr[31:26]),
    .funct(Instr[5:0]),
    .rt(Instr[20:16]),
    .zero(Zero),
    .gt(GreaterThan),
    .lt(LessThan),
    .reg_dst(reg_dst),
    .reg_write(reg_write),
    .alu_src(alu_src),
    .alu_op(ALU_Control),
    .to_reg(to_reg),
    .mem_write(mem_write),
    .mem_data_size(mem_data_size),
    .pc_src(pc_src),
    .wr_data_src(wr_data_src),
    .lo_src(lo_src),
    .hi_src(hi_src),
    .hi_write(hi_write),
    .lo_write(lo_write),
    .div_en(DivEn),
    .mult_en(MultEn),
    .sign_extend(sign_extend),
    .unsigned_instr(unsigned_instr)
);

ALU alu_inst (
    .SrcA(rd_data1),
    .SrcB(SrcB),
    .alu_op(ALU_Control),
    .shamt(Instr[10:6]),
    .alu_result(alu_result),
    .zero(Zero),
    .gt(GreaterThan),
    .lt(LessThan),
    .unsigned_instr(unsigned_instr),
    .overflow(overflow)
);

Data_Mem data_mem_inst (
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(mem_write),
    .addr(alu_result),
    .mem_data_size(mem_data_size),
    .wr_data(rd_data2),
    .rd_data(mem_rd_data)
);

DIV_Unit div_unit_inst (
    .op1(rd_data1),
    .op2(rd_data2),
    .div_en(DivEn),
    .unsigned_instr(unsigned_instr),
    .div_result(div_result)
);

MULT_Unit mult_unit_inst (
    .op1(rd_data1),
    .op2(rd_data2),
    .mult_en(MultEn),
    .unsigned_instr(unsigned_instr),
    .mult_result(mult_result)
);

hi_reg hi_reg_inst (
    .clk(clk),
    .rst_n(rst_n),
    .hi_write(hi_write),
    .hi_in(hi_in),
    .hi_out(hi_out)
);

lo_reg lo_reg_inst (
    .clk(clk),
    .rst_n(rst_n),
    .lo_write(lo_write),
    .lo_in(lo_in),
    .lo_out(lo_out)
);


assign PC_Plus_4 = PC + 4;
assign PC_Branch = PC_Plus_4 + {Sign_OR_Zero_Imm[29:0], 2'b00};
assign PC_JTA = {PC_Plus_4[31:28], Instr[25:0], 2'b00};
assign PC_Jump_Register = rd_data1;

assign PC_next = (pc_src == 2'b00) ? PC_Branch :
                 (pc_src == 2'b01) ? PC_JTA :
                 (pc_src == 2'b10) ? PC_Plus_4 :
                 PC_Jump_Register;

assign SrcB = (alu_src == 2'b00) ? rd_data2 :
              (alu_src == 2'b01) ? Sign_OR_Zero_Imm :
              32'b0;

assign Write_Data = (wr_data_src) ? PC_Plus_4 :
                    (to_reg == 2'b00) ? hi_out :
                    (to_reg == 2'b01) ? lo_out :
                    (to_reg == 2'b10) ? alu_result :
                    mem_rd_data;

assign Reg_Write_Addr = (reg_dst == 2'b00) ? Instr[20:16] :
                        (reg_dst == 2'b01) ? Instr[15:11] :
                        {27'b0, 5'b11111}; // $ra

assign hi_in = (hi_src == 2'b00) ? rd_data1 :
               (hi_src == 2'b01) ? mult_result[63:32] :
               (hi_src == 2'b10) ? div_result[63:32] :
               32'b0;

assign lo_in = (lo_src == 2'b00) ? rd_data1 :
               (lo_src == 2'b01) ? mult_result[31:0] :
               (lo_src == 2'b10) ? div_result[31:0] :
               32'b0;

assign led = reg_file_inst.reg_file_mem[16][3:0];

endmodule
