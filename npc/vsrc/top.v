/* verilator lint_off UNUSEDSIGNAL */
`include "const.v"
module top(
	input clk,
	input rst
);
	wire [31:0] inst;
	wire BrJp;
	wire [(`OP_BIT   - 1):0] ALUSel;
	wire [(`TYPE_BIT - 1):0] ImmSel;
	wire [(`LS_BIT   - 1):0] BitSel;
	wire [(`BR_BIT   - 1):0]  BrSel;
	wire ASel;
	wire [1:0] BSel;
	wire PCSel;
	wire CSel;
	wire MemWEn;
	wire RegWEn;
	wire EndSim; 

	CU CU_U0(
		.inst(inst),
		.BrJp(BrJp),
		.ALUSel(ALUSel),
		.ImmSel(ImmSel),
		.BitSel(BitSel),
		.BrSel(BrSel),
		.ASel(ASel),
		.BSel(BSel),
		.CSel(CSel),
		.PCSel(PCSel),
		.MemWEn(MemWEn),
		.RegWEn(RegWEn),
		.EndSim(EndSim)
	);

	wire [(`RISCV_XLEN - 1):0] pc_i;
	wire [(`RISCV_XLEN - 1):0] pc_o;
	PC PC_U0(
		.clk(clk), 
		.rst(rst), 
		.WEn(1'b1), 
		.din(pc_i), 
		.dout(pc_o)
	);
	
	IMEM IMEM_U0(
		.addr(pc_o),
		.inst(inst)
	);

	wire [(`RISCV_XLEN - 1):0] dataW;
	wire [(`RISCV_XLEN - 1):0] data1;
	wire [(`RISCV_XLEN - 1):0] data2;
	RegFile RegFile_U0(
		.clk(clk),
		.rst(rst),
		.RegWEn(RegWEn),
		.rs2(inst[24:20]),
		.rs1(inst[19:15]),
		.rd(inst[11:7]),
		.dataW(dataW),
		.data1(data1),
		.data2(data2)
	);

	wire [(`RISCV_XLEN - 1):0] imm;
	ImmGen ImmGen_U0(
		.inst(inst),
		.ImmSel(ImmSel),
		.imm(imm)
	);


	BranchComp BranchComp_U0(
		.A(data1),
		.B(data2),
		.BrSel(BrSel),
		.BrJp(BrJp)
	);

	wire [(`RISCV_XLEN - 1):0] A;
	Mux21 Mux21_U0(
		.x(data1),
		.y(pc_o),
		.s(CSel),
		.o(A)
	);

	wire [(`RISCV_XLEN - 1):0] B;
	Mux21 Mux21_U1(
		.x(data2),
		.y(imm),
		.s(ASel),
		.o(B)
	);

	wire [(`RISCV_XLEN - 1):0] alu_o;
	ALU ALU_U0(
		.A(A),
		.B(B),
		.ALUSel(ALUSel),
		.o(alu_o)
	);

	wire [(`RISCV_XLEN - 1):0] dataR;
	DMEM DMEM_U0(
		.clk(clk),
		.rst(rst),
		.MemWEn(MemWEn),
		.BitSel(BitSel),
		.addr(alu_o),
		.dataW(data2),
		.dataR(dataR)
	);

	wire [(`RISCV_XLEN - 1):0] pc_plus_4 = pc_i + 4;
	Mux31 Mux31_U0(
		.in0(alu_o),
		.in1(dataR),
		.in2(pc_plus_4),
		.s(BSel),
		.o(dataW)
	);

	Mux21 Mux21_U2(
		.x(pc_plus_4),
		.y(alu_o),
		.s(PCSel),
		.o(pc_i)
	);

endmodule
