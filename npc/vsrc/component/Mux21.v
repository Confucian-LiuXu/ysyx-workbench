`include "../const.v"
module Mux21(
	input  [(`RISCV_XLEN - 1):0] x,
	input  [(`RISCV_XLEN - 1):0] y,
	input  s,	// select
	output [(`RISCV_XLEN - 1):0] o
);
	assign o = s ? y : x;
endmodule
