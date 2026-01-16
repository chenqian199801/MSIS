`include "video_define.v"
module VGA_display(
    input pclk,
    input rst_n,
    //exchange data
    input [15:0]pixel_color,
    output [11:0]pos_x,
    output [11:0]pos_y,
    output video_active,
    //VGA port
    output [4:0]rgb_r,
    output [5:0]rgb_g,
    output [4:0]rgb_b,
    output hs,
    output vs
    /*
    //test
   output  reg [11:0]hcount,
   output  reg [11:0]vcount
   */
    );
//************************************************************************************************************
//800x600 40Mhz
`ifdef  VIDEO_800_600
parameter H_ACTIVE = 12'd800;           //horizontal active time (pixels)
parameter H_FP = 12'd40;                //horizontal front porch (pixels)
parameter H_SYNC = 12'd128;             //horizontal sync time(pixels)
parameter H_BP = 12'd88;                //horizontal back porch (pixels)
parameter V_ACTIVE = 12'd600;           //vertical active Time (lines)
parameter V_FP  = 12'd1;                //vertical front porch (lines)
parameter V_SYNC  = 12'd4;              //vertical sync time (lines)
parameter V_BP  = 12'd23;               //vertical back porch (lines)
//parameter HS_POL = 1'b1;               //horizontal sync polarity, 1 : POSITIVE,0 : NEGATIVE;
//parameter VS_POL = 1'b1;               //vertical sync polarity, 1 : POSITIVE,0 : NEGATIVE;
`endif

//1280x720 74.25MMhz
`ifdef  VIDEO_1280_720
parameter H_ACTIVE = 12'd1280;
parameter H_FP = 12'd110;      
parameter H_SYNC = 12'd40;   
parameter H_BP = 12'd220;     
parameter V_ACTIVE = 12'd720; 
parameter V_FP  = 12'd5;      
parameter V_SYNC  = 12'd5;    
parameter V_BP  = 12'd20;     
//parameter HS_POL = 1'b1;
//parameter VS_POL = 1'b1;
`endif

//1600*900 97.750MMhz
`ifdef  VIDEO_1600_900
parameter H_ACTIVE = 12'd1600;
parameter H_FP = 12'd48;      
parameter H_SYNC = 12'd32;   
parameter H_BP = 12'd80;     
parameter V_ACTIVE = 12'd900; 
parameter V_FP  = 12'd3;      
parameter V_SYNC  = 12'd5;    
parameter V_BP  = 12'd18;     
//parameter HS_POL = 1'b1;
//parameter VS_POL = 1'b1;
`endif

//1280x1024 108MMhz
`ifdef  VIDEO_1280_1024
parameter H_ACTIVE = 12'd1280;
parameter H_FP = 12'd48;      
parameter H_SYNC = 12'd112;   
parameter H_BP = 12'd248;     
parameter V_ACTIVE = 12'd1024; 
parameter V_FP  = 12'd1;      
parameter V_SYNC  = 12'd3;    
parameter V_BP  = 12'd38;     
//parameter HS_POL = 1'b1;
//parameter VS_POL = 1'b1;
`endif

//1920x1080 148.5Mhz
`ifdef  VIDEO_1920_1080
parameter H_ACTIVE = 12'd1920;
parameter H_FP = 12'd88;
parameter H_SYNC = 12'd44;
parameter H_BP = 12'd148; 
parameter V_ACTIVE = 12'd1080;
parameter V_FP  = 12'd4;
parameter V_SYNC  = 12'd5;
parameter V_BP  = 12'd36;
//parameter HS_POL = 1'b1;
//parameter VS_POL = 1'b1;
`endif

parameter H_TOTAL = H_ACTIVE + H_FP + H_SYNC + H_BP;//horizontal total time (pixels)
parameter V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP;//vertical total time (lines)

//*************************************************************************************************************

assign rgb_r = pixel_color[15:11];
assign rgb_g = pixel_color[10:5];
assign rgb_b = pixel_color[4:0];
    
reg [11:0]hcount;
reg [11:0]vcount;
/*
wire [11:0]hcount_ov;
wire [11:0]vcount_ov;
assign hcount_ov = (hcount == (H_TOTAL - 12'd1));
assign vcount_ov = (vcount == (V_TOTAL - 12'd1));
*/
always@(posedge pclk or negedge rst_n)
begin
    if(!rst_n)
        hcount <= 12'd0;
    else if(hcount == (H_TOTAL - 12'd1))
        hcount <= 12'd0;
    else
        hcount <= hcount +12'd1;
end
always@(posedge pclk or negedge rst_n)
begin
    if(!rst_n)
        vcount <= 12'd0;
    else if(hcount == (H_TOTAL - 12'd1))
    begin
        if(vcount == (V_TOTAL - 12'd1))
            vcount <= 12'd0;
        else
            vcount <= vcount +12'd1;
    end
    else
        vcount <= vcount;
end
/*    
assign hs = ~(hcount >= H_FP && hcount < H_FP+H_SYNC);
assign vs = ~(vcount >= V_FP && vcount < V_FP+V_SYNC);

assign pos_x = (hcount >= H_FP + H_SYNC + H_BP)?(hcount - (H_FP + H_SYNC + H_BP - 12'd1)):(12'd0);
assign pos_y = (vcount >= V_FP + V_SYNC + V_BP)?(vcount - (V_FP + V_SYNC + V_BP - 12'd1)):(12'd0);
*/
assign hs = (hcount >= H_SYNC);
assign vs = (vcount >= V_SYNC);

assign pos_x = (hcount >= H_SYNC + H_BP && hcount < H_SYNC + H_BP + H_ACTIVE)?(hcount - (H_SYNC + H_BP - 12'd1)):(12'd0);
assign pos_y = (vcount >= V_SYNC + V_BP && vcount < V_SYNC + V_BP + V_ACTIVE)?(vcount - (V_SYNC + V_BP - 12'd1)):(12'd0);
assign video_active = (pos_x >= 12'd1 && pos_x <= H_ACTIVE && pos_y >= 12'd1 && pos_y <= V_ACTIVE);

endmodule
