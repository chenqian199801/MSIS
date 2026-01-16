module Inteligent_recog(
	input fft_clk,
	input rst_n,
	input pclk,
	input adc_clk,

	input [3:0]music_list_1,
	input key0,							//0:模式一    1:模式二
	input key1,							//0:停止      1:启动
	
	input [13:0]fft_vga_ram_input_cnt,
	input [11:0]fft_data,
	input [7:0]THR,
	input [11:0]PARA,
	input [11:0]pos_x,
	input [11:0]pos_y,
	
	output [7:0]score_0,			//模式一识别得分
	output reg [7:0]score_1,		//模式二学习进度
	output [3:0]music_list_0,		//0:识别中；1~5:五首歌曲,7:全黑
	output reg [6:0]fft_k0,			//当前弹奏的琴键
	output reg [6:0]fft_k1,			//学习模式下标准琴键
	output reg select_color,
	//7_seg
    output [3:0]AN,					//片选
    output [7:0]C,					//段选
	
	//test
	input 	led3,
	input   key3_flag,				//+
	input 	key4_flag				//-
	
    );

//实际K值映射到钢琴键值
function [6:0]o_fft_K; 
    input [11:0]i_data;
    begin
        if     (i_data > 12'd15   && i_data <= 12'd23  )   o_fft_K = 7'd1;
        else if(i_data > 12'd23   && i_data <= 12'd24  )   o_fft_K = 7'd2;
        else if(i_data > 12'd24   && i_data <= 12'd26  )   o_fft_K = 7'd3;
        else if(i_data > 12'd26   && i_data <= 12'd27  )   o_fft_K = 7'd4;
        else if(i_data > 12'd27   && i_data <= 12'd29  )   o_fft_K = 7'd5;
        else if(i_data > 12'd29   && i_data <= 12'd30  )   o_fft_K = 7'd6;
        else if(i_data > 12'd30   && i_data <= 12'd32  )   o_fft_K = 7'd7;
        else if(i_data > 12'd32   && i_data <= 12'd34  )   o_fft_K = 7'd8;
        else if(i_data > 12'd34   && i_data <= 12'd36  )   o_fft_K = 7'd9;
        else if(i_data > 12'd36   && i_data <= 12'd38  )   o_fft_K = 7'd10; 
        else if(i_data > 12'd38   && i_data <= 12'd41  )   o_fft_K = 7'd11;
        else if(i_data > 12'd41   && i_data <= 12'd43  )   o_fft_K = 7'd12;
        else if(i_data > 12'd43   && i_data <= 12'd46  )   o_fft_K = 7'd13;
        else if(i_data > 12'd46   && i_data <= 12'd49  )   o_fft_K = 7'd14;
        else if(i_data > 12'd49   && i_data <= 12'd52  )   o_fft_K = 7'd15;
        else if(i_data > 12'd52   && i_data <= 12'd55  )   o_fft_K = 7'd16;
        else if(i_data > 12'd55   && i_data <= 12'd58  )   o_fft_K = 7'd17;
        else if(i_data > 12'd58   && i_data <= 12'd62  )   o_fft_K = 7'd18;
        else if(i_data > 12'd62   && i_data <= 12'd65  )   o_fft_K = 7'd19;  
        else if(i_data > 12'd65   && i_data <= 12'd69  )   o_fft_K = 7'd20;
        else if(i_data > 12'd69   && i_data <= 12'd73  )   o_fft_K = 7'd21;
        else if(i_data > 12'd73   && i_data <= 12'd78  )   o_fft_K = 7'd22;
        else if(i_data > 12'd78   && i_data <= 12'd83  )   o_fft_K = 7'd23;
        else if(i_data > 12'd83   && i_data <= 12'd87  )   o_fft_K = 7'd24;
        else if(i_data > 12'd87   && i_data <= 12'd93  )   o_fft_K = 7'd25;
        else if(i_data > 12'd93   && i_data <= 12'd98  )   o_fft_K = 7'd26;
        else if(i_data > 12'd98   && i_data <= 12'd103 )   o_fft_K = 7'd27;
        else if(i_data > 12'd103  && i_data <= 12'd110 )   o_fft_K = 7'd28;  
        else if(i_data > 12'd110  && i_data <= 12'd117 )   o_fft_K = 7'd29;
        else if(i_data > 12'd117  && i_data <= 12'd124 )   o_fft_K = 7'd30;
        else if(i_data > 12'd124  && i_data <= 12'd131 )   o_fft_K = 7'd31;
        else if(i_data > 12'd131  && i_data <= 12'd140 )   o_fft_K = 7'd32;
        else if(i_data > 12'd140  && i_data <= 12'd147 )   o_fft_K = 7'd33;
        else if(i_data > 12'd147  && i_data <= 12'd155 )   o_fft_K = 7'd34;
        else if(i_data > 12'd155  && i_data <= 12'd165 )   o_fft_K = 7'd35;
        else if(i_data > 12'd165  && i_data <= 12'd175 )   o_fft_K = 7'd36;
        else if(i_data > 12'd175  && i_data <= 12'd186 )   o_fft_K = 7'd37;  
        else if(i_data > 12'd186  && i_data <= 12'd197 )   o_fft_K = 7'd38;
        else if(i_data > 12'd197  && i_data <= 12'd209 )   o_fft_K = 7'd39;
        else if(i_data > 12'd209  && i_data <= 12'd221 )   o_fft_K = 7'd40;
        else if(i_data > 12'd221  && i_data <= 12'd233 )   o_fft_K = 7'd41;
        else if(i_data > 12'd233  && i_data <= 12'd248 )   o_fft_K = 7'd42;
        else if(i_data > 12'd248  && i_data <= 12'd263 )   o_fft_K = 7'd43;
        else if(i_data > 12'd263  && i_data <= 12'd279 )   o_fft_K = 7'd44;
        else if(i_data > 12'd279  && i_data <= 12'd295 )   o_fft_K = 7'd45;
        else if(i_data > 12'd295  && i_data <= 12'd315 )   o_fft_K = 7'd46;  
        else if(i_data > 12'd315  && i_data <= 12'd330 )   o_fft_K = 7'd47;
        else if(i_data > 12'd330  && i_data <= 12'd350 )   o_fft_K = 7'd48;
        else if(i_data > 12'd350  && i_data <= 12'd371 )   o_fft_K = 7'd49;
        else if(i_data > 12'd371  && i_data <= 12'd393 )   o_fft_K = 7'd50;
        else if(i_data > 12'd393  && i_data <= 12'd412 )   o_fft_K = 7'd51;
        else if(i_data > 12'd412  && i_data <= 12'd441 )   o_fft_K = 7'd52;
        else if(i_data > 12'd441  && i_data <= 12'd470 )   o_fft_K = 7'd53;
        else if(i_data > 12'd470  && i_data <= 12'd495 )   o_fft_K = 7'd54;
        else if(i_data > 12'd495  && i_data <= 12'd525 )   o_fft_K = 7'd55;  
        else if(i_data > 12'd525  && i_data <= 12'd555 )   o_fft_K = 7'd56;
        else if(i_data > 12'd555  && i_data <= 12'd590 )   o_fft_K = 7'd57;
        else if(i_data > 12'd590  && i_data <= 12'd620 )   o_fft_K = 7'd58;
        else if(i_data > 12'd620  && i_data <= 12'd661 )   o_fft_K = 7'd59;
        else if(i_data > 12'd661  && i_data <= 12'd700 )   o_fft_K = 7'd60;
        else if(i_data > 12'd700  && i_data <= 12'd742 )   o_fft_K = 7'd61;
        else if(i_data > 12'd742  && i_data <= 12'd786 )   o_fft_K = 7'd62;
        else if(i_data > 12'd786  && i_data <= 12'd835 )   o_fft_K = 7'd63;
        else if(i_data > 12'd835  && i_data <= 12'd882 )   o_fft_K = 7'd64;  
        else if(i_data > 12'd882  && i_data <= 12'd933 )   o_fft_K = 7'd65;
        else if(i_data > 12'd933  && i_data <= 12'd990 )   o_fft_K = 7'd66;
        else if(i_data > 12'd990  && i_data <= 12'd1050)   o_fft_K = 7'd67;
        else if(i_data > 12'd1050 && i_data <= 12'd1110)   o_fft_K = 7'd68;
        else if(i_data > 12'd1110 && i_data <= 12'd1180)   o_fft_K = 7'd69;
        else if(i_data > 12'd1180 && i_data <= 12'd1245)   o_fft_K = 7'd70;
        else if(i_data > 12'd1245 && i_data <= 12'd1330)   o_fft_K = 7'd71;
        else if(i_data > 12'd1330 && i_data <= 12'd1400)   o_fft_K = 7'd72;
        else if(i_data > 12'd1400 && i_data <= 12'd1485)   o_fft_K = 7'd73;  
        else if(i_data > 12'd1485 && i_data <= 12'd1570)   o_fft_K = 7'd74;
        else if(i_data > 12'd1570 && i_data <= 12'd1668)   o_fft_K = 7'd75;
        else if(i_data > 12'd1668 && i_data <= 12'd1765)   o_fft_K = 7'd76;
        else if(i_data > 12'd1765 && i_data <= 12'd1870)   o_fft_K = 7'd77;
        else if(i_data > 12'd1870 && i_data <= 12'd1982)   o_fft_K = 7'd78;
        else if(i_data > 12'd1982 && i_data <= 12'd2100)   o_fft_K = 7'd79;
        else if(i_data > 12'd2100 && i_data <= 12'd2225)   o_fft_K = 7'd80;
        else if(i_data > 12'd2225 && i_data <= 12'd2355)   o_fft_K = 7'd81;
        else if(i_data > 12'd2355 && i_data <= 12'd2495)   o_fft_K = 7'd82;
        else if(i_data > 12'd2495 && i_data <= 12'd2645)   o_fft_K = 7'd83;
        else if(i_data > 12'd2645 && i_data <= 12'd2800)   o_fft_K = 7'd84;
        else if(i_data > 12'd2800 && i_data <= 12'd2960)   o_fft_K = 7'd85;
        else if(i_data > 12'd2960 && i_data <= 12'd3140)   o_fft_K = 7'd86;
        else if(i_data > 12'd3140 && i_data <= 12'd3320)   o_fft_K = 7'd87;
        else if(i_data > 12'd3320 && i_data <= 12'd3500)   o_fft_K = 7'd88;
        else                                               o_fft_K = 7'd0; 
    end
endfunction


//曲库计算总调数相关变量
reg  cal_signal;
reg  [5:0]cal_cnt;
reg [5:0]Qupu1_sum;
reg [5:0]Qupu2_sum;
reg [5:0]Qupu3_sum;
reg [5:0]Qupu4_sum;
reg [5:0]Qupu5_sum;
//曲库相关变量
wire [5:0]F1_address0;
wire [5:0]F2_address0;
wire [5:0]F3_address0;
wire [5:0]F4_address0;
wire [5:0]F5_address0;

wire [5:0]mode0_Qupu1_cnt = F1_address0;
wire [5:0]mode0_Qupu2_cnt = F2_address0;
wire [5:0]mode0_Qupu3_cnt = F3_address0;
wire [5:0]mode0_Qupu4_cnt = F4_address0;
wire [5:0]mode0_Qupu5_cnt = F5_address0;


reg  [5:0]mode1_Qupu_cnt;

wire [5:0]ROM_Music_Qupu_1_cnt = (cal_signal)?(cal_cnt):((key0)?(mode1_Qupu_cnt):(mode0_Qupu1_cnt));
wire [5:0]ROM_Music_Qupu_2_cnt = (cal_signal)?(cal_cnt):((key0)?(mode1_Qupu_cnt):(mode0_Qupu2_cnt));
wire [5:0]ROM_Music_Qupu_3_cnt = (cal_signal)?(cal_cnt):((key0)?(mode1_Qupu_cnt):(mode0_Qupu3_cnt));
wire [5:0]ROM_Music_Qupu_4_cnt = (cal_signal)?(cal_cnt):((key0)?(mode1_Qupu_cnt):(mode0_Qupu4_cnt));
wire [5:0]ROM_Music_Qupu_5_cnt = (cal_signal)?(cal_cnt):((key0)?(mode1_Qupu_cnt):(mode0_Qupu5_cnt));
wire [7:0]ROM_Music_Qupu_1_data;
wire [7:0]ROM_Music_Qupu_2_data;
wire [7:0]ROM_Music_Qupu_3_data;
wire [7:0]ROM_Music_Qupu_4_data;
wire [7:0]ROM_Music_Qupu_5_data;

//mode0->mode0_fft_k;score_0;music_list_0;
reg [3:0]mode0_state;
reg [3:0]mode0_state_2;
reg  mode0_state_sub;
reg  mode0_state_sub2;

reg [7:0]score_0_temp1;
reg [7:0]score_0_temp2;
reg [3:0]music_list_0_temp1;
reg [3:0]music_list_0_temp2;
assign score_0	= (!key0)?((key1)?(score_0_temp1):(score_0_temp2)):(8'd0);
assign music_list_0 = (!key0)?((key1)?(music_list_0_temp1):(music_list_0_temp2)):(4'd7);
	

reg [6:0]mode0_mem[0:50];
reg [7:0]mem_i;

function fft_k0_uninclude;
	input [6:0]x;
	begin
		fft_k0_uninclude = (x != 7'd46 && x != 7'd48 && x != 7'd50 && x != 7'd53 && x != 7'd55 && x != 7'd58 && x != 7'd60 && x != 7'd62);
	end
endfunction

//[6:0]fft_k0 ->score_0，score_1，music_list_0
reg [31:0]xiaodou_cnt;
reg [6:0]fft_k0_temp;
reg sig_0;

wire condition1 = (fft_k0_temp >= 7'd44 && fft_k0_temp <= 7'd63 && fft_k0_uninclude(fft_k0_temp));
wire condition2 = (fft_k0_temp >= 7'd44 && fft_k0_temp <= 7'd63 && fft_k0 >= 7'd44 && fft_k0 <= 7'd63 && fft_k0 != fft_k0_temp && fft_k0_uninclude(fft_k0_temp) && fft_k0_uninclude(fft_k0)); 

//mode1
reg mode1_state_sub;
wire [7:0]ROM_Music_Qupu_data = ( music_list_1 == 4'd1)?(ROM_Music_Qupu_1_data):
								((music_list_1 == 4'd2)?(ROM_Music_Qupu_2_data):
								((music_list_1 == 4'd3)?(ROM_Music_Qupu_3_data):
								((music_list_1 == 4'd4)?(ROM_Music_Qupu_4_data):
								((music_list_1 == 4'd5)?(ROM_Music_Qupu_5_data):
								( 8'd0	)))));
//reg  [5:0]mode1_Qupu_cnt;
//***************************************************模式一内部算法****************************************************

always@(posedge pclk or negedge rst_n)
begin
	if(!rst_n)
	begin
		fft_k0_temp <= 7'd0;
	end
	else if(pos_y == 12'd20)
	begin
		fft_k0_temp <= fft_k0;
	end
	else
	begin
		fft_k0_temp <= fft_k0_temp;
	end
end



//模式一启动 往mode0_mem缓存灌入数据
always@(posedge pclk or negedge rst_n)
begin
	if(!rst_n)
	begin
		//模式一启动
		mem_i					<= 8'd0;
		mode0_state				<= 4'd0;
		mode0_state_sub 		<= 1'b0;
		mode0_state_sub2 		<= 1'b0;
		
		xiaodou_cnt				<= 32'd0;
		sig_0					<= 1'b0;
		
		//模式一结束
		/**/
		music_list_0_temp1		<= 4'd7;
		score_0_temp1			<= 8'd0;
		
	end
	else if(!key0) //模式一
	begin
		
		if(key1)	//启动 往mode0_mem缓存灌入数据
		begin
			case(mode0_state)
				4'd0:begin	//mode0_mem缓存清零
						mode0_mem[0]	<= 7'd0;mode0_mem[10]	<= 7'd0;mode0_mem[20]	<= 7'd0;mode0_mem[30]	<= 7'd0;mode0_mem[40]	<= 7'd0;
						mode0_mem[1]	<= 7'd0;mode0_mem[11]	<= 7'd0;mode0_mem[21]	<= 7'd0;mode0_mem[31]	<= 7'd0;mode0_mem[41]	<= 7'd0;
						mode0_mem[2]	<= 7'd0;mode0_mem[12]	<= 7'd0;mode0_mem[22]	<= 7'd0;mode0_mem[32]	<= 7'd0;mode0_mem[42]	<= 7'd0;
						mode0_mem[3]	<= 7'd0;mode0_mem[13]	<= 7'd0;mode0_mem[23]	<= 7'd0;mode0_mem[33]	<= 7'd0;mode0_mem[43]	<= 7'd0;
						mode0_mem[4]	<= 7'd0;mode0_mem[14]	<= 7'd0;mode0_mem[24]	<= 7'd0;mode0_mem[34]	<= 7'd0;mode0_mem[44]	<= 7'd0;
						mode0_mem[5]	<= 7'd0;mode0_mem[15]	<= 7'd0;mode0_mem[25]	<= 7'd0;mode0_mem[35]	<= 7'd0;mode0_mem[45]	<= 7'd0;
						mode0_mem[6]	<= 7'd0;mode0_mem[16]	<= 7'd0;mode0_mem[26]	<= 7'd0;mode0_mem[36]	<= 7'd0;mode0_mem[46]	<= 7'd0;
						mode0_mem[7]	<= 7'd0;mode0_mem[17]	<= 7'd0;mode0_mem[27]	<= 7'd0;mode0_mem[37]	<= 7'd0;mode0_mem[47]	<= 7'd0;
						mode0_mem[8]	<= 7'd0;mode0_mem[18]	<= 7'd0;mode0_mem[28]	<= 7'd0;mode0_mem[38]	<= 7'd0;mode0_mem[48]	<= 7'd0;
						mode0_mem[9]	<= 7'd0;mode0_mem[19]	<= 7'd0;mode0_mem[29]	<= 7'd0;mode0_mem[39]	<= 7'd0;mode0_mem[49]	<= 7'd0;
						mode0_mem[50]	<= 7'd0;
						/*
						mode0_mem[50]	<= 7'd0;mode0_mem[60]	<= 7'd0;mode0_mem[70]	<= 7'd0;mode0_mem[80]	<= 7'd0;mode0_mem[90]	<= 7'd0;
						mode0_mem[51]	<= 7'd0;mode0_mem[61]	<= 7'd0;mode0_mem[71]	<= 7'd0;mode0_mem[81]	<= 7'd0;mode0_mem[91]	<= 7'd0;
						mode0_mem[52]	<= 7'd0;mode0_mem[62]	<= 7'd0;mode0_mem[72]	<= 7'd0;mode0_mem[82]	<= 7'd0;mode0_mem[92]	<= 7'd0;
						mode0_mem[53]	<= 7'd0;mode0_mem[63]	<= 7'd0;mode0_mem[73]	<= 7'd0;mode0_mem[83]	<= 7'd0;mode0_mem[93]	<= 7'd0;
						mode0_mem[54]	<= 7'd0;mode0_mem[64]	<= 7'd0;mode0_mem[74]	<= 7'd0;mode0_mem[84]	<= 7'd0;mode0_mem[94]	<= 7'd0;
						mode0_mem[55]	<= 7'd0;mode0_mem[65]	<= 7'd0;mode0_mem[75]	<= 7'd0;mode0_mem[85]	<= 7'd0;mode0_mem[95]	<= 7'd0;
						mode0_mem[56]	<= 7'd0;mode0_mem[66]	<= 7'd0;mode0_mem[76]	<= 7'd0;mode0_mem[86]	<= 7'd0;mode0_mem[96]	<= 7'd0;
						mode0_mem[57]	<= 7'd0;mode0_mem[67]	<= 7'd0;mode0_mem[77]	<= 7'd0;mode0_mem[87]	<= 7'd0;mode0_mem[97]	<= 7'd0;
						mode0_mem[58]	<= 7'd0;mode0_mem[68]	<= 7'd0;mode0_mem[78]	<= 7'd0;mode0_mem[88]	<= 7'd0;mode0_mem[98]	<= 7'd0;
						mode0_mem[59]	<= 7'd0;mode0_mem[69]	<= 7'd0;mode0_mem[79]	<= 7'd0;mode0_mem[89]	<= 7'd0;mode0_mem[99]	<= 7'd0;
						*/ 
						//初始匿
						mem_i					<= 8'd0;
						mode0_state_sub 		<= 1'b0;
						mode0_state_sub2 		<= 1'b0;
						
						xiaodou_cnt				<= 32'd0;
						sig_0					<= 1'b0;
						
						music_list_0_temp1		<= 4'd0;	//识别中...
						score_0_temp1			<= 8'd0;
						
						/**/
						mode0_state		<= 4'd1;
					 end
				4'd1:begin
						case(mode0_state_sub)
							1'b0:begin	//灌入数据
									if(condition1)	
									begin
										if(xiaodou_cnt <= 32'd10_000_000) //消抖时间，待调整
											xiaodou_cnt <= xiaodou_cnt + 32'd1;
										else
										begin
											xiaodou_cnt 		<= 32'd0;
											mode0_mem[mem_i]	<= fft_k0_temp;
											if(mem_i < 8'd49)	mem_i <= mem_i + 8'd1;
											
											mode0_state_sub 	<= 1'b1;
										end
									end
									else
										xiaodou_cnt <= 32'd0;
								 end
							1'b1:begin //等待下降到THR之下
									if(!condition1)	
									begin
										if(xiaodou_cnt <= 32'd10_000_000) //消抖时间，待调整
											xiaodou_cnt <= xiaodou_cnt + 32'd1;
										else
										begin
											xiaodou_cnt 	<= 32'd0;
											mode0_state_sub <= 1'b0;
										end
									end
									else
										xiaodou_cnt <= 32'd0;
								 end
						endcase
						
						mode0_state		<= 4'd2;
					 end
				4'd2:begin
						if(pos_y == 12'd10)
						begin
							case(mode0_state_sub2)
								1'b0:begin
										if(condition2)
										begin
											sig_0				<= 1'b1;
											
											mode0_state_sub2	<= 1'b1;
										end
									 end
								1'b1:begin
										if(!condition2)
											mode0_state_sub2	<= 1'b0;
									 end
							endcase
						end
						
						mode0_state	<= 4'd3;
					 end
				4'd3:begin
						if(pos_y == 12'd30 && sig_0)
						begin
							sig_0 <= 1'b0;
						
							mode0_mem[mem_i]	<= fft_k0_temp;
							if(mem_i < 8'd49)	mem_i <= mem_i + 8'd1;
						end
					
						mode0_state	<= 4'd1;
					 end
				default:begin 
							mode0_state 		<= 4'd1;
							mode0_state_sub 	<= 1'b0;
							mode0_state_sub2 	<= 1'b0;
						end
			endcase
		end
		else	    //停止
		begin
			mode0_state		<= 4'd0;
		end
	end
	else	//模式二
	begin
		mode0_state		<= 4'd0;
	end
end
//将采到的mode0_mem数据进行数码管显示
reg [7:0]mem_i_3;

always@(posedge fft_clk or negedge rst_n)
begin
	if(!rst_n)
		mem_i_3 <= 8'd0;
	else if(led3)
	begin
		if(key3_flag)
		begin
			if(mem_i_3 > 8'd49)
				mem_i_3 <= 8'd0;
			else if(mem_i_3 == 8'd49)
				mem_i_3 <= 8'd0;
			else
				mem_i_3 <= mem_i_3 + 8'd1;
		end
		else if(key4_flag)
		begin
			if(mem_i_3 > 8'd49)
				mem_i_3 <= 8'd0;
			else if(mem_i_3 == 8'd0)
				mem_i_3 <= 8'd49;
			else
				mem_i_3 <= mem_i_3 - 8'd1;
		end
		else
		begin
			if(mem_i_3 > 8'd49)
				mem_i_3 <= 8'd0;
			else
				mem_i_3 <= mem_i_3;
		end
	end
	else
		mem_i_3 <= 8'd0;
end

reg [31:0]seg_data;

always@(posedge adc_clk or negedge rst_n)
begin
	if(!rst_n)
		seg_data <= 32'd0;
	else
		seg_data <= {24'd0,mem_i_3} * 32'd100 + {25'd0,mode0_mem[mem_i_3]};
end

seg_display	seg_display_0(
     .xxx				(seg_data			),
     .sys_clk			(fft_clk			),
     .AN				(AN					),//片选
     .C					(C					)//段选
    );

//***problem***problem***problem***problem***problem***problem***problem

//模式一结束，mode0_mem缓存数据和标准库对比产生结果 music_list_0_temp2 && score_0_temp2

//quku_RAM相关变量

//quku_RAM输入变量************************************待完善（用于标准库更新）************************************************
reg [5:0]quku1_i_cnt = 6'd50;
reg [7:0]quku1_i_data;
reg [5:0]quku2_i_cnt = 6'd50;
reg [7:0]quku2_i_data;
reg [5:0]quku3_i_cnt = 6'd50;
reg [7:0]quku3_i_data;
reg [5:0]quku4_i_cnt = 6'd50;
reg [7:0]quku4_i_data;
reg [5:0]quku5_i_cnt = 6'd50;
reg [7:0]quku5_i_data;
//***************************************************待完善（用于标准库更新）*************************************************

//quku_RAM输出变量 && 将标准库数据灌入DTW模块
wire  [5:0]quku1_o_cnt;
wire  [5:0]quku2_o_cnt;
wire  [5:0]quku3_o_cnt;
wire  [5:0]quku4_o_cnt;
wire  [5:0]quku5_o_cnt;

wire [7:0]quku1_o_data;
wire [7:0]quku2_o_data;
wire [7:0]quku3_o_data;
wire [7:0]quku4_o_data;
wire [7:0]quku5_o_data;


//******DTW相关变量
//***DTW输出变量
wire music_match_done;
wire [7:0]music_match_result;
wire score_match_done;
wire [7:0]score_match_result;

//***DTW输入变量
reg [7:0]F1_q;
reg [7:0]F2_q;
reg [7:0]F3_q;
reg [7:0]F4_q;
reg [7:0]F5_q;
reg [7:0]R_q;

wire F1_ce0;
wire F2_ce0;
wire F3_ce0;
wire F4_ce0;
wire F5_ce0;
wire R_ce0;
/*
wire [5:0]F1_address0;
wire [5:0]F2_address0;
wire [5:0]F3_address0;
wire [5:0]F4_address0;
wire [5:0]F5_address0;
*/
wire [5:0]R_address0;
wire [7:0]F1_q0 = F1_q;
wire [7:0]F2_q0 = F2_q;
wire [7:0]F3_q0 = F3_q;
wire [7:0]F4_q0 = F4_q;
wire [7:0]F5_q0 = F5_q;
wire [7:0]R_q0  = R_q;

wire F1_ce1;
wire F2_ce1;
wire F3_ce1;
wire F4_ce1;
wire F5_ce1;
wire R_ce1;
wire [5:0]F1_address1;
wire [5:0]F2_address1;
wire [5:0]F3_address1;
wire [5:0]F4_address1;
wire [5:0]F5_address1;
wire [5:0]R_address1;
wire [7:0]F1_q1 = F1_q;
wire [7:0]F2_q1 = F2_q;
wire [7:0]F3_q1 = F3_q;
wire [7:0]F4_q1 = F4_q;
wire [7:0]F5_q1 = F5_q;
wire [7:0]R_q1  = R_q;

//缓存mem数据灌入DTW
always@(posedge fft_clk or negedge rst_n)
begin
	if(!rst_n)
		R_q <= 8'd0;
	else if(R_ce0)
		R_q <= mode0_mem[R_address0];
	else
		R_q <= R_q;
end

//曲库数据灌入DTW
always@(posedge fft_clk or negedge rst_n)
begin
	if(!rst_n)
		F1_q <= 8'd0;
	else if(F1_ce0)
		F1_q <= ROM_Music_Qupu_1_data;
	else
		F1_q <= F1_q;
end
always@(posedge fft_clk or negedge rst_n)
begin
	if(!rst_n)
		F2_q <= 8'd0;
	else if(F2_ce0)
		F2_q <= ROM_Music_Qupu_2_data;
	else
		F2_q <= F2_q;
end
always@(posedge fft_clk or negedge rst_n)
begin
	if(!rst_n)
		F3_q <= 8'd0;
	else if(F3_ce0)
		F3_q <= ROM_Music_Qupu_3_data;
	else
		F3_q <= F3_q;
end
always@(posedge fft_clk or negedge rst_n)
begin
	if(!rst_n)
		F4_q <= 8'd0;
	else if(F4_ce0)
		F4_q <= ROM_Music_Qupu_4_data;
	else
		F4_q <= F4_q;
end
always@(posedge fft_clk or negedge rst_n)
begin
	if(!rst_n)
		F5_q <= 8'd0;
	else if(F5_ce0)
		F5_q <= ROM_Music_Qupu_5_data;
	else
		F5_q <= F5_q;
end

//计算得到music_list_0_temp2 && score_0_temp2
always@(posedge fft_clk or negedge rst_n)
begin
	if(!rst_n)
		music_list_0_temp2 <= 4'd7;
	else if(!key0 && !key1)
	begin
		if(music_match_done)
			music_list_0_temp2 <= music_match_result[3:0];
		else
			music_list_0_temp2 <= music_list_0_temp2;
	end
	else
		music_list_0_temp2 <= 4'd7;
end

always@(posedge fft_clk or negedge rst_n)
begin
	if(!rst_n)
		score_0_temp2 <= 8'd0;
	else if(!key0 && !key1)
	begin
		if(score_match_done)
			score_0_temp2 <= score_match_result;
		else
			score_0_temp2 <= score_0_temp2;
	end
	else
		score_0_temp2 <= 8'd0;
end

/*
//[7:0]ROM_Music_Qupu_1_data  [5:0]mode0_Qupu_cnt
//
wire dtw_done;
wire [7:0]dtw_result;
wire [7:0]test_dtw_result = (dtw_done)?((dtw_result > 8'd100)?(8'd100):(dtw_result)):(8'd0);
wire F_ce;
wire [5:0]F_address;
reg [7:0]F_q;

wire R_ce;
wire [5:0]R_address;
reg [7:0]R_q;

always@(posedge fft_clk or negedge rst_n)
begin
	if(!rst_n)
		score_0_temp2		<= 8'd0;
	else if(!key0 && !key1)
	begin
		if(dtw_done)
			score_0_temp2   <= test_dtw_result;
		else
			score_0_temp2	<= score_0_temp2;
	end
	else
		score_0_temp2		<= 8'd0;
end

always@(posedge fft_clk or negedge rst_n)
begin
	if(!rst_n)
		F_q <= 8'd0;
	else if(F_ce)
		F_q <= ROM_Music_Qupu_1_data;
	else
		F_q <= F_q;
end

//mode0_mem[0]
always@(posedge fft_clk or negedge rst_n)
begin
	if(!rst_n)
		R_q <= 8'd0;
	else if(R_ce)
		R_q <= mode0_mem[R_address];
	else
		R_q <= R_q;
end
*/


//******DTW
music_match_0 music_match_0_0 (
  .F1_ce0					(F1_ce0					),            // output wire F1_ce0
  .F2_ce0					(F2_ce0					),            // output wire F2_ce0
  .F3_ce0					(F3_ce0					),            // output wire F3_ce0
  .F4_ce0					(F4_ce0					),            // output wire F4_ce0
  .F5_ce0					(F5_ce0					),            // output wire F5_ce0
  .R_ce0					(R_ce0					),              // output wire R_ce0
  .ap_clk					(fft_clk				),            // input wire ap_clk
  .ap_rst					(!rst_n					),            // input wire ap_rst
  .ap_start					(1'b1					),        // input wire ap_start
  .ap_done					(music_match_done		),          // output wire ap_done
  .ap_idle					(						),          // output wire ap_idle
  .ap_ready					(						),        // output wire ap_ready
  .ap_return				(music_match_result		),      // output wire [7 : 0] ap_return
  .F1_address0				(F1_address0			),  // output wire [5 : 0] F1_address0
  .F1_q0					(F1_q0					),              // input wire [7 : 0] F1_q0
  .F2_address0				(F2_address0			),  // output wire [5 : 0] F2_address0
  .F2_q0					(F2_q0					),              // input wire [7 : 0] F2_q0
  .F3_address0				(F3_address0			),  // output wire [5 : 0] F3_address0
  .F3_q0					(F3_q0					),              // input wire [7 : 0] F3_q0
  .F4_address0				(F4_address0			),  // output wire [5 : 0] F4_address0
  .F4_q0					(F4_q0					),              // input wire [7 : 0] F4_q0
  .F5_address0				(F5_address0			),  // output wire [5 : 0] F5_address0
  .F5_q0					(F5_q0					),              // input wire [7 : 0] F5_q0
  .R_address0				(R_address0				),    // output wire [5 : 0] R_address0
  .R_q0						(R_q0					)                // input wire [7 : 0] R_q0
);
score_match_0 score_match_0_0 (
  .F1_ce0					(F1_ce1					),            // output wire F1_ce0
  .F2_ce0					(F2_ce1					),            // output wire F2_ce0
  .F3_ce0					(F3_ce1					),            // output wire F3_ce0
  .F4_ce0					(F4_ce1					),            // output wire F4_ce0
  .F5_ce0					(F5_ce1					),            // output wire F5_ce0
  .R_ce0					(R_ce1					),              // output wire R_ce0
  .ap_clk					(fft_clk				),            // input wire ap_clk
  .ap_rst					(!rst_n					),            // input wire ap_rst
  .ap_start					(1'b1					),        // input wire ap_start
  .ap_done					(score_match_done		),          // output wire ap_done
  .ap_idle					(						),          // output wire ap_idle
  .ap_ready					(						),        // output wire ap_ready
  .ap_return				(score_match_result		),      // output wire [7 : 0] ap_return
  .F1_address0				(F1_address1			),  // output wire [5 : 0] F1_address0
  .F1_q0					(F1_q1					),              // input wire [7 : 0] F1_q0
  .F2_address0				(F2_address1			),  // output wire [5 : 0] F2_address0
  .F2_q0					(F2_q1					),              // input wire [7 : 0] F2_q0
  .F3_address0				(F3_address1			),  // output wire [5 : 0] F3_address0
  .F3_q0					(F3_q1					),              // input wire [7 : 0] F3_q0
  .F4_address0				(F4_address1			),  // output wire [5 : 0] F4_address0
  .F4_q0					(F4_q1					),              // input wire [7 : 0] F4_q0
  .F5_address0				(F5_address1			),  // output wire [5 : 0] F5_address0
  .F5_q0					(F5_q1					),              // input wire [7 : 0] F5_q0
  .R_address0				(R_address1				),    // output wire [5 : 0] R_address0
  .R_q0						(R_q1					)                // input wire [7 : 0] R_q0
);
//******quku_RAM
RAM_quku1 RAM_quku1_0 (
  .clka(fft_clk),    // input wire clka
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(quku1_i_cnt),  // input wire [5 : 0] addra
  .dina(quku1_i_data),    // input wire [7 : 0] dina
  .clkb(fft_clk),    // input wire clkb
  .addrb(quku1_o_cnt),  // input wire [5 : 0] addrb
  .doutb(quku1_o_data)  // output wire [7 : 0] doutb
);
RAM_quku2 RAM_quku2_0 (
  .clka(fft_clk),    // input wire clka
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(quku2_i_cnt),  // input wire [5 : 0] addra
  .dina(quku2_i_data),    // input wire [7 : 0] dina
  .clkb(fft_clk),    // input wire clkb
  .addrb(quku2_o_cnt),  // input wire [5 : 0] addrb
  .doutb(quku2_o_data)  // output wire [7 : 0] doutb
);
RAM_quku3 RAM_quku3_0 (
  .clka(fft_clk),    // input wire clka
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(quku3_i_cnt),  // input wire [5 : 0] addra
  .dina(quku3_i_data),    // input wire [7 : 0] dina
  .clkb(fft_clk),    // input wire clkb
  .addrb(quku3_o_cnt),  // input wire [5 : 0] addrb
  .doutb(quku3_o_data)  // output wire [7 : 0] doutb
);
RAM_quku4 RAM_quku4_0 (
  .clka(fft_clk),    // input wire clka
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(quku4_i_cnt),  // input wire [5 : 0] addra
  .dina(quku4_i_data),    // input wire [7 : 0] dina
  .clkb(fft_clk),    // input wire clkb
  .addrb(quku4_o_cnt),  // input wire [5 : 0] addrb
  .doutb(quku4_o_data)  // output wire [7 : 0] doutb
);
RAM_quku5 RAM_quku5_0 (
  .clka(fft_clk),    // input wire clka
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(quku5_i_cnt),  // input wire [5 : 0] addra
  .dina(quku5_i_data),    // input wire [7 : 0] dina
  .clkb(fft_clk),    // input wire clkb
  .addrb(quku5_o_cnt),  // input wire [5 : 0] addrb
  .doutb(quku5_o_data)  // output wire [7 : 0] doutb
);
//***************************************************模式二内部算法****************************************************
//计算曲库每首歌总调数
wire [5:0]Qupu_sum = ( music_list_1 == 4'd1)?(Qupu1_sum):
					 ((music_list_1 == 4'd2)?(Qupu2_sum):
					 ((music_list_1 == 4'd3)?(Qupu3_sum):
					 ((music_list_1 == 4'd4)?(Qupu4_sum):
					 ((music_list_1 == 4'd5)?(Qupu5_sum):
					 ( 6'd1	)))));

always@(posedge adc_clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		Qupu1_sum		<= 6'd0;
		Qupu2_sum		<= 6'd0;
		Qupu3_sum		<= 6'd0;
		Qupu4_sum		<= 6'd0;
		Qupu5_sum		<= 6'd0;
		cal_signal		<= 1'b1;
		cal_cnt			<= 6'd0;
	end
	else if(cal_signal)	//计算总调数
	begin
		if(ROM_Music_Qupu_1_data != 8'd0)
			Qupu1_sum <= Qupu1_sum + 6'd1;
		else
			Qupu1_sum <= Qupu1_sum;
		if(ROM_Music_Qupu_2_data != 8'd0)
			Qupu2_sum <= Qupu2_sum + 6'd1;
		else
			Qupu2_sum <= Qupu2_sum;
		if(ROM_Music_Qupu_3_data != 8'd0)
			Qupu3_sum <= Qupu3_sum + 6'd1;
		else
			Qupu3_sum <= Qupu3_sum;
		if(ROM_Music_Qupu_4_data != 8'd0)
			Qupu4_sum <= Qupu4_sum + 6'd1;
		else
			Qupu4_sum <= Qupu4_sum;
		if(ROM_Music_Qupu_5_data != 8'd0)
			Qupu5_sum <= Qupu5_sum + 6'd1;
		else
			Qupu5_sum <= Qupu5_sum;			

		if(cal_cnt <= 6'd60)
			cal_cnt	<= cal_cnt + 6'd1;
		else
			cal_signal <= 1'b0;
	end
	else				//完成计算，待定
	begin
		cal_signal <= 1'b0;
	end
end

wire [15:0]score_1_cnt = {10'd0,mode1_Qupu_cnt};

wire [15:0] score_1_temp = score_1_cnt * 16'd100 / Qupu_sum;
always@(posedge adc_clk or negedge rst_n)
begin
	if(!rst_n)
		score_1 <= 8'd0;
	else if(key0 && key1)
		score_1 <= score_1_temp[7:0];
	else
		score_1 <= 8'd0;
end

reg [31:0]xiaodou_cnt2;
//模式二
always@(posedge adc_clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		select_color			<= 1'b0;
		mode1_state_sub 		<= 1'b0;
		mode1_Qupu_cnt			<= 6'd0;
		
		xiaodou_cnt2			<= 32'd0;
	end
	else if(key0)
	begin
		if(key1)		//启动
			case(mode1_state_sub)
				1'b0:begin	
						if(condition1)
						begin
							if(xiaodou_cnt2 <= 32'd2_000)		//消抖100ms
								xiaodou_cnt2 <= xiaodou_cnt2 + 32'd1;
							else
							begin
								xiaodou_cnt2 <= 32'd0;
								
								if(ROM_Music_Qupu_data != 8'd0 && ROM_Music_Qupu_data == fft_k0)
								begin
									mode1_Qupu_cnt 	<= mode1_Qupu_cnt + 6'd1;	
									select_color	<= 1'b0;		//GREEN
								end
								else
								begin
									mode1_Qupu_cnt 	<= mode1_Qupu_cnt;
									select_color	<= 1'b1;		//RED
								end
								mode1_state_sub <= 1'b1;
							end
						end
						else
							xiaodou_cnt2 <= 32'd0;
					 end
				1'b1:begin //等待下降到THR之下
						if(!condition1)	
						begin
							if(xiaodou_cnt2 <= 32'd2_000)		//消抖100ms
								xiaodou_cnt2 <= xiaodou_cnt2 + 32'd1;
							else
							begin
								xiaodou_cnt2 	<= 32'd0;
								
								mode1_state_sub <= 1'b0;
							end
						end
						else
							xiaodou_cnt2 <= 32'd0;
					 end
				default:begin
							select_color			<= 1'b0;
							mode1_state_sub 		<= 1'b0;
							mode1_Qupu_cnt			<= 6'd0;
							xiaodou_cnt2 			<= 32'd0;
						end
			endcase
		else			//结束
		begin
			select_color			<= 1'b0;
			mode1_state_sub 		<= 1'b0;
			mode1_Qupu_cnt			<= 6'd0;
			xiaodou_cnt2 			<= 32'd0;
		end
	end
	else
	begin
		select_color			<= 1'b0;
		mode1_state_sub 		<= 1'b0;
		mode1_Qupu_cnt			<= 6'd0;
		xiaodou_cnt2 			<= 32'd0;
	end
end

//****************************模式二实时显示 fft_k1************************************************************************************
always@(posedge pclk or negedge rst_n)
begin
	if(!rst_n)
		fft_k1 <= 7'd0;
	else if(key0 && key1)	//模式二启动
		fft_k1 <= ROM_Music_Qupu_data;
	else
		fft_k1 <= 7'd0;
end

//****************************实时刷新显示 fft_k0************************************************************************************
reg [11:0]mode_fft_k;

reg [11:0]Ansys_output_K_mem[0:1];
reg [11:0]max_Ansys_output_data;
reg [3:0]Ansys_state;
reg [11:0]Ansys_output_cnt;
reg Ansys_en; 								// 1:write  0:read
wire [11:0]Ansys_output_data;

wire [11:0]Ansys_cnt;
wire [11:0]Ansys_temp_data;
assign Ansys_output_data = (Ansys_en)?(12'd0):((PARA == 12'd1)?(Ansys_temp_data):((PARA == 12'd2)?({1'd0,Ansys_temp_data[11:1]}):((PARA == 12'd3)?({2'd0,Ansys_temp_data[11:2]}):({3'd0,Ansys_temp_data[11:3]}))));
assign Ansys_cnt = (Ansys_en)?((fft_vga_ram_input_cnt <= 14'd4095)?(fft_vga_ram_input_cnt[11:0]):(12'd0)):(Ansys_output_cnt);

reg [11:0]K_mem_max_data[0:1];
// Ansys_en , Ansys_output_cnt , Ansys_output_data; -> mode_fft_k
always@(posedge fft_clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        Ansys_en 				<= 1'b1;
        Ansys_state 			<= 4'd0;
        max_Ansys_output_data 	<= 12'd0;
        Ansys_output_cnt 		<= 12'd0;
		
        Ansys_output_K_mem[0] 	<= 12'd0;
		Ansys_output_K_mem[1] 	<= 12'd0;
		K_mem_max_data[0]		<= 12'd0;
		K_mem_max_data[1]		<= 12'd0;

		mode_fft_k				<= 12'd0;
    end
    else
    begin
        case(Ansys_state)
			//初始化
            4'd0:begin  
                    if(fft_vga_ram_input_cnt == 14'd16383)
                    begin
						if(key1)
						begin
							Ansys_en 				<= 1'b0;

							Ansys_output_K_mem[0] 	<= 12'd0;
							Ansys_output_K_mem[1] 	<= 12'd0;
							K_mem_max_data[0]		<= 12'd0;
							K_mem_max_data[1]		<= 12'd0;
							
							max_Ansys_output_data 	<= 12'd0;
							Ansys_output_cnt 		<= 12'd260;
							Ansys_state 			<= 4'd1;
						end
						else
						begin
							Ansys_en 				<= 1'b0;

							Ansys_output_K_mem[0] 	<= 12'd0;
							Ansys_output_K_mem[1] 	<= 12'd0;
							K_mem_max_data[0]		<= 12'd0;
							K_mem_max_data[1]		<= 12'd0;
							
							max_Ansys_output_data 	<= 12'd0;
							Ansys_output_cnt 		<= 12'd0;
							Ansys_state 			<= 4'd1;
						end
                    end
                 end
			//找出最大数据
            4'd1:begin		
					if(key1)	
					begin
						if(Ansys_output_cnt <= 12'd840)
						begin
							if(Ansys_output_cnt > 12'd260 && Ansys_output_data > max_Ansys_output_data)
							begin
								max_Ansys_output_data <= Ansys_output_data;
								Ansys_output_K_mem[0] <= Ansys_output_cnt;
							end
							Ansys_output_cnt <= Ansys_output_cnt + 12'd1;
						end
						else
						begin
							K_mem_max_data[0]		<= max_Ansys_output_data;
							
							max_Ansys_output_data 	<= 12'd0;
							Ansys_output_cnt 		<= 12'd260;
							Ansys_state 			<= 4'd3;
						end
					end
					else
					begin
						if(Ansys_output_cnt <= 12'd3500)
						begin
							if(Ansys_output_cnt > 12'd15 && Ansys_output_data > max_Ansys_output_data)
							begin
								max_Ansys_output_data <= Ansys_output_data;
								Ansys_output_K_mem[0] <= Ansys_output_cnt;
							end
							Ansys_output_cnt <= Ansys_output_cnt + 12'd1;
						end
						else
						begin
							K_mem_max_data[0]		<= max_Ansys_output_data;
							
							max_Ansys_output_data 	<= 12'd0;
							Ansys_output_cnt 		<= 12'd0;
							Ansys_state 			<= 4'd3;
						end
					end
                 end
			//数据计算得到mode_fft_k
            4'd3:begin			
					if(key1)
					begin
						if(K_mem_max_data[0] >= THR)
							mode_fft_k <= Ansys_output_K_mem[0];
						else
							mode_fft_k <= 12'd0;
						
						Ansys_state <= 4'd13;
					end
					else
					begin
						if(K_mem_max_data[0] >= THR)
							mode_fft_k <= Ansys_output_K_mem[0];
						else
							mode_fft_k <= 12'd0;
						
						Ansys_state <= 4'd13;
					end
                  end
            4'd13:begin
                     if(fft_vga_ram_input_cnt == 14'd16383)
                     begin
                         Ansys_en 		<= 1'b1;
                         Ansys_state 	<= 4'd0;
                     end
                  end  
			default:begin
						Ansys_state 	<= 4'd13;
					end	
        endcase
    end 
end

//fft_k0实时刷新
always@(posedge pclk or negedge rst_n)
begin
	if(!rst_n)
	begin
		fft_k0 <= 7'd0;
	end
	else if(pos_y == 12'd150)
	begin
		fft_k0 <= o_fft_K(mode_fft_k);
	end
	else
	begin
		fft_k0 <= fft_k0;
	end
end

Ansys_FFT_RAM Ansys_FFT_RAM_0 (
  .a(Ansys_cnt),      // input wire [11 : 0] a
  .d(fft_data),      // input wire [11 : 0] d
  .clk(fft_clk),  // input wire clk
  .we(Ansys_en),    // input wire we 
  .spo(Ansys_temp_data)  // output wire [11 : 0] spo
);


//曲库
ROM_Music_Qupu_1 ROM_Music_Qupu_1_0 (
  .a(ROM_Music_Qupu_1_cnt),      // input wire [5 : 0] a
  .spo(ROM_Music_Qupu_1_data)  // output wire [7 : 0] spo
);
ROM_Music_Qupu_2 ROM_Music_Qupu_2_0 (
  .a(ROM_Music_Qupu_2_cnt),      // input wire [5 : 0] a
  .spo(ROM_Music_Qupu_2_data)  // output wire [7 : 0] spo
);
ROM_Music_Qupu_3 ROM_Music_Qupu_3_0 (
  .a(ROM_Music_Qupu_3_cnt),      // input wire [5 : 0] a
  .spo(ROM_Music_Qupu_3_data)  // output wire [7 : 0] spo
);
ROM_Music_Qupu_4 ROM_Music_Qupu_4_0 (
  .a(ROM_Music_Qupu_4_cnt),      // input wire [5 : 0] a
  .spo(ROM_Music_Qupu_4_data)  // output wire [7 : 0] spo
);
ROM_Music_Qupu_5 ROM_Music_Qupu_5_0 (
  .a(ROM_Music_Qupu_5_cnt),      // input wire [5 : 0] a
  .spo(ROM_Music_Qupu_5_data)  // output wire [7 : 0] spo
);


endmodule
