module ALU( result, zero, overflow, aluSrc1, aluSrc2, invertA, invertB, operation );
   
  output wire[31:0] result;
  output wire zero;
  output wire overflow;

  input wire[31:0] aluSrc1;
  input wire[31:0] aluSrc2;
  input wire invertA;
  input wire invertB;
  input wire[1:0] operation;
  
  /*your code here*/
  
  wire[31:0] carryi = 32'b0;
  wire[1:0] op;

  reg[31:0] srca;
  reg[31:0] srcb;
  reg[31:0] less = 32'b0;

  output wire[31:0] re;
  output wire[31:0] carryo;

  assign op = (operation == 2'b11) ? 2'b10 : operation;		//if op is SLT,then do SUB.
  
  genvar i;		//use for_loop to complete the 32_bits ALU.
  generate
    ALU_1bit alu0(
      .result(re[0]),
      .carryOut(carryo[0]),
      .a(aluSrc1[0]),
      .b(aluSrc2[0]),
      .invertA(invertA),
      .invertB(invertB),
      .operation(op),
      .carryIn(invertB),
      .less(less[0])
    );
    for (i=1;i<32;i=i+1)begin:block1
        ALU_1bit alu0(
          .result(re[i]),
          .carryOut(carryo[i]),
          .a(aluSrc1[i]),
          .b(aluSrc2[i]),
          .invertA(invertA),
          .invertB(invertB),
          .operation(op),
          .carryIn(carryo[i-1]),
          .less(less[i])
        );
    end
  endgenerate 

  assign overflow=carryo[31] ^ carryo[30];
  
  always @(*) begin  		
    if (operation == 2'b11)		//decide the less[0] by the sign_bit when the operation is SLT.
    begin  		
      if (re[31] == 1'b1) less[0] = re[31];
    end

    else 						//if the operation is not SLT, less[0] == 0
    begin 							
      less[0] = 1'b0;
    end
  end
  assign zero = (result == 32'b0) ? 1'b1 : 1'b0; 		//if 32 bits of the result are all 0, then set zero ==1.
  assign result = (operation == 2'b11) ? less : re;  	//if the operation is SLT, then the result == less.
  														//Otherwise, the result == re.
endmodule