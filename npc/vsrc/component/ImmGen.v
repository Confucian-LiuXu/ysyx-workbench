/* verilator lint_off UNUSEDSIGNAL */
`include "../const.v"
module ImmGen(
	input  [31:0] inst,
	input  [(`TYPE_BIT   - 1):0] ImmSel,
	output [(`RISCV_XLEN - 1):0] imm
);
	reg  [(`RISCV_XLEN - 1):0] _imm;
	assign imm = _imm;

	localparam immX  = `RISCV_XLEN'd0;
	// ImmSel is based on "instruction format"
	wire [(`RISCV_XLEN - 1):0] immI = { {(`RISCV_XLEN - 12){inst[31]}}, inst[31:20] };
	wire [(`RISCV_XLEN - 1):0] immU = { {(`RISCV_XLEN - 32){inst[31]}}, inst[31:12], {12{1'b0}} };

	always @(*) begin
		case (ImmSel)
			`ENUM_TYPE_R  : _imm = immX;
			// the actual '_imm' of 'slli, srli, srai' ====>
			// '{ {(`RISCV_XLEN - `RISCV_XLEN_EXP){inst[20 + `RISCV_XLEN_EXP - 1]}}, inst[(20 + `RISCV_XLEN_EXP - 1):20] }'
			// However, module 'ALU' will deal with the situation
			`ENUM_TYPE_I  : _imm = immI;
 			`ENUM_TYPE_I_M: _imm = immI;
 			`ENUM_TYPE_I_J: _imm = immI;
 			`ENUM_TYPE_S  : _imm = { {(`RISCV_XLEN - 12){inst[31]}}, inst[31:25], inst[11:7] };
 			`ENUM_TYPE_B  : _imm = { {(`RISCV_XLEN - 13){inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
 			`ENUM_TYPE_J  : _imm = { {(`RISCV_XLEN - 21){inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0 };
 			`ENUM_TYPE_U_A: _imm = immU;
 			`ENUM_TYPE_U_L: _imm = immU;
 			`ENUM_TYPE_E  : _imm = immX;
			default: _imm = immX;
		endcase
	end
endmodule
