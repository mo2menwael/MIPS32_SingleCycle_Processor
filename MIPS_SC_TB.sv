// verilog_lint: waive-start explicit-parameter-storage-type
// verilog_lint: waive-start parameter-name-style
// verilog_lint: waive-start line-length

`timescale 1ns/1ns

module MIPS_SC_TB ();

logic clk, rst_n;
logic [3:0] led;

MIPS_SC_Top dut (
    .clk(clk),
    .rst_n(rst_n),
    .led(led)
);

parameter clock_period = 10;
always #(clock_period/2) clk = ~clk;

initial begin
    $dumpfile("MIPS_SC_Top.vcd");
    $dumpvars;

    clk = 0;
    rst_n = 0;
    #clock_period;
    rst_n = 1;

    // Initialize memory with some test instructions or load from file
    $readmemh("Tests/Test6.hex", dut.instr_mem_inst.mem);

    #1000; // Run for a sufficient time to execute all instructions

    $stop;
end

endmodule
