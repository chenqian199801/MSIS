`timescale 1ns / 1ps
module seg_display(
     input [31:0]xxx,
     input sys_clk,
     output reg [3:0]AN,//片选
     output reg [7:0]C//段选
    );
         
    task convert;
    input [31:0]x;
    output [31:0]y;
    reg [63:0]hex;
    begin
            hex[31:0]=x;
        repeat(31)
        begin
            hex=hex<<1;    
            if(hex[63:60]>4)
            hex[63:60]=hex[63:60]+3;
            if(hex[59:56]>4)
            hex[59:56]=hex[59:56]+3;
            if(hex[55:52]>4)
            hex[55:52]=hex[55:52]+3;
            if(hex[51:48]>4)
            hex[51:48]=hex[51:48]+3;
            if(hex[47:44]>4)
            hex[47:44]=hex[47:44]+3;
            if(hex[43:40]>4)
            hex[43:40]=hex[43:40]+3;
            if(hex[39:36]>4)
            hex[39:36]=hex[39:36]+3;
            if(hex[35:32]>4)
            hex[35:32]=hex[35:32]+3;
        end
        hex=hex<<1;
        y=hex[63:32];
    end
    endtask
    
    reg [31:0]sss;
    
    always begin   convert(xxx,sss);end
    
     wire [7:0]Y3,Y2,Y1,Y0;
     display1    M1(sss[3:0],Y0);
     display1    M2(sss[7:4],Y1);
     display1    M3(sss[11:8],Y2);
     display1    M4(sss[15:12],Y3);  
     
    reg[31:0]cnt=32'd0;
    reg [2:0]CS=3'b000;  
     
     always @(posedge sys_clk)
     begin
         if(cnt==32'd100_000)
            begin cnt<=32'd0;CS<=CS+1;   end
         else  if(CS==3'b100)CS<=3'b000;
         else   cnt<=cnt+1'b1;
     end
     
    initial begin
    AN=4'b1111;C=8'hff;
    end
	
    always@(posedge sys_clk)
	begin
		case(CS)
			3'b000:begin AN<=4'b0111;C<=Y3; end
			3'b001:begin AN<=4'b1011;C<=Y2; end
			3'b010:begin AN<=4'b1101;C<=Y1; end
			3'b011:begin AN<=4'b1110;C<=Y0; end
		endcase
	end
    endmodule

module display1(X,Y);//y0=a~y7=h
    input  [3:0]X;
    output [7:0]Y;
    reg [7:0]Y;
    always begin
    case(X)
    4'b0000  :Y=8'hc0  ;
    4'b0001  :Y=8'hf9  ;
    4'b0010  :Y=8'ha4  ;
    4'b0011  :Y=8'hb0  ;
    4'b0100  :Y=8'h99  ;
    4'b0101  :Y=8'h92  ;
    4'b0110  :Y=8'h82  ;
    4'b0111  :Y=8'hf8  ;
    4'b1000  :Y=8'h80  ;
    4'b1001  :Y=8'h90  ;
    4'b1010  :Y=8'h88  ;
    4'b1011  :Y=8'h83  ;
    4'b1100  :Y=8'hc6  ;
    4'b1101  :Y=8'ha1  ;
    4'b1110  :Y=8'h86  ;
    4'b1111  :Y=8'h8e  ;
    endcase
    end  
endmodule
