`timescale 1ns / 1ps
module tb_IP_Core;

reg fft_clk = 1'b0;
always #5 fft_clk =~fft_clk;
reg [5:0]cnt = 6'd0;
wire [7:0]data;

always@(posedge fft_clk)
begin
	cnt <= cnt + 6'd1;
end

RAM_quku2 RAM_quku1_0 (
  .clka(fft_clk),    // input wire clka
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(6'd0),  // input wire [5 : 0] addra
  .dina(8'd0),    // input wire [7 : 0] dina
  .clkb(fft_clk),    // input wire clkb
  .addrb(cnt),  // input wire [5 : 0] addrb
  .doutb(data)  // output wire [7 : 0] doutb
);
endmodule
