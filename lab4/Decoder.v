module Decoder( instr_op_i, funct_i, RegWrite_o,ALUOp_o, ALUSrc_o, RegDst_o , MemWrite_o, MemRead_o, MemtoReg_o, Branch_o, BranchType_o, Jump_o, Blt_o, Bgez_o);
     
//I/O ports
input	[6-1:0] 	instr_op_i;
input	[6-1:0]		funct_i;

output				RegWrite_o;
output	[3-1:0] 	ALUOp_o;
output				ALUSrc_o;
output	[2-1:0]		RegDst_o;

//Lab3
output 				MemWrite_o;
output 				MemRead_o;
output 	[2-1:0]		MemtoReg_o;
output 				Branch_o;
output 				BranchType_o;
output 	[2-1:0]		Jump_o;
output 				Blt_o;
output 				Bgez_o;
 
//Internal Signals
wire	[3-1:0] 	ALUOp_o;
wire				ALUSrc_o;
wire				RegWrite_o;
wire	[2-1:0]		RegDst_o;

wire 				Blt_o;
wire 				Bgez_o;
wire 				MemWrite_o;
wire 				MemRead_o;
wire 	[2-1:0] 	MemtoReg_o;
wire 				Branch_o;
wire 				BranchType_o;
wire 	[2-1:0] 	Jump_o;  

//Main function
assign RegDst_o = 	(instr_op_i == 6'b000000) ? 1 :					//R-type
					(instr_op_i == 6'b000011) ? 2 :					//Jal
					(instr_op_i == 6'b001000) ? 0 : 0;				//I-type

assign RegWrite_o = (instr_op_i == 6'b101101) ? 0 :					//sw
					(instr_op_i == 6'b000010) ? 0 :					//J
					(instr_op_i == 6'b001010) ? 0 :					//beq
					({instr_op_i, funct_i} == 12'b000000001000) ? 0:	//Jr
					(instr_op_i == 6'b001011) ? 0 : 				//bne 
					(instr_op_i == 6'b001110) ? 0 :					//blt
					(instr_op_i == 6'b001100) ? 0 :					//bnez
					(instr_op_i == 6'b001101) ? 0 : 1;				//bgez-- other instr in given table need to write

assign ALUSrc_o = 	(instr_op_i == 6'b000000) ? 0 :					//R-type
					(instr_op_i == 6'b001010) ? 0 :					//beq
					(instr_op_i == 6'b001011) ? 0 :					//bne
					(instr_op_i == 6'b001110) ? 0 :					//blt
					(instr_op_i == 6'b001101) ? 0 :					//bgez
					(instr_op_i == 6'b001100) ? 0 :					//bnez
					(instr_op_i == 6'b001000) ? 1 : 1;				//I-type

assign ALUOp_o = 	(instr_op_i == 6'b000000) ? 3'b010 :			//R-type
					(instr_op_i == 6'b101100) ? 3'b000 :			//lw
					(instr_op_i == 6'b101101) ? 3'b000 :			//sw
					(instr_op_i == 6'b001010) ? 3'b001 : 			//beq
					(instr_op_i == 6'b001011) ? 3'b110 :			//bne
					(instr_op_i == 6'b001110) ? 3'b110 :			//blt
					(instr_op_i == 6'b001101) ? 3'b110 :			//bgez
					(instr_op_i == 6'b001100) ? 3'b110 :			//bnez
					(instr_op_i == 6'b001000) ? 3'b011 : 3'b011;	//ADDI : LUI

assign Blt_o = 		(instr_op_i == 6'b001110) ? 1 : 0;				//blt

assign Bgez_o = 	(instr_op_i == 6'b001101) ? 1 : 0;				//bgez

assign MemWrite_o = (instr_op_i == 6'b101100) ? 0 :					//sw
					(instr_op_i == 6'b101101) ? 1 : 0;

assign MemRead_o = 	(instr_op_i == 6'b101100) ? 1 :					//lw
					(instr_op_i == 6'b101101) ? 0 : 0; 

assign MemtoReg_o = (instr_op_i == 6'b101100) ? 1 :					//lw
					(instr_op_i == 6'b000011) ? 2 :					//Jal
					(instr_op_i == 6'b101101) ? 0 : 0;				//else
					
assign Branch_o = 	(instr_op_i == 6'b001010) ? 1 : 				//beq
					(instr_op_i == 6'b001011) ? 1 :					//bne
					(instr_op_i == 6'b001110) ? 1 :					//blt
					(instr_op_i == 6'b001100) ? 1 :					//bnez
					(instr_op_i == 6'b001101) ? 1 : 0;				//bgez
					
assign BranchType_o = (instr_op_i == 6'b001010) ? 0 : 				//beq
					(instr_op_i == 6'b001011) ? 1 : 				//bne
					(instr_op_i == 6'b001100) ? 1 : 0;				//bnez

assign Jump_o = 	(instr_op_i == 6'b000010) ? 1 :					//J
					({instr_op_i, funct_i} == 12'b000000001000) ? 2:	//Jr
					(instr_op_i == 6'b000011) ? 1 : 0; 				//Jal

endmodule