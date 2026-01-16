`timescale 1ns / 1ps
module tb_Top;
reg    sys_clk;
reg    rst_n;
    //VGA port
wire [4:0]   rgb_r;
wire [5:0]   rgb_g;
wire [4:0]   rgb_b;
wire    hs;
wire   vs;
    //test
wire[15:0]    pixel_color;
wire[11:0]    pos_x;
wire[11:0]   pos_y;
wire [11:0]hcount;
wire [11:0]vcount;
initial begin sys_clk = 1'b0;rst_n = 1'b0; #10 rst_n = 1'b1; end

always #5 sys_clk = ~sys_clk;





Top top_s(
    sys_clk,
    rst_n,
    //VGA port
    rgb_r,
    rgb_g,
    rgb_b,
    hs,
   vs,
    //test
    pixel_color,
    pos_x,
   pos_y,
   hcount,
   vcount
    );
    
endmodule
