`include "../const.v"
module RegFile(
	input  clk,
	input  rst,
	input  RegWEn,	// Register File Write Enable
	input  [4:0] rs2,
	input  [4:0] rs1,
	input  [4:0] rd,
	input  [(`RISCV_XLEN - 1):0] dataW,
	output [(`RISCV_XLEN - 1):0] data1,
	output [(`RISCV_XLEN - 1):0] data2
);
	reg [(`RISCV_XLEN - 1):0] rf [(`RISCV_REG_NUM - 1):0];
	integer j;

	always @(posedge clk) begin
		if (rst) begin
			for (j = 0; j < `RISCV_REG_NUM; j = j + 1)
				rf[j] <= `RISCV_XLEN'd0;
		end
		else if (RegWEn)
			rf[rd] <= dataW;
	end
	
	assign data1 = rf[rs1];
	assign data2 = rf[rs2];
	// TODO DPI-C => gpr[0] ... gpr[31]
endmodule
