/* verilator lint_off UNUSEDSIGNAL */
`include "../const.v"
module BranchComp(
	input [(`RISCV_XLEN - 1):0] A,
	input [(`RISCV_XLEN - 1):0] B,
	input [(`BR_BIT     - 1):0] BrSel,
	output BrJp
);
	reg _BrJp;
	assign BrJp = _BrJp;

	wire eq = (A == B);
	// lt
	wire [`RISCV_XLEN:0] lt_tmp = {A[`RISCV_XLEN - 1], A} - {B[`RISCV_XLEN - 1], B};
	wire lt = lt_tmp[`RISCV_XLEN];
	// ltu
	wire ltu = (A < B);

	always @(*) begin
		case(BrSel)
			`ENUM_BR_EQ  : _BrJp =  eq;
			`ENUM_BR_NEQ : _BrJp = ~eq;
			`ENUM_BR_LT  : _BrJp =  lt;
			`ENUM_BR_GTE : _BrJp = ~lt;
			`ENUM_BR_LTU : _BrJp =  ltu;
			`ENUM_BR_GTEU: _BrJp = ~ltu; 
			default: _BrJp = 1'b0;
		endcase
	end
endmodule
