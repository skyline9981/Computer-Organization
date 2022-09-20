module Pipeline_CPU( clk_i, rst_n );

//I/O port
input         		 clk_i;
input         		 rst_n;

//Internal Signles
wire [4:0]ReadReg1;
wire [4:0]ReadReg2;
wire [4:0]toshifter;



/**** IF stage ****/
wire [31:0]pc_out;
wire [31:0]pc_next;
wire [31:0]pc_back;
wire [31:0]instr_o;

wire [31:0]if_id_pc_next;
wire [31:0]if_id_instr_o;
/**** ID stage ****/
wire [1:0]regdst;
wire regwrite;
wire branch;
wire ALUSrc;
wire memread;
wire memwrite;
wire [2:0]ALU_op;
wire [1:0]memtoreg;
wire [31:0]RSdata;
wire [31:0]RTdata;
wire [31:0]extend;

wire [1:0]ID_EX_regdst;
wire ID_EX_regwrite;
wire ID_EX_branch;
wire ID_EX_ALUSrc;
wire ID_EX_zero;
wire ID_EX_memread;
wire ID_EX_memwrite;
wire [2:0]ID_EX_ALU_op;
wire [1:0]ID_EX_memtoreg;
wire [31:0]ID_EX_RSdata;
wire [31:0]ID_EX_RTdata;
wire [31:0]ID_EX_extend;
wire [31:0]ID_EX_pc_next;
wire [31:0]ID_EX_instr_o;

/**** EX stage ****/
wire [31:0]pc_cal;
wire [31:0]result;
wire zero;
wire [31:0]muxalu;
wire [31:0]extend2;
wire [3:0]ALU_control;
wire [4:0]WriteReg1;

wire EX_MEM_regwrite;
wire EX_MEM_branch;
wire EX_MEM_memread;
wire EX_MEM_memwrite;
wire [1:0]EX_MEM_memtoreg;
wire [31:0]EX_MEM_pc_cal;
wire EX_MEM_zero;
wire [31:0]EX_MEM_result;
wire [31:0]EX_MEM_RTdata;
wire [4:0]EX_MEM_WriteReg1;
/**** MEM stage ****/
wire [31:0]redmonster;

wire MEM_WB_regwrite;
wire [1:0]MEM_WB_memtoreg;
wire [4:0]MEM_WB_WriteReg1;
wire [31:0]MEM_WB_result;
wire [31:0]MEM_WB_redmonster;
/**** WB stage ****/
wire [31:0]regresult;



/****************************************
Instantiate modules
****************************************/
//Instantiate the components in IF stage
Mux2to1 #(.size(32)) Mux0(
        .data0_i(pc_next),
        .data1_i(EX_MEM_pc_cal),
        .select_i(EX_MEM_zero && EX_MEM_branch),
        .data_o(pc_back)
	);

Program_Counter PC(
        .clk_i(clk_i),      
	.rst_n (rst_n),     
	.pc_in_i(pc_back) ,   
	.pc_out_o(pc_out) 
	);

Instr_Memory IM(
     	.pc_addr_i(pc_out),
     	.instr_o(instr_o)
	);
			
Adder Add_pc(
     	.src1_i(pc_out),
     	.src2_i(4),
     	.sum_o(pc_next)
	);

		
Pipe_Reg #(.size(64)) IF_ID(       //N is the total length of input/output
	.clk_i(clk_i),
	.rst_n(rst_n),
	.data_i({pc_next,instr_o}),
	.data_o({if_id_pc_next,if_id_instr_o})
	);


//Instantiate the components in ID stage
Reg_File RF(
        .clk_i(clk_i),      
	.rst_n(rst_n) ,     
        .RSaddr_i(if_id_instr_o[25:21]) ,  
        .RTaddr_i(if_id_instr_o[20:16]) ,  
        .RDaddr_i(MEM_WB_WriteReg1) ,  
        .RDdata_i(regresult)  , 
        .RegWrite_i (MEM_WB_regwrite),
        .RSdata_o(RSdata) ,  
        .RTdata_o(RTdata)   
	);

Decoder Control(
        .instr_op_i(if_id_instr_o[31:26]), 
	.RegWrite_o(regwrite), 
	.ALUOp_o(ALU_op),   
	.ALUSrc_o(ALUSrc),   
	.RegDst_o(regdst),   
	.Branch_o(branch),
        .MemRead_o(memread),
	.MemWrite_o(memwrite),
	.MemtoReg_o(memtoreg)
	);

Sign_Extend Sign_Extend(
        .data_i(if_id_instr_o[15:0]),
        .data_o(extend)
	);	

Pipe_Reg #(.size(172)) ID_EX(
        .clk_i(clk_i),
        .rst_n(rst_n),
        .data_i({regwrite,ALU_op,ALUSrc,regdst,branch,memread,memwrite,memtoreg,extend,
                RSdata,RTdata,if_id_pc_next,if_id_instr_o}),
        .data_o({ID_EX_regwrite,ID_EX_ALU_op,ID_EX_ALUSrc,ID_EX_regdst,ID_EX_branch,ID_EX_memread,ID_EX_memwrite,ID_EX_memtoreg
                ,ID_EX_extend,ID_EX_RSdata,ID_EX_RTdata,ID_EX_pc_next,ID_EX_instr_o})
	);

//Instantiate the components in EX stage	   
Shifter Shift(
        .sftSrc(ID_EX_extend),
        .leftRight(ALU_control[0]),
        .shamt(toshifter),
        .result(extend2)
	);

Mux2to1 #(.size(32)) Mux_ALUSrc(
        .data0_i(ID_EX_RTdata),
        .data1_i(ID_EX_extend),
        .select_i(ID_EX_ALUSrc),
        .data_o(muxalu)
	);

ALU_Ctrl ALU_Control(
        .funct_i(ID_EX_instr_o[5:0]),   
        .ALUOp_i(ID_EX_ALU_op),   
        .ALU_operation_o(ALU_control) 
	);

ALU ALU(
        .aluSrc1(ID_EX_RSdata),
	.aluSrc2(muxalu),
	.ALUctl(ALU_control),
	.ALUOut(result),
	.Zero(zero)
	);
	
Mux3to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(ID_EX_instr_o[20:16]),
        .data1_i(ID_EX_instr_o[15:11]),
        .data2_i(5'd31),
        .select_i(ID_EX_regdst),
        .data_o(WriteReg1)
        );	

Adder Add_pc_branch(
        .src1_i(ID_EX_pc_next),     
	.src2_i(extend2),     
	.sum_o(pc_cal)   
	);

Pipe_Reg #(.size(108)) EX_MEM(
        .clk_i(clk_i),
        .rst_n(rst_n),
        .data_i({ID_EX_regwrite,ID_EX_branch,ID_EX_memread,ID_EX_memwrite,ID_EX_memtoreg,pc_cal,zero,
                result,ID_EX_RTdata,WriteReg1}),
        .data_o({EX_MEM_regwrite,EX_MEM_branch,EX_MEM_memread,EX_MEM_memwrite,EX_MEM_memtoreg,
                EX_MEM_pc_cal,EX_MEM_zero,EX_MEM_result,EX_MEM_RTdata,EX_MEM_WriteReg1})
	);

//Instantiate the components in MEM stage
Data_Memory DM(
        .clk_i(clk_i),
	.addr_i(EX_MEM_result),
	.data_i(EX_MEM_RTdata),
	.MemRead_i(EX_MEM_memread),
	.MemWrite_i(EX_MEM_memwrite),
	.data_o(redmonster)
	);

Pipe_Reg #(.size(72)) MEM_WB(
        .clk_i(clk_i),
        .rst_n(rst_n),
        .data_i({EX_MEM_regwrite,EX_MEM_memtoreg,EX_MEM_WriteReg1,EX_MEM_result,redmonster}),
        .data_o({MEM_WB_regwrite,MEM_WB_memtoreg,MEM_WB_WriteReg1,MEM_WB_result,MEM_WB_redmonster})
	);


//Instantiate the components in WB stage
Mux3to1 #(.size(32)) Mux3(
        .data0_i(MEM_WB_result),
        .data1_i(MEM_WB_redmonster),
        .data2_i(pc_next),
        .select_i(MEM_WB_memtoreg),
        .data_o(regresult)
	);


endmodule