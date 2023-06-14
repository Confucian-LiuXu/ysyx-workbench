/* verilator lint_off UNUSEDSIGNAL */
`include "../const.v"
module ALU(
	input  [(`RISCV_XLEN - 1):0] A,
	input  [(`RISCV_XLEN - 1):0] B,
	input  [(`OP_BIT	 - 1):0] ALUSel,
	output [(`RISCV_XLEN - 1):0] o
);
	reg [(`RISCV_XLEN - 1):0] _o;
	assign o = _o;

	// `SRA
	wire sign = A[`RISCV_XLEN - 1];
	wire [(`RISCV_XLEN * 2 - 1):0] sra_tmp = { {`RISCV_XLEN{sign}}, A } >> B[(`RISCV_XLEN_EXP - 1):0];
	// `SLT
	wire [`RISCV_XLEN:0] slt_tmp = {A[`RISCV_XLEN - 1], A} - {B[`RISCV_XLEN - 1], B};

	localparam ZERO = `RISCV_XLEN'd0;

	always @(*) begin
		case (ALUSel)
			`ENUM_OP_ADD : _o = A + B;
			// A + (~B + `RISCV_XLEN'd1);
			`ENUM_OP_SUB : _o = A - B;	
			`ENUM_OP_AND : _o = A & B;
			`ENUM_OP_OR  : _o = A | B;
			`ENUM_OP_XOR : _o = A ^ B;
			// RV32I, A << B[4:0]; RV64I, A << B[5:0]
			`ENUM_OP_SLL : _o = A << B[(`RISCV_XLEN_EXP - 1):0];	
			// RV32I, A >> B[4:0]; RV64I, A >> B[5:0]
			`ENUM_OP_SRL : _o = A >> B[(`RISCV_XLEN_EXP - 1):0];
			// eApand => 64 + 64 bit => truncate => 64 bit
			`ENUM_OP_SRA : _o = sra_tmp[(`RISCV_XLEN - 1):0];
			// if A < B, then sign bit of (A - B) == 1
			`ENUM_OP_SLT : _o = { {(`RISCV_XLEN - 1){1'b0}}, slt_tmp[`RISCV_XLEN] }; 
			// A | B => unsigned, so the rational eApression is unsigned comparison(IEEE 2005)
			`ENUM_OP_SLTU: _o = (A < B) ? 1 : 0;
			`ENUM_OP_ADD0: _o = B; // lui
			// TODO 
			default: _o = ZERO;
		endcase
	end
endmodule
