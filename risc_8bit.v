`timescale 1ns/100ps
module risc_8bit(dataout,carry,sign,zero,instr,clk);
output  reg [7:0]  dataout=0;
input [13:0]instr;
output reg carry,sign,zero;
input clk;
parameter ideal=2'b00,decode=2'b01,exec=2'b10;
reg [1:0]stage=0,nxt;
//////////////register
reg[13:0]opcode;
reg[7:0]a=0;
reg [7:0]b=0;
//////////////memory
reg [7:0]datamem[15:0];
reg [13:0]inst_mem[14:0];
//ptr
reg[3:0]ptr_mem=0;
reg[3:0]ptr=0;
initial 
	begin 
datamem[0]=8;
datamem[1]=3;
datamem[2]=1;
datamem[3]=5;
datamem[4]=2;
datamem[5]=9;
datamem[6]=17;
datamem[7]=4;
datamem[8]=21;
datamem[9]=15;
datamem[10]=5;
datamem[11]=7;
datamem[12]=4;
datamem[13]=1;
datamem[14]=9;
datamem[15]=11;
datamem[16]=32;
	end
always @(instr)
begin
inst_mem[ptr_mem]=instr;
ptr_mem=ptr_mem+1;
if(ptr_mem==4'b1111) ptr_mem=0;
end 

always@(stage)
begin
case(stage)
	ideal:begin 
		   
	            opcode=inst_mem[ptr];
	      nxt=decode;
	      end

	decode:begin 
			case(opcode[13:12])
				2'b00:begin if(opcode[11:8]==4'b1110) a=opcode[7:0]; else b=opcode[7:0] ;end
				2'b01:b=opcode[7:0];
				2'b11:begin a=datamem[opcode[7:4]]; b=datamem[opcode[3:0]]; end
			endcase
	       nxt=exec;
	       end

	exec:begin
			case(opcode[11:8])
				4'b0000:begin dataout=a||b;if(dataout==0) zero=1; else zero=0; end
				4'b0001:begin dataout=a&&b;if(dataout==0) zero=1; else zero=0; end
				4'b0010:begin dataout=!a;if(dataout==0) zero=1; else zero=0; end
				4'b0100:begin {carry,dataout}=a+b;if({carry,dataout}==0) zero=1; else zero=0;end
				4'b0110:begin {sign,dataout}=a-b;if({sign,dataout}==0) zero=1; else zero=0;end
				4'b1100:begin dataout=a<<b;if(dataout==0) zero=1; else zero=0; end
				4'b1101:begin dataout=a>>b;if(dataout==0) zero=1; else zero=0;end
				
			endcase
	     nxt=ideal; ptr=ptr+1;
	     end 
endcase
end
always @(posedge clk)
stage=nxt;
endmodule

module risc_8bit_tb;
wire [7:0]dataout;
wire carry,sign,zero;
reg [13:0]instr;
reg clk;
risc_8bit r1(dataout,carry,sign,zero,instr,clk);


initial 
clk=0;

always #10 clk=~clk;

initial 
begin 

 instr=14'b00111000000101;
#0.1 instr=14'b00111100001001;
#0.1 instr=14'b01010001110110;
#0.1 instr=14'b11011001111100;
#0.1 instr=14'b01000100000010;
#0.1 instr=14'b11110010111101;
end

endmodule 