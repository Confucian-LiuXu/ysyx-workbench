/* DESCRIPTION:
the file containts the global macro definition */

// the width of an integer register in bits (32 / 64)
`define RISCV_XLEN 64
// 2^{RISCV_XLEN_EXP} = RISCV_XLEN
`define RISCV_XLEN_EXP 6
// integer register number
`define RISCV_REG_NUM 32
// the start address of code segment (ABI convention)
`define RISCV_PC_RST_VAL `RISCV_XLEN'h80000000

// ----------------------------------- opcode  ---------------------------------------
// RV32I ; [RV32M] ; [RV64I] ; [RV64M]
// TYPE_T[_SUFFIX] : different SUFFIX of the same TYPE_T => different 'opcode'

// add, sub, and, or, xor, sll, srl, sra, slt, sltu ; [div, divu, mul, mulh, mulhsu, mulhu, rem, remu] ; [...] ;
`define TYPE_R		7'b011_0011
// addi, andi, ori, (slli, srli, srai), xori, slti, sltiu ; [] ; [...]
`define TYPE_I		7'b001_0011
// lb, lbu, lh, lhu, lw ; [] ; [...]
`define TYPE_I_M	7'b000_0011
// jalr
`define TYPE_I_J	7'b110_0111
// sb, sh, sw ; [] ; [...]
`define TYPE_S		7'b010_0011
// beq, bge, bgeu, blt, bltu, bne ; [] ; [...]
`define TYPE_B		7'b110_0011
// jal
`define TYPE_J		7'b110_1111
// auipc
`define TYPE_U_A	7'b001_0111
// lui
`define TYPE_U_L	7'b011_0111
// ebreak, ecall
`define TYPE_E		7'b111_0011
// TODO RV64I, RVxxM

// ------------------------------------------ ImmSel ---------------------------------------------
// total 10 => use `TYPE_BIT bits to display 'ImmSel'

`define TYPE_BIT 4

`define	ENUM_TYPE_R			`TYPE_BIT'd0
`define ENUM_TYPE_I			`TYPE_BIT'd1
`define ENUM_TYPE_I_M		`TYPE_BIT'd2
`define ENUM_TYPE_I_J		`TYPE_BIT'd3
`define ENUM_TYPE_S			`TYPE_BIT'd4
`define ENUM_TYPE_B			`TYPE_BIT'd5
`define ENUM_TYPE_J			`TYPE_BIT'd6
`define ENUM_TYPE_U_A		`TYPE_BIT'd7
`define ENUM_TYPE_U_L		`TYPE_BIT'd8
`define ENUM_TYPE_E			`TYPE_BIT'd9

`define ENUM_TYPE_NONE		`TYPE_BIT'd10
// TODO RV64I, RVxxM

// ------------------------------------------ ALUSel ---------------------------------------------
// total 10 (add, sub, and, or, xor, sll, srl, sra, slt, sltu) ==> use `OP_BIT bits to display 'ALUSel'

`define OP_BIT 4

`define ENUM_OP_ADD  `OP_BIT'd0
`define ENUM_OP_SUB  `OP_BIT'd1
`define ENUM_OP_AND  `OP_BIT'd2
`define ENUM_OP_OR   `OP_BIT'd3
`define ENUM_OP_XOR  `OP_BIT'd4
`define ENUM_OP_SLL  `OP_BIT'd5
`define ENUM_OP_SRL  `OP_BIT'd6
`define ENUM_OP_SRA  `OP_BIT'd7
`define ENUM_OP_SLT  `OP_BIT'd8
`define ENUM_OP_SLTU `OP_BIT'd9
// lui
`define ENUM_OP_ADD0 `OP_BIT'd10
// if most instructions => `OP_BIT'd0
`define ENUM_OP_NONE `OP_BIT'd11

// func3(R)
`define FUNC3_ADD	3'b000
`define FUNC3_SUB  	3'b000
`define FUNC3_AND  	3'b111
`define FUNC3_OR   	3'b110
`define FUNC3_XOR  	3'b100
`define FUNC3_SLL  	3'b001
`define FUNC3_SRL  	3'b101
`define FUNC3_SRA  	3'b101
`define FUNC3_SLT  	3'b010
`define FUNC3_SLTU 	3'b011
// func7(R)
`define FUNC7_ADD	7'b0000000
`define FUNC7_SUB  	7'b0100000
`define FUNC7_AND  	7'b0000000
`define FUNC7_OR   	7'b0000000
`define FUNC7_XOR  	7'b0000000
`define FUNC7_SLL  	7'b0000000
`define FUNC7_SRL  	7'b0000000
`define FUNC7_SRA  	7'b0100000
`define FUNC7_SLT  	7'b0000000
`define FUNC7_SLTU 	7'b0000000

// func3(I)
`define FUNC3_ADDI	`FUNC3_ADD
// no 'subi' instruction
`define FUNC3_ANDI 	`FUNC3_AND
`define FUNC3_ORI  	`FUNC3_OR
`define FUNC3_XORI 	`FUNC3_XOR
`define FUNC3_SLLI	`FUNC3_SLL
`define FUNC3_SRLI	`FUNC3_SRL
`define FUNC3_SRAI	`FUNC3_SRA
`define FUNC3_SLTI 	`FUNC3_SLT
`define FUNC3_SLTIU	`FUNC3_SLTU

// ------------------------------------------ BitSel ---------------------------------------------

`define LS_BIT	4

// load
`define ENUM_LS_LB		`LS_BIT'd0
`define ENUM_LS_LBU		`LS_BIT'd1
`define ENUM_LS_LH		`LS_BIT'd2
`define ENUM_LS_LHU		`LS_BIT'd3
`define ENUM_LS_LW		`LS_BIT'd4
// store
`define ENUM_LS_SB		`LS_BIT'd5
`define ENUM_LS_SH		`LS_BIT'd6
`define ENUM_LS_SW		`LS_BIT'd7
// default
`define ENUM_LS_NONE	`LS_BIT'd8

// load
`define FUNC3_LB	3'b000
`define FUNC3_LBU	3'b100
`define FUNC3_LH	3'b001
`define FUNC3_LHU	3'b101
`define FUNC3_LW	3'b010
// store
`define FUNC3_SB	`FUNC3_LB
`define FUNC3_SH	`FUNC3_LH
`define FUNC3_SW	`FUNC3_LW


// ------------------------------------------ BitSel ---------------------------------------------
`define BR_BIT 3

`define ENUM_BR_EQ		`BR_BIT'd0
`define ENUM_BR_NEQ		`BR_BIT'd1
`define ENUM_BR_LT		`BR_BIT'd2
`define ENUM_BR_GTE		`BR_BIT'd3
`define ENUM_BR_LTU		`BR_BIT'd4
`define ENUM_BR_GTEU	`BR_BIT'd5

`define ENUM_BR_NONE	`BR_BIT'd6

`define FUNC3_BEQ		3'b000
`define FUNC3_BGE		3'b101
`define FUNC3_BGEU		3'b111
`define FUNC3_BLT		3'b100
`define FUNC3_BLTU		3'b110
`define FUNC3_BNE		3'b001


// ------------------------------------------ BitSel ---------------------------------------------
`define INST_EBREAK 32'b000000000001_00000_000_00000_1110011
