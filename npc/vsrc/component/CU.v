/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off UNDRIVEN */
`include "../const.v"
module CU(
	// Control Unit => combinational logic
	input  [31:0] inst,
	input  BrJp,
	output [(`OP_BIT   - 1):0] ALUSel,
	output [(`TYPE_BIT - 1):0] ImmSel,
	output [(`LS_BIT   - 1):0] BitSel,
	output [(`BR_BIT   - 1):0]  BrSel,
	output ASel,
	output [1:0] BSel,
	output PCSel,
	output CSel,
	output MemWEn,
	output RegWEn,
	output EndSim
);
	wire [6:0] opcode = inst[ 6: 0];
	wire [4:0] rd	  = inst[11: 7];
	wire [2:0] func3  = inst[14:12];
	wire [4:0] rs1	  = inst[19:15];
	wire [4:0] rs2	  = inst[24:20];
	wire [6:0] func7  = inst[31:25];

	// TODO : TYPE_E => CSR ?

	// ------------------- ALUSel ----------------------
	reg [(`OP_BIT - 1):0] _ALUSel;
	assign ALUSel = _ALUSel;

	always @(*) begin
		case (opcode)
			`TYPE_R: begin
				// hierachical decode => first decode 'func3', then decode 'func7'
				case(func3)
					// add, sub
					`FUNC3_ADD : _ALUSel = inst[30] ? `ENUM_OP_SUB : `ENUM_OP_ADD;
					`FUNC3_AND : _ALUSel = `ENUM_OP_AND;
					`FUNC3_OR  : _ALUSel = `ENUM_OP_OR ;
					`FUNC3_XOR : _ALUSel = `ENUM_OP_XOR;
					`FUNC3_SLL : _ALUSel = `ENUM_OP_SLL;
					// srl, sra
					`FUNC3_SRL : _ALUSel = inst[30] ? `ENUM_OP_SRA : `ENUM_OP_SLL;
					`FUNC3_SLT : _ALUSel = `ENUM_OP_SLT;
					`FUNC3_SLTU: _ALUSel = `ENUM_OP_SLTU;
					default: _ALUSel = `ENUM_OP_NONE;
				endcase
			end
			`TYPE_I: begin
				case (func3)
					`FUNC3_ADDI : _ALUSel = `ENUM_OP_ADD;
					`FUNC3_ANDI : _ALUSel = `ENUM_OP_AND;
					`FUNC3_ORI  : _ALUSel = `ENUM_OP_OR ;
					`FUNC3_XORI : _ALUSel = `ENUM_OP_XOR;
					`FUNC3_SLLI : _ALUSel = `ENUM_OP_SLL;
					// `FUNC3_SRLI == `FUNC3_SRAI
					// The 'right shift type' is encoded in bit 30
					`FUNC3_SRLI : _ALUSel = inst[30] ? `ENUM_OP_SRA : `ENUM_OP_SRL;
					`FUNC3_SLTI : _ALUSel = `ENUM_OP_SLT;
					`FUNC3_SLTIU: _ALUSel = `ENUM_OP_SLTU;	
					default _ALUSel = `ENUM_OP_NONE;
				endcase
			end
			`TYPE_I_M: _ALUSel = `ENUM_OP_ADD;
			`TYPE_I_J: _ALUSel = `ENUM_OP_ADD;
			`TYPE_S  : _ALUSel = `ENUM_OP_ADD;
			`TYPE_B  : _ALUSel = `ENUM_OP_ADD;
			`TYPE_J  : _ALUSel = `ENUM_OP_ADD;
			`TYPE_U_A: _ALUSel = `ENUM_OP_ADD;
			`TYPE_U_L: _ALUSel = `ENUM_OP_ADD0;
			`TYPE_E  : _ALUSel = `ENUM_OP_NONE;
			default: _ALUSel = `ENUM_OP_NONE;
		endcase
	end

	// ------------------- ImmSel ----------------------
	reg [(`TYPE_BIT - 1):0] _ImmSel;
	assign ImmSel = _ImmSel;

	always @(*) begin
		case(opcode)
			`TYPE_R  : _ImmSel = `ENUM_TYPE_R;
			`TYPE_I  : _ImmSel = `ENUM_TYPE_I;
			`TYPE_I_M: _ImmSel = `ENUM_TYPE_I_M;
			`TYPE_I_J: _ImmSel = `ENUM_TYPE_I_J;
			`TYPE_S  : _ImmSel = `ENUM_TYPE_S;
			`TYPE_B  : _ImmSel = `ENUM_TYPE_B;
			`TYPE_J  : _ImmSel = `ENUM_TYPE_J;
			`TYPE_U_A: _ImmSel = `ENUM_TYPE_U_A;
			`TYPE_U_L: _ImmSel = `ENUM_TYPE_U_L;
			`TYPE_E  : _ImmSel = `ENUM_TYPE_E;
			default: _ImmSel = `ENUM_TYPE_NONE;
		endcase
	end

	// -------------------- BitSel -----------------------
	reg [(`LS_BIT - 1):0] _BitSel;
	assign BitSel = _BitSel;

	always @(*) begin
		case(opcode)
			`TYPE_I_M: begin
				case (func3)
					`FUNC3_LB : _BitSel = `ENUM_LS_LB;
					`FUNC3_LBU: _BitSel = `ENUM_LS_LBU;
					`FUNC3_LH : _BitSel = `ENUM_LS_LH;
					`FUNC3_LHU: _BitSel = `ENUM_LS_LHU;
					`FUNC3_LW : _BitSel = `ENUM_LS_LW;
					// TODO
					default: _BitSel = `ENUM_LS_NONE;
				endcase
			end
			`TYPE_S  : begin
				case(func3)
					`FUNC3_SB : _BitSel = `ENUM_LS_SB;
					`FUNC3_SH : _BitSel = `ENUM_LS_SH;
					`FUNC3_SW : _BitSel = `ENUM_LS_SW;
					// TODO
					default: _BitSel = `ENUM_LS_NONE;
				endcase
			end
			default: _BitSel = `ENUM_LS_NONE;
		endcase
	end

	// -------------------- ASel -----------------------
	reg _ASel;
	assign ASel = _ASel;

	localparam x_ASel = 1'b0;

	always @(*) begin
		case(opcode)
			`TYPE_R  : _ASel = 1'b0;
			`TYPE_I  : _ASel = 1'b1;
			`TYPE_I_M: _ASel = 1'b1;
			`TYPE_I_J: _ASel = 1'b1;
			`TYPE_S  : _ASel = 1'b1;
			`TYPE_B  : _ASel = 1'b0;
			`TYPE_J  : _ASel = 1'b1;
			`TYPE_U_A: _ASel = 1'b1;
			`TYPE_U_L: _ASel = 1'b1;
			`TYPE_E  : _ASel = x_ASel;
			default: _ASel = x_ASel;
		endcase
	end

	// -------------------- BSel -----------------------
	reg [1:0] _BSel;
	assign BSel = _BSel;

	localparam x_BSel = 2'd3;

	always @(*) begin
		case(opcode)
			`TYPE_R  : _BSel = 2'd0;
			`TYPE_I  : _BSel = 2'd0;
			`TYPE_I_M: _BSel = 2'd1;
			`TYPE_I_J: _BSel = 2'd2;
			// because RegWEn = 1'b0
			`TYPE_S  : _BSel = x_BSel;
			`TYPE_B  : _BSel = x_BSel;
			`TYPE_J  : _BSel = 2'd2;
			`TYPE_U_A: _BSel = 2'd0;
			`TYPE_U_L: _BSel = 2'd0;
			`TYPE_E  : _BSel = x_BSel;
			default: _BSel = x_BSel;
		endcase
	end

	// -------------------- CSel -----------------------
	reg _CSel;
	assign CSel = _CSel;

	localparam x_CSel = 1'b0;

	always @(*) begin
		case(opcode)
			`TYPE_R  : _CSel = 1'b0;
			`TYPE_I  : _CSel = 1'b0;
			`TYPE_I_M: _CSel = 1'b0;
			`TYPE_I_J: _CSel = 1'b0;
			`TYPE_S  : _CSel = 1'b0;
			`TYPE_B  : _CSel = 1'b1;
			`TYPE_J  : _CSel = 1'b1;
			`TYPE_U_A: _CSel = 1'b1;
			`TYPE_U_L: _CSel = x_CSel;
			`TYPE_E  : _CSel = x_CSel;
			default: _CSel = x_CSel;
		endcase
	end

	// -------------------- PCSel -----------------------
	reg _PCSel;
	assign PCSel = _PCSel;

	localparam x_PCSel = 1'b0;

	always @(*) begin
		case(opcode)
			`TYPE_R  : _PCSel = 1'b0;
			`TYPE_I  : _PCSel = 1'b0;
			`TYPE_I_M: _PCSel = 1'b0;
			`TYPE_I_J: _PCSel = 1'b1;
			`TYPE_S  : _PCSel = 1'b0;
			`TYPE_B  : _PCSel = BrJp;
			`TYPE_J  : _PCSel = 1'b1;
			`TYPE_U_A: _PCSel = 1'b0;
			`TYPE_U_L: _PCSel = 1'b0;
			`TYPE_E  : _PCSel = x_PCSel;
			default: _PCSel = x_PCSel;
		endcase
	end

	// ------------------- BrSel ----------------------
	reg [(`BR_BIT - 1):0] _BrSel;
	assign BrSel = _BrSel;

	always @(*) begin
		case(opcode)
			`TYPE_B  : begin
				case(func3)
					`FUNC3_BEQ : _BrSel = `ENUM_BR_EQ  ;
					`FUNC3_BGE : _BrSel = `ENUM_BR_NEQ ;
					`FUNC3_BGEU: _BrSel = `ENUM_BR_LT  ;
					`FUNC3_BLT : _BrSel = `ENUM_BR_GTE ;	
					`FUNC3_BLTU: _BrSel = `ENUM_BR_LTU ;
					`FUNC3_BNE : _BrSel = `ENUM_BR_GTEU;
					default: _BrSel = `ENUM_BR_NONE;
				endcase
			end
			default: _BrSel = `ENUM_BR_NONE;
		endcase
	end

	// ------------------- MemWEn ----------------------
	assign MemWEn = (opcode == `TYPE_S) ? 1'b1 : 1'b0;

	// ------------------- RegWEn ----------------------
	reg _RegWEn;
	assign RegWEn = _RegWEn;

	localparam x_RegWEn = 1'b0;

	// x0 : always 0
	wire IsX0 = (rd == 5'b00000);
	// _RegWEn = x & ~(rd == 5'b00000);
	always @(*) begin
		case(opcode)
			`TYPE_R  : _RegWEn = 1'b1 & ~IsX0;
			`TYPE_I  : _RegWEn = 1'b1 & ~IsX0;
			`TYPE_I_M: _RegWEn = 1'b1 & ~IsX0; 
			`TYPE_I_J: _RegWEn = 1'b1 & ~IsX0; 
			`TYPE_S  : _RegWEn = 1'b0; 
			`TYPE_B  : _RegWEn = 1'b0; 
			`TYPE_J  : _RegWEn = 1'b1 & ~IsX0; 
			`TYPE_U_A: _RegWEn = 1'b1 & ~IsX0; 
			`TYPE_U_L: _RegWEn = 1'b1 & ~IsX0; 
			`TYPE_E  : _RegWEn = 1'b0;
			default: _RegWEn = x_RegWEn;
		endcase
	end

	// ------------------- EndSim ----------------------
	// TODO => DPI-C
	assign EndSim = (inst == `INST_EBREAK);

/* ------------ TEMPLATE ------------ */
//	always @(*) begin
//		case(opcode)
//			`TYPE_R  : /* TODO */;
//			`TYPE_I  : /* TODO */;
//			`TYPE_I_M: /* TODO */;
//			`TYPE_I_J: /* TODO */;
//			`TYPE_S  : /* TODO */;
//			`TYPE_B  : /* TODO */;
//			`TYPE_J  : /* TODO */;
//			`TYPE_U_A: /* TODO */;
//			`TYPE_U_L: /* TODO */;
//			`TYPE_E  : /* TODO */;
//			default: /* TODO */;
//		endcase
//	end

endmodule
