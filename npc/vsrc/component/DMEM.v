/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off UNDRIVEN */
`include "../const.v"
module DMEM(
	input  clk,	// single cycle, clk is used with MemWEn
	input  rst,
	input  MemWEn,
	input  [(`LS_BIT     - 1):0] BitSel,
	input  [(`RISCV_XLEN - 1):0] addr,
	input  [(`RISCV_XLEN - 1):0] dataW,
	output [(`RISCV_XLEN - 1):0] dataR
);
	/* TODO ==> DPI-C */
	// pmem_read(...)  ==> lb, lbu, lh, lhu, lw, lwu, ld
	// pmem_write(...) ==> sb, sh, sw, sd
	// Extractor.v
endmodule
