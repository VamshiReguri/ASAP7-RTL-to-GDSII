module alu32_pipeline (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [2:0]  op,
    output reg  [31:0] Y
);
reg [31:0] alu_result;
reg [31:0] A_reg;
reg [31:0] B_reg;
reg [2:0]  op_reg;

always @(*) begin
    case (op_reg)
        3'b000: alu_result = A_reg + B_reg;
	3'b001: alu_result = A_reg - B_reg;
	3'b010: alu_result = A_reg & B_reg;
	3'b011: alu_result = A_reg | B_reg;
	3'b100: alu_result = A_reg ^ B_reg;
	default: alu_result = 32'b0;
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        A_reg <= 32'b0;
        B_reg <= 32'b0;
        op_reg <= 3'b000;
        Y <= 32'b0;
    end
    else begin
        A_reg <= A;
        B_reg <= B;
        op_reg <= op;
        Y <= alu_result;
    end
end

endmodule
