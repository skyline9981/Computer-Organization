module ALU_1bit( result, carryOut, a, b, invertA, invertB, operation, carryIn, less ); 
  
  output wire result;
  output wire carryOut;
  
  input wire a;
  input wire b;
  input wire invertA;
  input wire invertB;
  input wire[1:0] operation;
  input wire carryIn;
  input wire less;
  
  /*your code here*/
  
  reg input1;
  reg input2;
  reg re;

  wire AND1;
  wire OR1;

  output wire s;
  
  or  OR(OR1, input1, input2);
  and AND(AND1, input1, input2);
  Full_adder ADD(.sum(s),.carryOut(carryOut),.carryIn(carryIn),.input1(input1),.input2(input2));//use full_adder to control add

  always @(*)
  begin
    input1 = (invertA == 1'b0) ? a : ~a; //if invertA==0 input1 = a; else input1 = ~a;
    input2 = (invertB == 1'b0) ? b : ~b; //if invertB==0 input2 = b; else input2 = ~b;

    case (operation)
        2'b00:re = AND1;  //AND or NAND
        2'b01:re = OR1;   //OR or NOR
        2'b10:re = s;     //add or sub
        default: re = less; 
    endcase

  end

  assign result = re;
  
endmodule