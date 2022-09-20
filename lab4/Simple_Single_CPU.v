module Simple_Single_CPU( clk_i, rst_n );

//I/O port
input            clk_i;
input            rst_n;

//Internal Signles
wire    [32-1:0] pc_adder1_o, pc_to_ins, writeData, instr_o, readData1, readData2, instr_ext, instr_ze, alu_mux, ALU_result, shifter_res;
wire    [32-1:0] pc_result, pc_adder2_o, pc_for_branch;
wire    [32-1:0] result_source, mem_output; 
wire    [5-1:0]  instr_to_write, toShifter, RTaddr; 
wire    [4-1:0]  ALU_operation;
wire    [3-1:0]  ALUOp;
wire    [2-1:0]  FURslt, RegDst, MemtoReg, Jump;
wire             MemWrite, MemRead, Branch, BranchType, zeroslt, zero;
wire             RegWrite, ALUSrc, shvamt, overflow, Blt, Bgez, less, notless;

//modules
Program_Counter PC(
        .clk_i(clk_i),      
	    .rst_n(rst_n),     
	    .pc_in_i(pc_result),   
	    .pc_out_o(pc_to_ins) 
	    );
	
Adder Adder1(
        .src1_i(pc_to_ins),     
	    .src2_i(32'd4),
	    .sum_o(pc_adder1_o)    
	    );
	
Instr_Memory IM(
        .pc_addr_i(pc_to_ins),  
	    .instr_o(instr_o)    
	    );

Mux3to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(instr_o[20:16]),
        .data1_i(instr_o[15:11]),
        .data2_i(5'd31),
        .select_i(RegDst),
        .data_o(instr_to_write)
        );

Mux2to1 #(.size(5)) Mux_Bgez(
        .data0_i(instr_o[20:16]),
        .data1_i(5'b0),
        .select_i(Bgez),
        .data_o(RTaddr)
        );
		
Reg_File RF(
        .clk_i(clk_i),      
        .rst_n(rst_n) ,     
        .RSaddr_i(instr_o[25:21]) ,  
        .RTaddr_i(RTaddr) ,  
        .RDaddr_i(instr_to_write) ,  
        .RDdata_i(writeData)  , 
        .RegWrite_i(RegWrite),
        .RSdata_o(readData1) ,  
        .RTdata_o(readData2)   
        );
	
Decoder Decoder(
        .instr_op_i(instr_o[31:26]), 
        .funct_i(instr_o[5:0]),
        .RegWrite_o(RegWrite), 
        .ALUOp_o(ALUOp),   
        .ALUSrc_o(ALUSrc),   
        .RegDst_o(RegDst),
        .MemWrite_o(MemWrite),
        .MemRead_o(MemRead),
        .MemtoReg_o(MemtoReg),
        .Branch_o(Branch),
        .BranchType_o(BranchType),
        .Jump_o(Jump),
        .Blt_o(Blt),
        .Bgez_o(Bgez)   
	);

ALU_Ctrl AC(
        .funct_i(instr_o[5:0]),   
        .ALUOp_i(ALUOp),   
        .ALU_operation_o(ALU_operation),
        .FURslt_o(FURslt),
        .ShiftV_o(shvamt)
        );
	
Sign_Extend SE(
        .data_i(instr_o[15:0]),
        .data_o(instr_ext)
        );

Zero_Filled ZF(
        .data_i(instr_o[15:0]),
        .data_o(instr_ze)
        );
		
Mux2to1 #(.size(32)) ALU_src2Src(
        .data0_i(readData2),
        .data1_i(instr_ext),
        .select_i(ALUSrc),
        .data_o(alu_mux)
        );	

ALU ALU(
    	.aluSrc1(readData1),
    	.aluSrc2(alu_mux),
    	.ALU_operation_i(ALU_operation),
    	.result(ALU_result),
    	.zero(zero),
    	.overflow(overflow),
        .less(less),
        .notless(notless)
    	);
		
Shifter shifter( 
    	.result(shifter_res), 
    	.leftRight(ALU_operation[0]),
    	.shamt(toShifter),
    	.sftSrc(alu_mux) 
    	);
		
Mux3to1 #(.size(32)) RDdata_Source(
        .data0_i(ALU_result),
        .data1_i(shifter_res),
	.data2_i(instr_ze),
        .select_i(FURslt),
        .data_o(result_source)
        );

Mux2to1 #(.size(5)) shiftvariable(
        .data0_i(instr_o[10:6]),
        .data1_i(readData1[4:0]),
        .select_i(shvamt),
        .data_o(toShifter)
        );

Data_Memory DM(
        .clk_i(clk_i),
        .addr_i(result_source),
        .data_i(readData2),
        .MemRead_i(MemRead),
        .MemWrite_i(MemWrite),
        .data_o(mem_output)
        );
        
Mux3to1 #(.size(32)) Mem_WD(
        .data0_i(result_source),
        .data1_i(mem_output),
        .data2_i(pc_adder1_o),
        .select_i(MemtoReg),
        .data_o(writeData)
        );
        
Mux2to1 #(.size(1)) Zero_mux(
        .data0_i(zero),
        .data1_i(!zero),
        .select_i(BranchType),
        .data_o(zero_slt)
        );

Adder Adder2(
        .src1_i(pc_adder1_o),     
        .src2_i(instr_ext << 2),
        .sum_o(pc_adder2_o)    
        );

Mux2to1 #(.size(32)) Branch_mux(
        .data0_i(pc_adder1_o),
        .data1_i(pc_adder2_o),
        .select_i(Branch & (zero_slt | (notless & Bgez) | (less & Blt))),
        .data_o(pc_for_branch)
        );
        
Mux3to1 #(.size(32)) Jump_mux(
        .data0_i(pc_for_branch),
        .data1_i({pc_adder1_o[31:28],{instr_o[25:0],2'b0}}),
        .data2_i(readData1),
        .select_i(Jump),
        .data_o(pc_result)
        );			

endmodule
