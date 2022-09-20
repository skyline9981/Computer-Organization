module Shifter( result, leftRight, shamt, sftSrc  );
    
  output wire[31:0] result;

  input wire leftRight;
  input wire[4:0] shamt;
  input wire[31:0] sftSrc ;
  
  /*your code here*/ 
  integer sh;
  reg [31:0] result_reg;
  always @(leftRight or shamt or sftSrc) 
  begin
  	sh = shamt;
  	if(leftRight) result_reg = (sftSrc << sh);
  	else result_reg = (sftSrc >> sh);
  end
  assign result = result_reg;
	
endmodule