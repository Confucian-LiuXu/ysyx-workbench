`include "../const.v"
module Mux31(
	input  [(`RISCV_XLEN - 1):0] in0,
	input  [(`RISCV_XLEN - 1):0] in1,
	input  [(`RISCV_XLEN - 1):0] in2,
	input  [1:0] s,
	output [(`RISCV_XLEN - 1):0] o
);
	reg [(`RISCV_XLEN - 1):0] _o;
	assign o = _o;

	always @(*) begin
		case(s)
			2'd0: _o = in0;
			2'd1: _o = in1;
			2'd2: _o = in2;
			default: _o = in0;
		endcase
	end

endmodule
