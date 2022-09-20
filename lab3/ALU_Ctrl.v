module ALU_Ctrl( funct_i, ALUOp_i, ALU_operation_o, FURslt_o, ShifterV_o );

//I/O ports 
input      [6-1:0] funct_i;
input      [3-1:0] ALUOp_i;

output     [4-1:0] ALU_operation_o;  
output     [2-1:0] FURslt_o;
output	   		   ShifterV_o;
     
//Internal Signals
wire		[4-1:0] ALU_operation_o;
wire		[2-1:0] FURslt_o;
wire        	    ShifterV_o;

//Main function
/*your code here*/
assign FURslt_o = ({ALUOp_i,funct_i} == 9'b001_000000) ? 1 : 	//sll
			({ALUOp_i,funct_i} == 9'b001_000010) ? 1 :			//srl 
			({ALUOp_i,funct_i} == 9'b001_000110) ? 1 :  		//sllv
			({ALUOp_i,funct_i} == 9'b001_000100) ? 1 : 0;		//srlv //else

assign ALU_operation_o = ({ALUOp_i,funct_i} == 9'b001_010011 || ALUOp_i == 3'b010) ? 2 : 	//add addi
				({ALUOp_i,funct_i} == 9'b001_010001) ? 6 : 		//sub
				({ALUOp_i,funct_i} == 9'b001_010100) ? 0 : 		//and
				({ALUOp_i,funct_i} == 9'b001_010110) ? 1 : 		//or
				({ALUOp_i,funct_i} == 9'b001_010101) ? 12 : 	//nor
				({ALUOp_i,funct_i} == 9'b001_110000) ? 7 : 		//slt
				({ALUOp_i,funct_i} == 9'b001_000000) ? 1 : 		//sll
				({ALUOp_i,funct_i} == 9'b001_000010) ? 0 :		//srl		
				({ALUOp_i,funct_i} == 9'b001_000110) ? 1 : 		//sllv
				({ALUOp_i,funct_i} == 9'b001_000100) ? 0 : 0;	//srlv	

assign ShifterV_o = ({ALUOp_i,funct_i} == 9'b001_000110) ? 1 : 	//SLLV
			({ALUOp_i,funct_i} == 9'b001_000100) ? 1 : 0; 		//SRLV	

endmodule     
