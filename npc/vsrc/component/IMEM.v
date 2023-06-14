/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off UNDRIVEN */
`include "../const.v"
module IMEM(
	input  [(`RISCV_XLEN - 1):0] addr,
	output [31:0] inst
);
	/* TODO ==> DPI-C */
endmodule
