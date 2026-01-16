`timescale 1ns / 1ps

module dtw_tb;

reg sys_clk = 1'b0;
reg test_clk = 1'b0;

always #5 sys_clk = ~sys_clk;
always #10 test_clk = ~test_clk;

reg [7:0]R_q0;
reg R_ce0 = 1'b0;
reg [5:0]R_address = 6'd0;

always@(posedge R_ce0)
begin
	R_address <= R_address + 6'd1;
end

always@(posedge sys_clk)
begin
	R_ce0 <= ~R_ce0;
end

always@(posedge sys_clk)
begin
	if(R_ce0 && R_address == 6'd1)
		R_q0 <= 8'd55;
	else if(R_ce0 && R_address == 6'd3)
		R_q0 <= 8'd66;
	else
		R_q0 <= R_q0;
end

endmodule
