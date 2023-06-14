`include "../const.v"
module PC(
	input  clk,
	input  rst,
	input  WEn,	// Write Enable
	input  [(`RISCV_XLEN - 1):0] din,
	output [(`RISCV_XLEN - 1):0] dout
);
	reg [(`RISCV_XLEN - 1):0] _dout;
	assign dout = _dout;

	always @(posedge clk) begin
		if (rst)
			_dout <= `RISCV_PC_RST_VAL;
		else if (WEn)
			_dout <= din;
	end
	// TODO => DPI-C
endmodule
