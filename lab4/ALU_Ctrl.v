module ALU_Ctrl( funct_i, ALUOp_i, ALU_operation_o, FURslt_o, ShiftV_o);

//I/O ports 
input      [6-1:0] funct_i;
input      [3-1:0] ALUOp_i;

output     [4-1:0] ALU_operation_o;  
output     [2-1:0] FURslt_o;
output		   	   ShiftV_o;
     
//Internal Signals
wire		[4-1:0] ALU_operation_o;
wire		[2-1:0] FURslt_o;
wire			    ShiftV_o;	

//Main function
assign ALU_operation_o = ({ALUOp_i,funct_i} == 9'b010_010011 || ALUOp_i == 3'b011) ? 4'b0010 : //add addi
			 		      ({ALUOp_i,funct_i} == 9'b010_010001) ? 4'b0110 :  //sub
			 		      ({ALUOp_i,funct_i} == 9'b010_010100) ? 4'b0000 :  //and
			 		      ({ALUOp_i,funct_i} == 9'b010_010110) ? 4'b0001 :  //or 
			  		      ({ALUOp_i,funct_i} == 9'b010_010101) ? 4'b1100 :  //nor 
			 		      ({ALUOp_i,funct_i} == 9'b010_110000) ? 4'b0111 :  //slt
			 		      ({ALUOp_i,funct_i} == 9'b010_000000) ? 4'b0000 :  //sll
			 		      ({ALUOp_i,funct_i} == 9'b010_000010) ? 4'b0001 :  //srl
			 		      ({ALUOp_i,funct_i} == 9'b010_000110) ? 4'b0010 :  //sllv
					      ({ALUOp_i,funct_i} == 9'b010_000100) ? 4'b0011 :  //srlv 
					      (ALUOp_i == 3'b001) ? 6 :							//beq
						  (ALUOp_i == 3'b110) ? 6 :							//bne
						  (ALUOp_i == 3'b000) ? 2 : 0;						//lw sw 

assign FURslt_o =  ({ALUOp_i,funct_i} == 9'b010_010011 || ALUOp_i == 3'b011) ? 2'b00 : //add addi
					({ALUOp_i,funct_i} == 9'b010_010001) ? 2'b00 :  //sub
					({ALUOp_i,funct_i} == 9'b010_010100) ? 2'b00 :  //and
					({ALUOp_i,funct_i} == 9'b010_010110) ? 2'b00 :  //or 
					({ALUOp_i,funct_i} == 9'b010_010101) ? 2'b00 :  //nor 
			 		({ALUOp_i,funct_i} == 9'b010_110000) ? 2'b00 :  //slt
			 		({ALUOp_i,funct_i} == 9'b010_000000) ? 2'b01 :  //sll
					({ALUOp_i,funct_i} == 9'b010_000010) ? 2'b01 :  //srl
					({ALUOp_i,funct_i} == 9'b010_000110) ? 2'b01 :  //sllv
					({ALUOp_i,funct_i} == 9'b010_000100) ? 2'b01 : 2'b00;  //srlv others(lw & sw)

assign ShifterV_o = ({ALUOp_i,funct_i} == 9'b001_000110) ? 1 : 		//SLLV
					({ALUOp_i,funct_i} == 9'b001_000100) ? 1 : 0; 	//SRLV	

endmodule     
