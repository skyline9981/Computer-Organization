module Simple_Single_CPU( clk_i, rst_n );

//I/O port
input         		 clk_i;
input         		 rst_n;

//Internal Signles
wire 		[32-1:0] pc_in_i, pc_out_o, writeData, instr_o, readData1, readData2;
wire 		[32-1:0] data_o_Extend, data_o_Zero, Mux_out_ALU, data_o_ALU, shifter_result;
wire 				 RegDst, RegWrite, ALUSrc, sh;
wire 		[5-1:0]  addr_to_write, Shiftnum; 
wire 		[4-1:0]  ALU_operation;
wire 		[3-1:0]  ALUOp;
wire 		[2-1:0]  FURslt;

//modules
Program_Counter PC(
        .clk_i(clk_i),      
	    .rst_n(rst_n),     
	    .pc_in_i(pc_in_i) ,   
	    .pc_out_o(pc_out_o) 
	    );
	
Adder Adder1(
        .src1_i(pc_out_o),     
	    .src2_i(32'd4),
	    .sum_o(pc_in_i)    
	    );
	
Instr_Memory IM(
        .pc_addr_i(pc_out_o),  
	    .instr_o(instr_o)    
	    );

Mux2to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(instr_o[20:16]),
        .data1_i(instr_o[15:11]),
        .select_i(RegDst),
        .data_o(addr_to_write)
        );	
		
Reg_File RF(
        .clk_i(clk_i),      
	    .rst_n(rst_n) ,     
        .RSaddr_i(instr_o[25:21]) ,  
        .RTaddr_i(instr_o[20:16]) ,  
        .RDaddr_i(addr_to_write) ,  
        .RDdata_i(writeData)  , 
        .RegWrite_i(RegWrite),
        .RSdata_o(readData1) ,  
        .RTdata_o(readData2)   
        );
	
Decoder Decoder(
        .instr_op_i(instr_o[31:26]), 
	    .RegWrite_o(RegWrite), 
	    .ALUOp_o(ALUOp),   
	    .ALUSrc_o(ALUSrc),   
	    .RegDst_o(RegDst)   
		);

ALU_Ctrl AC(
        .funct_i(instr_o[5:0]),   
        .ALUOp_i(ALUOp),   
        .ALU_operation_o(ALU_operation),
		.FURslt_o(FURslt),
		.ShifterV_o(sh)
        );
	
Sign_Extend SE(
        .data_i(instr_o[15:0]),
        .data_o(data_o_Extend)
        );

Zero_Filled ZF(
        .data_i(instr_o[15:0]),
        .data_o(data_o_Zero)
        );
		
Mux2to1 #(.size(32)) ALU_src2Src(
        .data0_i(readData2),
        .data1_i(data_o_Extend),
        .select_i(ALUSrc),
        .data_o(Mux_out_ALU)
        );	
		
ALU ALU(
		.ALUctl(ALU_operation),
		.aluSrc1(readData1),
	    .aluSrc2(Mux_out_ALU),
		.ALUOut(data_o_ALU),
		.Zero()
	    );
		
Shifter shifter( 
		.result(shifter_result), 
		.leftRight(ALU_operation[0]),
		.shamt(Shiftnum),
		.sftSrc(Mux_out_ALU) 
		);
		
Mux3to1 #(.size(32)) RDdata_Source(
        .data0_i(data_o_ALU),
        .data1_i(shifter_result),
		.data2_i(data_o_Zero),
        .select_i(FURslt),
        .data_o(writeData)
        );	

Mux2to1 #(.size(5)) ShiftVariable(
		.data0_i(instr_o[10:6]),
		.data1_i(readData1[4:0]),
		.select_i(sh),
		.data_o(Shiftnum)
		);		

endmodule