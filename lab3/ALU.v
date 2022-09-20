module ALU (ALUctl, aluSrc1, aluSrc2, ALUOut, Zero);

//I/O ports 
input [4-1:0] ALUctl;
input signed [32-1:0] aluSrc1,aluSrc2;

output reg [32-1:0] ALUOut;
output Zero;

//Main function
/*your code here*/

assign Zero = (ALUOut == 0);

always @(ALUctl, aluSrc1, aluSrc2) begin
  case (ALUctl)
  0: ALUOut <= aluSrc1 & aluSrc2;
  1: ALUOut <= aluSrc1 | aluSrc2;
  2: ALUOut <= aluSrc1 + aluSrc2;
  6: ALUOut <= aluSrc1 - aluSrc2;
  7: ALUOut <= aluSrc1 < aluSrc2 ? 1 : 0;
  12: ALUOut <= ~(aluSrc1 | aluSrc2);
  default: ALUOut <= 0;
  endcase
end
    
endmodule