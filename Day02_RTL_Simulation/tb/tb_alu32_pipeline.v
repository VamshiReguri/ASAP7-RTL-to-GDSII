`timescale 1ns/1ps

module tb_alu32_pipeline;

reg clk;
reg rst;
reg [31:0] A;
reg [31:0] B;
reg [2:0]  op;

wire [31:0] Y;

alu32_pipeline dut (
    .clk(clk),
    .rst(rst),
    .A(A),
    .B(B),
    .op(op),
    .Y(Y)
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

initial begin
    rst = 1'b1;
    A   = 32'b0;
    B   = 32'b0;
    op  = 3'b000;

    #12;
    rst = 1'b0;
end

initial begin
    $dumpfile("../waveforms/alu32_pipeline.vcd");
    $dumpvars(0, tb_alu32_pipeline);

    #15;
    A  = 32'd10;
    B  = 32'd20;
    op = 3'b000;   // ADD
    #11;
    $display("ADD: A=%0d B=%0d Y=%0d", A, B, Y);

    @(negedge clk);
    A  = 32'd30;
    B  = 32'd10;
    op = 3'b001;   // SUB
    
    @(posedge clk);
    @(posedge clk);
    #1;
    $display("SUB: A=%0d B=%0d Y=%0d", A, B, Y);

    @(negedge clk);
    A  = 32'h0F0F0F0F;
    B  = 32'h00FF00FF;
    op = 3'b010;   // AND
    
    @(posedge clk);
    @(posedge clk);
    #1;  
    $display("AND: A=%h B=%h Y=%h", A, B, Y);

    @(negedge clk);
    A  = 32'h0F0F0F0F;
    B  = 32'h00FF00FF;
    op = 3'b011;   // OR
    
    @(posedge clk);
    @(posedge clk);
    #1;
    $display("OR : A=%h B=%h Y=%h", A, B, Y);

    @(negedge clk);
    A  = 32'h0F0F0F0F;
    B  = 32'h00FF00FF;
    op = 3'b100;   // XOR
    
    @(posedge clk);
    @(posedge clk);
    #1;
    $display("XOR: A=%h B=%h Y=%h", A, B, Y);

    $finish;

end

endmodule
