module Top(
    input sys_clk,
    input rst_n,
    //adc_data
    input [11:0]adc_data,
    output adc_clk,
    //VGA port
    output [4:0]rgb_r,
    output [5:0]rgb_g,
    output [4:0]rgb_b,
    output  hs,
    output  vs,
    //key
    input key_0,        //选择 模式
    input key_1,        //选择 开始 or 结束
    input key_2,        //选择THR or PARA模式 or 模式二歌曲选择
    input key_3,        //THR or PARA or 歌曲 加
    input key_4,        //THR or PARA or 歌曲 减
	//7_seg
    output [3:0]AN,		//片选
    output [7:0]C,		//段选
	//led
	output led0,		//THR
	output led1,		//PARA
	output led2,		//模式二歌曲选择
	output led3			//显示采集到的缓存数据
    /*
    //test
    */
    );
//******************************按键开始******************************  
//待控制变量
reg [7:0]THR;
reg [11:0]PARA;
reg key0;
reg key1;
reg [1:0]key2;
wire [3:0]music_list_0;		//模式一(7(全黑),0   1,2,3,4,5)
wire [7:0]score_0;		
wire [7:0]score_1;	
reg [3:0]music_list_1;		//模式二(6   1,2,3,4,5)
wire [3:0]music_list = (key0)?(music_list_1):(music_list_0);
wire [7:0]score = (key0)?(score_1):(score_0);

//按键模块
wire key0_flag;
wire key1_flag;
wire key2_flag;
wire key3_flag;
wire key4_flag;

always@(posedge sys_clk or negedge rst_n)
begin
    if(!rst_n)
    begin
		key2 <= 2'd0;
    end  
	else if(key1 && !key0)
	begin
		key2 <= 2'd3;
	end
	else if(key1 && key0)
	begin
		key2 <= 2'd2;
	end
    else if(key2_flag)
	begin
		key2 <= key2 + 2'd1;
    end	    
    else
    begin
        key2 <= key2;
    end
end
assign led0 = (key2 == 2'd0);
assign led1 = (key2 == 2'd1);
assign led2 = (key2 == 2'd2);
assign led3 = (key2 == 2'd3);
always@(posedge sys_clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        THR 		 <= 8'd40;
        PARA 		 <= 12'd1;
    end    
    else if(led0)
    begin
        if(key3_flag && THR < 8'd160)
			THR <= THR + 8'd5;
		else if(key4_flag && THR > 8'd0)
			THR <= THR - 8'd5;
		else
			THR <= THR;
    end
    else if(led1)
	begin
		if(key4_flag && PARA < 12'd4)
			PARA <= PARA + 12'd1;
		else if(key3_flag && PARA > 12'd1)
			PARA <= PARA - 12'd1;
		else
			PARA <= PARA;
	end
	else
	begin
		THR  <= THR;
		PARA <= PARA;
	end
end

always@(posedge sys_clk or negedge rst_n)
begin
    if(!rst_n)
    begin
		music_list_1 <= 4'd6;
    end   
	else if((key0 && key1_flag && key1 == 1'b1) || (key0_flag && key0 == 1'b0))
		music_list_1 <= 4'd6;
	else if(key0 && led2 && key3_flag && key1 == 1'b0)
	begin
		if(music_list_1 == 4'd5 || music_list_1 == 4'd6)
			music_list_1 <= 4'd1;
		else
			music_list_1 <= music_list_1 + 4'd1;
	end
	else if(key0 && led2 && key4_flag && key1 == 1'b0)
	begin
		if(music_list_1 == 4'd1 || music_list_1 == 4'd6)
			music_list_1 <= 4'd5;
		else
			music_list_1 <= music_list_1 - 4'd1;
	end
	else
	begin
		music_list_1 <= music_list_1;
	end
end

always@(posedge sys_clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        key0 <= 1'b0;
        key1 <= 1'b0;
    end    
    else if(key0_flag && !key1)
        key0 <= ~key0;
    else if(key1_flag)
	begin
		if(!key0)
			key1 <= ~key1;
		else
		begin
			if(music_list >= 4'd1 && music_list <= 4'd5)
				key1 <= ~key1;
			else
				key1 <= key1;
		end
	end
    else
    begin
        key0 <= key0;
        key1 <= key1;
    end
end

key_debounce key_debounce_0(sys_clk,rst_n,key_0,key0_flag);
key_debounce key_debounce_1(sys_clk,rst_n,key_1,key1_flag);
key_debounce key_debounce_2(sys_clk,rst_n,key_2,key2_flag);
key_debounce key_debounce_3(sys_clk,rst_n,key_3,key3_flag);
key_debounce key_debounce_4(sys_clk,rst_n,key_4,key4_flag);
//******************************按键结束******************************  
wire [11:0]pos_x;
wire [11:0]pos_y;
wire video_active;
wire pclk;  
//******************************adc_clk******************************  
reg adc_clk_d0;
reg [31:0]adc_clk_cnt;
assign adc_clk = adc_clk_d0;
always@(posedge sys_clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        adc_clk_d0 <= 1'b0;
        adc_clk_cnt <= 32'd0;
    end
    else if(adc_clk_cnt == 32'd2499) // 20KHZ
    begin
        adc_clk_cnt <= 32'd0;
        adc_clk_d0 <= ~adc_clk_d0;
    end
    else
    begin
        adc_clk_cnt <= adc_clk_cnt + 32'd1;
        adc_clk_d0 <= adc_clk_d0;
    end
end
//******************************adc_clk-over******************************
//******************************FFT******************************
wire fft_clk;
assign fft_clk = sys_clk;
reg [13:0]adc_fft_ram_input_cnt;
reg [13:0]adc_fft_ram_output_cnt;
wire [11:0]adc_fft_ram_output_data;
reg flag_ini_adc;
wire [11:0]adc_data_d0 = (flag_ini_adc == 1'b1)?(adc_data):(12'd2048);
ADC_FFT_RAM ADC_FFT_RAM_0 (
  .clka(adc_clk),    // input wire clka
  .wea(1'b1),      // input wire [0 : 0] wea
  .addra(adc_fft_ram_input_cnt),  // input wire [13 : 0] addra
  .dina(adc_data_d0),    // input wire [11 : 0] dina
  .clkb(fft_clk),    // input wire clkb
  .addrb(adc_fft_ram_output_cnt),  // input wire [13 : 0] addrb
  .doutb(adc_fft_ram_output_data)  // output wire [11 : 0] doutb
);

always@(posedge adc_clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        adc_fft_ram_input_cnt <= 14'd0;
        flag_ini_adc <= 1'b0;
    end
    else if(flag_ini_adc == 1'b0)
    begin
        adc_fft_ram_input_cnt <= adc_fft_ram_input_cnt + 14'd1;
        if(adc_fft_ram_input_cnt == 14'd16383)
            flag_ini_adc <= 1'b1;
    end
    else
    begin
        if(adc_fft_ram_input_cnt < 14'd16383)
            adc_fft_ram_input_cnt <= adc_fft_ram_input_cnt + 14'd1;
        else
            adc_fft_ram_input_cnt <= 14'd0;
    end
end


always@(posedge fft_clk or negedge rst_n)
begin
    if(!rst_n)
        adc_fft_ram_output_cnt <= 14'd0;
    else
        adc_fft_ram_output_cnt <= adc_fft_ram_output_cnt + 14'd1;
end
wire[11:0]fft_data;
wire fft_data_valid;
FFT_transfer    FFT_transfer_0(
    .fft_clk                            (fft_clk                ),//FFT模块时钟      
    .rst_n                              (rst_n                  ),
                           
    .fft_input_data                     (adc_fft_ram_output_data),//FFT模块输入数据                 
    .fft_input_valid                    (1'b1                   ),
    .fft_input_ready                    (                       ),
    
    .fft_output_data                    (fft_data               ),//FFT模块输出数据                         
    .fft_data_valid                     (fft_data_valid         ),//                                
    .fft_output_ready                   (1'b1                   )
    );
//******************************FFT_over******************************
//******************************FFT后端处理算法******************************
reg [13:0]fft_vga_ram_input_cnt;

wire select_color;
//显示缓存
wire [6:0]fft_K[0:1];

//调用智能识别模块
Inteligent_recog	Inteligent_recog_0(
	.fft_clk					(fft_clk				),
	.rst_n						(rst_n					),
	.pclk						(pclk					),
	.adc_clk					(adc_clk				),

	.music_list_1				(music_list_1			),
	.key0						(key0					),			//0:模式一    1:模式二
	.key1						(key1					),			//0:停止      1:启动
	
	.fft_vga_ram_input_cnt		(fft_vga_ram_input_cnt	),
	.fft_data					(fft_data				),
	.THR						(THR					),
	.PARA						(PARA					),
	.pos_x						(pos_x					),
	.pos_y						(pos_y					),
	
	.score_0					(score_0				),			//模式一识别得分
	.score_1					(score_1				),			//模式二学习进度
	.music_list_0				(music_list_0			),			//0:识别中；1~5:五首歌曲,7:全黑
	.fft_k0						(fft_K[0]				),			//当前弹奏的琴键
	.fft_k1						(fft_K[1]				),			//学习模式下标准琴键
	.select_color				(select_color			),
	
	.AN							(AN						),
	.C							(C						),
	
	//test
	.led3						(led3					),
	.key3_flag					(key3_flag				),
	.key4_flag					(key4_flag				)
	
    );

//******************************FFT后端处理算法_over******************************
//******************************VGA******************************
parameter WRITE     = 16'hFFFF;     //白色 
parameter BLACK     = 16'h0;        //黑色
parameter RED       = 16'hF800;     //红色
parameter ORANGE    = 16'hFB00;     //橙色
parameter YELLOW    = 16'hFFE0;     //黄色
parameter GREEN     = 16'h07E0;     //绿色
parameter BLUE      = 16'h001F;     //蓝色
parameter CYAN      = 16'h07FF;     //青色
parameter VIOLET    = 16'h780F;     //紫色
parameter PLUM_RED  = 16'hDD1B;     //梅红色
parameter BROWN     = 16'h8145;     //棕色
parameter WOOD      = 16'hBB83;     //木色
parameter GRAY      = 16'h7BCF;     //灰色
    
//wire pclk;  
  clk_wiz_0 instance_name
 (
  .pclk(pclk),  
  .clk_in(sys_clk)
  );   
/*   
wire [11:0]pos_x;
wire [11:0]pos_y;
wire video_active;
*/
//******VGA第一层
reg [15:0]pixel_color_d0;
always@(posedge pclk or negedge rst_n)
begin
    if(!rst_n)
        pixel_color_d0 <= 16'h0; //黑色
    else if(video_active)
    begin
        if(pos_x <= 12'd100)
            pixel_color_d0 <= RED;
        else if(pos_x <= 12'd200)
            pixel_color_d0 <= PLUM_RED;
        else if(pos_x <= 12'd300)
            pixel_color_d0 <= ORANGE;
        else if(pos_x <= 12'd400)
            pixel_color_d0 <= VIOLET;
        else if(pos_x <= 12'd500)
            pixel_color_d0 <= YELLOW;
        else if(pos_x <= 12'd600)
            pixel_color_d0 <= CYAN;
        else if(pos_x <= 12'd700)
            pixel_color_d0 <= PLUM_RED;
        else if(pos_x <= 12'd800)
            pixel_color_d0 <= BROWN;
        else if(pos_x <= 12'd900)
            pixel_color_d0 <= BLUE;
        else if(pos_x <= 12'd1000)
            pixel_color_d0 <= PLUM_RED;
        else if(pos_x <= 12'd1100)
            pixel_color_d0 <= CYAN;
        else if(pos_x <= 12'd1200)
            pixel_color_d0 <= YELLOW;
        else if(pos_x <= 12'd1300)
            pixel_color_d0 <= VIOLET;
        else if(pos_x <= 12'd1400)
            pixel_color_d0 <= ORANGE;
        else if(pos_x <= 12'd1500)
            pixel_color_d0 <= RED; 
        else
            pixel_color_d0 <= PLUM_RED;
    end
    else
        pixel_color_d0 <= 16'h0; //黑色
end  

//******VGA第二层
wire region_active;     //两个黑窗
assign region_active = ((pos_x >= 12'd11 && pos_x <= 12'd1590) && ((pos_y >= 12'd6 && pos_y <= 12'd35) || (pos_y >= 12'd41 && pos_y <= 12'd310) || (pos_y >= 12'd331 && pos_y <= 12'd850) || (pos_y >= 12'd861 && pos_y <= 12'd890)));

reg [15:0]pixel_color_d1;
//顶部汉字显示缓存
reg [10:0]ROM_Top_Left_cnt;
wire [15:0]ROM_Top_Left_data;
reg [12:0]ROM_Top_Mid_cnt;
wire [15:0]ROM_Top_Mid_data;
reg [12:0]ROM_Top_Right_cnt;
wire [15:0]ROM_Top_Right_data;
ROM_Top_Left ROM_Top_Left_0 (
  .a(ROM_Top_Left_cnt),      // input wire [10 : 0] a
  .spo(ROM_Top_Left_data)  // output wire [15 : 0] spo
);
ROM_Top_Mid ROM_Top_Mid_0 (
  .a(ROM_Top_Mid_cnt),      // input wire [12 : 0] a
  .spo(ROM_Top_Mid_data)  // output wire [15 : 0] spo
);
ROM_Top_Right ROM_Top_Right_0 (
  .a(ROM_Top_Right_cnt),      // input wire [12 : 0] a
  .spo(ROM_Top_Right_data)  // output wire [15 : 0] spo
);

always@(posedge pclk or negedge rst_n)
begin
    if(!rst_n)
    begin
        ROM_Top_Left_cnt  <= 11'd0;
        ROM_Top_Mid_cnt   <= 13'd0;
        ROM_Top_Right_cnt <= 13'd0;
    end
    else if(pos_y >= 12'd11 && pos_y <= 12'd30)
    begin
        if(pos_x >= 12'd12 && pos_x <= 12'd71)
        begin
            ROM_Top_Left_cnt  <= ROM_Top_Left_cnt + 11'd1;
            ROM_Top_Mid_cnt   <= ROM_Top_Mid_cnt;
            ROM_Top_Right_cnt <= ROM_Top_Right_cnt;
        end
        else if(pos_x >= 12'd691 && pos_x <= 12'd910)
        begin
            ROM_Top_Left_cnt  <= ROM_Top_Left_cnt;
            ROM_Top_Mid_cnt   <= ROM_Top_Mid_cnt + 13'd1;
            ROM_Top_Right_cnt <= ROM_Top_Right_cnt;
        end
        else if(pos_x >= 12'd1370 && pos_x <= 12'd1589)
        begin
            ROM_Top_Left_cnt  <= ROM_Top_Left_cnt;
            ROM_Top_Mid_cnt   <= ROM_Top_Mid_cnt;
            ROM_Top_Right_cnt <= ROM_Top_Right_cnt + 13'd1;
        end
        else
        begin
            ROM_Top_Left_cnt  <= ROM_Top_Left_cnt;
            ROM_Top_Mid_cnt   <= ROM_Top_Mid_cnt;
            ROM_Top_Right_cnt <= ROM_Top_Right_cnt;
        end
    end
    else
    begin
        ROM_Top_Left_cnt  <= 11'd0;
        ROM_Top_Mid_cnt   <= 13'd0;
        ROM_Top_Right_cnt <= 13'd0;
    end
end
//底部汉字显示缓存
reg [12:0]ROM_Bottom_Mid_cnt;
wire [15:0]ROM_Bottom_Mid_data;
ROM_Bottom_Mid your_instance_name (
  .a(ROM_Bottom_Mid_cnt),      // input wire [12 : 0] a
  .spo(ROM_Bottom_Mid_data)  // output wire [15 : 0] spo
);
always@(posedge pclk or negedge rst_n)
begin
    if(!rst_n)
    begin
        ROM_Bottom_Mid_cnt   <= 13'd0;
    end
    else if(pos_y >= 12'd866 && pos_y <= 12'd885)
    begin
        if(pos_x >= 12'd630 && pos_x <= 12'd969)
        begin
            ROM_Bottom_Mid_cnt  <= ROM_Bottom_Mid_cnt + 13'd1;
        end
        else
        begin
            ROM_Bottom_Mid_cnt  <= ROM_Bottom_Mid_cnt;
        end
    end
    else
    begin
        ROM_Bottom_Mid_cnt   <= 13'd0;
    end
end
//中间区域模式显示
reg [12:0]ROM_Mode1_cnt;
wire [15:0]ROM_Mode1_data_d0;
wire [15:0]ROM_Mode1_data = (key0)?(ROM_Mode1_data_d0):((ROM_Mode1_data_d0 == 16'h0)?(~GREEN):(16'hffff));
ROM_Mode1 ROM_Mode1_0 (
  .a(ROM_Mode1_cnt),      // input wire [12 : 0] a
  .spo(ROM_Mode1_data_d0)  // output wire [15 : 0] spo
);
reg [11:0]ROM_Mode2_cnt;
wire [15:0]ROM_Mode2_data_d0;
wire [15:0]ROM_Mode2_data = (key0)?((ROM_Mode2_data_d0 == 16'h0)?(~GREEN):(16'hffff)):(ROM_Mode2_data_d0);
ROM_Mode2 ROM_Mode2_0 (
  .a(ROM_Mode2_cnt),      // input wire [11 : 0] a
  .spo(ROM_Mode2_data_d0)  // output wire [15 : 0] spo
);
always@(posedge pclk or negedge rst_n)
begin
    if(!rst_n)
    begin
        ROM_Mode1_cnt   <= 13'd0;
        ROM_Mode2_cnt   <= 12'd0;
    end
    else if(pos_y >= 12'd151 && pos_y <= 12'd170)
    begin
        if(pos_x >= 12'd21 && pos_x <= 12'd260)
        begin
            ROM_Mode1_cnt <= ROM_Mode1_cnt + 13'd1;
            ROM_Mode2_cnt <= ROM_Mode2_cnt;
        end
        else if(pos_x >= 12'd301 && pos_x <= 12'd460)
        begin
            ROM_Mode1_cnt <= ROM_Mode1_cnt;
            ROM_Mode2_cnt <= ROM_Mode2_cnt + 12'd1;
        end
        else
        begin
            ROM_Mode1_cnt <= ROM_Mode1_cnt;
            ROM_Mode2_cnt <= ROM_Mode2_cnt;
        end
    end
    else
    begin
        ROM_Mode1_cnt   <= 13'd0;
        ROM_Mode2_cnt   <= 12'd0;
    end
end
//中间汉字显示缓存
reg [12:0]ROM_Mid_High_cnt;
reg [12:0]ROM_Mid_Low_cnt;

wire [12:0]ROM_Mid_High_1_cnt = ROM_Mid_High_cnt;
wire [15:0]ROM_Mid_High_1_data;
ROM_Mid_High ROM_Mid_High_0 (
  .a(ROM_Mid_High_1_cnt),      // input wire [12 : 0] a
  .spo(ROM_Mid_High_1_data)  // output wire [15 : 0] spo
);
wire [12:0]ROM_Mid_Low_1_cnt = ROM_Mid_Low_cnt;
wire [15:0]ROM_Mid_Low_1_data;
ROM_Mid_Low ROM_Mid_Low_0 (
  .a(ROM_Mid_Low_1_cnt),      // input wire [12 : 0] a
  .spo(ROM_Mid_Low_1_data)  // output wire [15 : 0] spo
);
wire [12:0]ROM_Mid_High_2_cnt = ROM_Mid_High_cnt;
wire [15:0]ROM_Mid_High_2_data;
ROM_Mid_High_2 ROM_Mid_High_2_0 (
  .a(ROM_Mid_High_2_cnt),      // input wire [12 : 0] a
  .spo(ROM_Mid_High_2_data)  // output wire [15 : 0] spo
);
wire [12:0]ROM_Mid_Low_2_cnt = ROM_Mid_Low_cnt;
wire [15:0]ROM_Mid_Low_2_data;
ROM_Mid_Low_2 ROM_Mid_Low_2_0 (
  .a(ROM_Mid_Low_2_cnt),      // input wire [12 : 0] a
  .spo(ROM_Mid_Low_2_data)  // output wire [15 : 0] spo
);
wire [15:0]ROM_Mid_High_data = (key0)?(ROM_Mid_High_2_data):(ROM_Mid_High_1_data);
wire [15:0]ROM_Mid_Low_data  = (key0)?(ROM_Mid_Low_2_data):(ROM_Mid_Low_1_data);
always@(posedge pclk or negedge rst_n)
begin
    if(!rst_n)
    begin
        ROM_Mid_High_cnt   <= 13'd0;
        ROM_Mid_Low_cnt    <= 13'd0;
    end
    else if(pos_y >= 12'd181 && pos_y <= 12'd220)
    begin
        if(pos_x >= 12'd21 && pos_x <= 12'd220)
        begin
            ROM_Mid_High_cnt  <= ROM_Mid_High_cnt + 13'd1;
        end
        else
        begin
            ROM_Mid_High_cnt  <= ROM_Mid_High_cnt;
        end
    end
    else if(pos_y >= 12'd241 && pos_y <= 12'd280)
    begin
        if(pos_x >= 12'd21 && pos_x <= 12'd220)
        begin
            ROM_Mid_Low_cnt  <= ROM_Mid_Low_cnt + 13'd1;
        end
        else
        begin
            ROM_Mid_Low_cnt  <= ROM_Mid_Low_cnt;
        end
    end
    else
    begin
        ROM_Mid_High_cnt   <= 13'd0;
        ROM_Mid_Low_cnt    <= 13'd0;
    end
end
reg [9:0]ROM_Mid_Low_2_l_cnt;
wire [15:0]ROM_Mid_Low_2_l_data_d0;
wire [15:0]ROM_Mid_Low_2_l_data = (key0)?(ROM_Mid_Low_2_l_data_d0):(~BLACK);
ROM_Mid_Low_2_l ROM_Mid_Low_2_l_0 (
  .a(ROM_Mid_Low_2_l_cnt),      // input wire [9 : 0] a
  .spo(ROM_Mid_Low_2_l_data_d0)  // output wire [15 : 0] spo
);
always@(posedge pclk or negedge rst_n)
begin
    if(!rst_n)
        ROM_Mid_Low_2_l_cnt <= 10'd0;
    else if(pos_y >= 12'd241 && pos_y <= 12'd280)
    begin
        if(pos_x >= 12'd281 && pos_x <= 12'd300)
            ROM_Mid_Low_2_l_cnt <= ROM_Mid_Low_2_l_cnt + 10'd1;
        else
            ROM_Mid_Low_2_l_cnt <= ROM_Mid_Low_2_l_cnt;
    end
    else
        ROM_Mid_Low_2_l_cnt <= 10'd0;
end
//中间区域启动圆点
reg [10:0]ROM_Circle_cnt;
wire [15:0]ROM_Circle_data_d0;
wire [15:0]ROM_Circle_data = (key1)?((ROM_Circle_data_d0 == 16'h0)?(~GREEN):(16'hffff)):(ROM_Circle_data_d0);
ROM_Circle ROM_Circle (
  .a(ROM_Circle_cnt),      // input wire [10 : 0] a
  .spo(ROM_Circle_data_d0)  // output wire [15 : 0] spo
);
always@(posedge pclk or negedge rst_n)
begin
    if(!rst_n)
        ROM_Circle_cnt <= 11'd0;
    else if(pos_y >= 12'd211 && pos_y <= 12'd250)
    begin
        if(pos_x >= 12'd711 && pos_x <= 12'd750)
            ROM_Circle_cnt <= ROM_Circle_cnt + 11'd1;
        else
            ROM_Circle_cnt <= ROM_Circle_cnt;
    end
    else
        ROM_Circle_cnt <= 11'd0;
end
//识别结果缓存
wire [15:0]music_list_data;
wire [15:0]score_data;
Result_Display  Result_Display_0(
    music_list,
    score,
    
    pclk,
    rst_n,
    pos_x,
    pos_y,
    
    music_list_data,
    score_data
    );
//VGA像素显示
always@(posedge pclk or negedge rst_n)
begin
    if(!rst_n)
        pixel_color_d1 <= 16'h0;
    else if(region_active)
    begin
        //界面顶部标题
        if(pos_y >= 12'd6 && pos_y <= 12'd35)
        begin
            if(pos_y >= 12'd11 && pos_y <= 12'd30)
            begin
                if(pos_x >= 12'd12 && pos_x <= 12'd71)
                    pixel_color_d1 <= ~ROM_Top_Left_data;
                else if(pos_x >= 12'd691 && pos_x <= 12'd910)
                    pixel_color_d1 <= ~ROM_Top_Mid_data;
                else if(pos_x >= 12'd1370 && pos_x <= 12'd1589)
                    pixel_color_d1 <= ~ROM_Top_Right_data;
                else
                    pixel_color_d1 <= BLACK;
            end
            else
            begin
                pixel_color_d1 <= BLACK;
            end
        end
        //钢琴白底界面
        else if(pos_x >= 12'd16 && pos_x <= 12'd1585 && pos_y >= 12'd46 && pos_y <= 12'd145)
        begin
            if(pos_x >= 12'd21 && pos_x <= 12'd1580 && pos_y >= 12'd51 && pos_y <= 12'd140)
            begin
                if((pos_x - 12'd20)%30 == 0)
                    pixel_color_d1 <= BLACK;
                else
                    pixel_color_d1 <= WRITE;
            end
            else
                pixel_color_d1 <= WOOD;
        end
        //中部汉字显示窗口 && 波形显示窗口
        else if(pos_x >= 12'd16 && pos_x <= 12'd1585 && pos_y >= 12'd151 && pos_y <= 12'd300)
        begin
            //模式
            if     (pos_y >= 12'd151 && pos_y <= 12'd170 && pos_x >= 12'd21  && pos_x <= 12'd260)
                pixel_color_d1 <= ~ROM_Mode1_data;
            else if(pos_y >= 12'd151 && pos_y <= 12'd170 && pos_x >= 12'd301  && pos_x <= 12'd460)
                pixel_color_d1 <= ~ROM_Mode2_data;
            //识别结果 or 学习歌曲
            else if(pos_y >= 12'd181 && pos_y <= 12'd220 && pos_x >= 12'd21  && pos_x <= 12'd220)
                pixel_color_d1 <= ~ROM_Mid_High_data;
            else if(pos_y >= 12'd181 && pos_y <= 12'd220 && pos_x >= 12'd221 && pos_x <= 12'd620)
                pixel_color_d1 <= ~music_list_data;
            //得分    or 学习进度
            else if(pos_y >= 12'd241 && pos_y <= 12'd280 && pos_x >= 12'd21  && pos_x <= 12'd220)
                pixel_color_d1 <= ~ROM_Mid_Low_data;
            else if(pos_y >= 12'd241 && pos_y <= 12'd280 && pos_x >= 12'd221 && pos_x <= 12'd280)
                pixel_color_d1 <= ~score_data;
            else if(pos_y >= 12'd241 && pos_y <= 12'd280 && pos_x >= 12'd281 && pos_x <= 12'd300)
                pixel_color_d1 <= ~ROM_Mid_Low_2_l_data;
            //启动圆
            else if(pos_y >= 12'd211 && pos_y <= 12'd250 && pos_x >= 12'd711  && pos_x <= 12'd750)
                pixel_color_d1 <= ~ROM_Circle_data;
            //波形显示窗口
            else if(pos_y >= 12'd151 && pos_y <= 12'd300 && pos_x >= 12'd801 && pos_x <= 12'd1585)
            begin
                if(pos_y >= 12'd156 && pos_y <= 12'd295 && pos_x >= 12'd806 && pos_x <= 12'd1580)
                begin
                    if(pos_y == 12'd161 || pos_y == 12'd290 || (pos_y == 12'd225 && pos_x%2 == 0) ||
                       (pos_y > 12'd161 && pos_y < 12'd290 && pos_y%2 == 0 && (pos_x - 12'd805)%20 == 0))
                        pixel_color_d1 <= WRITE;
                    else
                        pixel_color_d1 <= BLACK;
                end
                else
                    pixel_color_d1 <= BLUE;
            end
            else
                pixel_color_d1 <= BLACK;
        end
        //频谱显示窗口
        else if( (pos_x - 12'd10 <= 12'd1500 && (pos_y == 12'd340 || pos_y == 12'd500 || pos_y == 12'd510 || pos_y == 12'd670 || (pos_y == 12'd420 && pos_x%2 == 0) || (pos_y == 12'd590 && pos_x%2 == 0))) ||
                 (pos_x - 12'd10 <= 12'd1100 && (pos_y == 12'd680 || pos_y == 12'd840 || (pos_y == 12'd760 && pos_x%2 == 0)))
               )
            pixel_color_d1 <= WRITE;
        else if( (pos_x - 12'd10 <= 12'd1500 && ( ((pos_x - 12'd10)%10 == 0 && pos_y >= 12'd495 && pos_y < 12'd500) || ((pos_x - 12'd10)%50 == 0 && pos_y >= 12'd490 && pos_y < 12'd500) )) ||
                 (pos_x - 12'd10 <= 12'd1500 && ( ((pos_x - 12'd10)%10 == 0 && pos_y >= 12'd665 && pos_y < 12'd670) || ((pos_x - 12'd10)%50 == 0 && pos_y >= 12'd660 && pos_y < 12'd670) )) ||
                 (pos_x - 12'd10 <= 12'd1100 && ( ((pos_x - 12'd10)%10 == 0 && pos_y >= 12'd835 && pos_y < 12'd840) || ((pos_x - 12'd10)%50 == 0 && pos_y >= 12'd830 && pos_y < 12'd840) ))
               )
            pixel_color_d1 <= WRITE;
        //底部汉字显示界面
        else if(pos_y >= 12'd861 && pos_y <= 12'd890)
        begin
            if(pos_x >= 12'd630 && pos_x <= 12'd969)
                pixel_color_d1 <= ~ROM_Bottom_Mid_data;
            else
                pixel_color_d1 <= BLACK;
        end
        //
        else
            pixel_color_d1 <= BLACK;
    end
    else
        pixel_color_d1 <= pixel_color_d0;
end
//********ADC->VGA
wire adc_wave_active = (pos_y >= 12'd161 && pos_y <= 12'd290 && pos_x >= 12'd806 && pos_x <= 12'd1580);
reg [10:0]adc_vga_ram_input_cnt;
reg [10:0]adc_vga_ram_output_cnt;
wire [11:0]adc_vga_ram_output_data;
ADC_VGA_RAM ADC_VGA_RAM_0 (
          .clka(adc_clk),    // input wire clka
          .wea(1'b1),      // input wire [0 : 0] wea
          .addra(adc_vga_ram_input_cnt),  // input wire [10 : 0] addra
          .dina(adc_data),    // input wire [11 : 0] dina
          .clkb(pclk),    // input wire clkb
          .addrb(adc_vga_ram_output_cnt),  // input wire [10 : 0] addrb
          .doutb(adc_vga_ram_output_data)  // output wire [11 : 0] doutb
);
always@(posedge adc_clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        adc_vga_ram_input_cnt <= 11'd0;
    end
    else
    begin
        adc_vga_ram_input_cnt <= adc_vga_ram_input_cnt + 11'd1;
    end
end
always@(posedge pclk)
begin
    if(adc_wave_active)
        adc_vga_ram_output_cnt <= adc_vga_ram_output_cnt + 11'd1;
    else
        adc_vga_ram_output_cnt <= 11'd0;    
end
reg[11:0]adc_vga_ram_output_data_d0;
always@(posedge pclk)
begin
    if(adc_wave_active)
    begin
        adc_vga_ram_output_data_d0 <= adc_vga_ram_output_data;
    end
    else
    begin
        adc_vga_ram_output_data_d0 <= 12'd0;
    end
end
//********FFT->VGA
//reg [13:0]fft_vga_ram_input_cnt;
reg [13:0]fft_vga_ram_output_cnt;
wire [11:0]fft_vga_ram_output_data;
FFT_VGA_RAM FFT_VGA_RAM_0 (
  .clka(fft_clk),    // input wire clka
  .wea(1'b1),      // input wire [0 : 0] wea
  .addra(fft_vga_ram_input_cnt),  // input wire [13 : 0] addra
  .dina(fft_data),    // input wire [11 : 0] dina
  .clkb(pclk),    // input wire clkb
  .addrb(fft_vga_ram_output_cnt),  // input wire [13 : 0] addrb
  .doutb(fft_vga_ram_output_data)  // output wire [11 : 0] doutb
);
always@(posedge fft_clk or negedge rst_n)
begin
    if(!rst_n)
        fft_vga_ram_input_cnt <= 14'd0;
    else if(fft_data_valid)
        fft_vga_ram_input_cnt <= fft_vga_ram_input_cnt + 14'd1;
    else
        fft_vga_ram_input_cnt <= 14'd0;
end
wire fft_region_active_1;
wire fft_region_active_2;
wire fft_region_active_3;
assign fft_region_active_1 = (pos_x - 12'd10 <= 12'd1500 && pos_x - 12'd10 >= 12'd1);
assign fft_region_active_2 = (pos_x - 12'd10 <= 12'd1500 && pos_x - 12'd10 >= 12'd1);
assign fft_region_active_3 = (pos_x - 12'd10 <= 12'd1096 && pos_x - 12'd10 >= 12'd1);
always@(posedge pclk)
begin
    if(pos_y > 12'd340 && pos_y <= 12'd500)
    begin
        if(fft_region_active_1)
            fft_vga_ram_output_cnt <= fft_vga_ram_output_cnt + 14'd1;
        else
            fft_vga_ram_output_cnt <= 14'd0;
    end
    else if(pos_y > 12'd510 && pos_y <= 12'd670)
    begin
        if(fft_region_active_2)
            fft_vga_ram_output_cnt <= fft_vga_ram_output_cnt + 14'd1;
        else
            fft_vga_ram_output_cnt <= 14'd1500;
    end
    else if(pos_y > 12'd680 && pos_y <= 12'd840)
    begin
        if(fft_region_active_3)
            fft_vga_ram_output_cnt <= fft_vga_ram_output_cnt + 14'd1;
        else
            fft_vga_ram_output_cnt <= 14'd3000;
    end
    else
        fft_vga_ram_output_cnt <= 14'd0;
end
//parameter PARA = 12'd1;
wire[11:0]fft_output_data;
assign fft_output_data = (PARA == 12'd1)?(fft_vga_ram_output_data):((PARA == 12'd2)?({1'b0,fft_vga_ram_output_data[11:1]}):((PARA == 12'd3)?({2'd0,fft_vga_ram_output_data[11:2]}):({3'd0,fft_vga_ram_output_data[11:3]})));

//******VGA第三层
reg [15:0]pixel_color_d2;
wire [15:0]wave_color = GREEN;
always@(posedge pclk or negedge rst_n)
begin
    if(!rst_n)
        pixel_color_d2 <= 16'h0;
    else if(region_active)
    begin
        //钢琴白底加黑块界面
        if(pos_x >= 12'd21 && pos_x <= 12'd1580 && pos_y >= 12'd51 && pos_y <= 12'd110)
        begin
            if(pos_x >= 12'd41 && pos_x <= 12'd41 + 12'd19)
                pixel_color_d2 <= BLACK;
            else if(  (pos_x >= 12'd101 && pos_x <= 12'd101 + 12'd19) ||
                      (pos_x >= 12'd101 + 12'd210 && pos_x <= 12'd101 + 12'd210 + 12'd19) || 
                      (pos_x >= 12'd101 + 12'd420 && pos_x <= 12'd101 + 12'd420 + 12'd19) ||
                      (pos_x >= 12'd101 + 12'd630 && pos_x <= 12'd101 + 12'd630 + 12'd19) ||
                      (pos_x >= 12'd101 + 12'd840 && pos_x <= 12'd101 + 12'd840 + 12'd19) ||
                      (pos_x >= 12'd101 + 12'd1050 && pos_x <= 12'd101 + 12'd1050 + 12'd19) ||
                      (pos_x >= 12'd101 + 12'd1260 && pos_x <= 12'd101 + 12'd1260 + 12'd19)   )
                pixel_color_d2 <= BLACK;
            else if(  (pos_x >= 12'd131 && pos_x <= 12'd131 + 12'd19) ||
                      (pos_x >= 12'd131 + 12'd210 && pos_x <= 12'd131 + 12'd210 + 12'd19) || 
                      (pos_x >= 12'd131 + 12'd420 && pos_x <= 12'd131 + 12'd420 + 12'd19) ||
                      (pos_x >= 12'd131 + 12'd630 && pos_x <= 12'd131 + 12'd630 + 12'd19) ||
                      (pos_x >= 12'd131 + 12'd840 && pos_x <= 12'd131 + 12'd840 + 12'd19) ||
                      (pos_x >= 12'd131 + 12'd1050 && pos_x <= 12'd131 + 12'd1050 + 12'd19) ||
                      (pos_x >= 12'd131 + 12'd1260 && pos_x <= 12'd131 + 12'd1260 + 12'd19)   )
                pixel_color_d2 <= BLACK;
            else if(  (pos_x >= 12'd191 && pos_x <= 12'd191 + 12'd19) ||
                      (pos_x >= 12'd191 + 12'd210 && pos_x <= 12'd191 + 12'd210 + 12'd19) || 
                      (pos_x >= 12'd191 + 12'd420 && pos_x <= 12'd191 + 12'd420 + 12'd19) ||
                      (pos_x >= 12'd191 + 12'd630 && pos_x <= 12'd191 + 12'd630 + 12'd19) ||
                      (pos_x >= 12'd191 + 12'd840 && pos_x <= 12'd191 + 12'd840 + 12'd19) ||
                      (pos_x >= 12'd191 + 12'd1050 && pos_x <= 12'd191 + 12'd1050 + 12'd19) ||
                      (pos_x >= 12'd191 + 12'd1260 && pos_x <= 12'd191 + 12'd1260 + 12'd19)   )
                pixel_color_d2 <= BLACK;
            else if(  (pos_x >= 12'd221 && pos_x <= 12'd221 + 12'd19) ||
                      (pos_x >= 12'd221 + 12'd210 && pos_x <= 12'd221 + 12'd210 + 12'd19) || 
                      (pos_x >= 12'd221 + 12'd420 && pos_x <= 12'd221 + 12'd420 + 12'd19) ||
                      (pos_x >= 12'd221 + 12'd630 && pos_x <= 12'd221 + 12'd630 + 12'd19) ||
                      (pos_x >= 12'd221 + 12'd840 && pos_x <= 12'd221 + 12'd840 + 12'd19) ||
                      (pos_x >= 12'd221 + 12'd1050 && pos_x <= 12'd221 + 12'd1050 + 12'd19) ||
                      (pos_x >= 12'd221 + 12'd1260 && pos_x <= 12'd221 + 12'd1260 + 12'd19)   )
                pixel_color_d2 <= BLACK;
            else if(  (pos_x >= 12'd251 && pos_x <= 12'd251 + 12'd19) ||
                      (pos_x >= 12'd251 + 12'd210 && pos_x <= 12'd251 + 12'd210 + 12'd19) || 
                      (pos_x >= 12'd251 + 12'd420 && pos_x <= 12'd251 + 12'd420 + 12'd19) ||
                      (pos_x >= 12'd251 + 12'd630 && pos_x <= 12'd251 + 12'd630 + 12'd19) ||
                      (pos_x >= 12'd251 + 12'd840 && pos_x <= 12'd251 + 12'd840 + 12'd19) ||
                      (pos_x >= 12'd251 + 12'd1050 && pos_x <= 12'd251 + 12'd1050 + 12'd19) ||
                      (pos_x >= 12'd251 + 12'd1260 && pos_x <= 12'd251 + 12'd1260 + 12'd19)   )
                pixel_color_d2 <= BLACK;
            else
                pixel_color_d2 <= pixel_color_d1;
        end
        //波形显示界面
        else if(adc_wave_active)
        begin
            if(adc_vga_ram_output_cnt == 11'd0 && 12'd290 - pos_y == {5'd0,adc_vga_ram_output_data[11:5]})
                pixel_color_d2 <= wave_color;
            else if(adc_vga_ram_output_cnt >= 11'd1 && adc_vga_ram_output_data_d0 > adc_vga_ram_output_data && (12'd290 - {5'd0,adc_vga_ram_output_data[11:5]} - pos_y) <= {5'd0,adc_vga_ram_output_data_d0[11:5]} - {5'd0,adc_vga_ram_output_data[11:5]})
                pixel_color_d2 <= wave_color;
            else if(adc_vga_ram_output_cnt >= 11'd1 && adc_vga_ram_output_data_d0 <= adc_vga_ram_output_data && (12'd290 - {5'd0,adc_vga_ram_output_data_d0[11:5]} - pos_y) <= {5'd0,adc_vga_ram_output_data[11:5]} - {5'd0,adc_vga_ram_output_data_d0[11:5]})
                pixel_color_d2 <= wave_color;
            else
                pixel_color_d2 <= pixel_color_d1;
        end
        //频谱界面
        else if(fft_region_active_1 && pos_y > 12'd340 && pos_y <= 12'd500 && 12'd500 - pos_y <= fft_output_data)
            pixel_color_d2 <= wave_color;
        else if(fft_region_active_2 && pos_y > 12'd510 && pos_y <= 12'd670 && 12'd670 - pos_y <= fft_output_data)
            pixel_color_d2 <= wave_color;
        else if(fft_region_active_3 && pos_y > 12'd680 && pos_y <= 12'd840 && 12'd840 - pos_y <= fft_output_data)
            pixel_color_d2 <= wave_color;
        else
            pixel_color_d2 <= pixel_color_d1;
    end
    else
        pixel_color_d2 <= pixel_color_d1;
end

//******VGA第四层
/*reg [6:0]fft_K[0:9];*/

reg [15:0]pixel_color_d3;
wire [15:0]piano_color = GREEN;
wire [15:0]color_test = pixel_color_d2;
//钢琴黑块
wire piano_condition_2  = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd42 && pos_x < 12'd42 + 12'd19);
wire piano_condition_5  = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd102 && pos_x < 12'd102 + 12'd19);
wire piano_condition_17 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd102 + 12'd210 && pos_x < 12'd102 + 12'd210 + 12'd19);
wire piano_condition_29 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd102 + 12'd420 && pos_x < 12'd102 + 12'd420 + 12'd19);
wire piano_condition_41 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd102 + 12'd630 && pos_x < 12'd102 + 12'd630 + 12'd19);
wire piano_condition_53 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd102 + 12'd840 && pos_x < 12'd102 + 12'd840 + 12'd19);
wire piano_condition_65 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd102 + 12'd1050 && pos_x < 12'd102 + 12'd1050 + 12'd19);
wire piano_condition_77 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd102 + 12'd1260 && pos_x < 12'd102 + 12'd1260 + 12'd19);
wire piano_condition_7  = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd132 && pos_x < 12'd132 + 12'd19);
wire piano_condition_19 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd132 + 12'd210 && pos_x < 12'd132 + 12'd210 + 12'd19);
wire piano_condition_31 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd132 + 12'd420 && pos_x < 12'd132 + 12'd420 + 12'd19);
wire piano_condition_43 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd132 + 12'd630 && pos_x < 12'd132 + 12'd630 + 12'd19);
wire piano_condition_55 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd132 + 12'd840 && pos_x < 12'd132 + 12'd840 + 12'd19);
wire piano_condition_67 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd132 + 12'd1050 && pos_x < 12'd132 + 12'd1050 + 12'd19);
wire piano_condition_79 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd132 + 12'd1260 && pos_x < 12'd132 + 12'd1260 + 12'd19);
wire piano_condition_10 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd192 && pos_x < 12'd192 + 12'd19);
wire piano_condition_22 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd192 + 12'd210 && pos_x < 12'd192 + 12'd210 + 12'd19);
wire piano_condition_34 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd192 + 12'd420 && pos_x < 12'd192 + 12'd420 + 12'd19);
wire piano_condition_46 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd192 + 12'd630 && pos_x < 12'd192 + 12'd630 + 12'd19);
wire piano_condition_58 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd192 + 12'd840 && pos_x < 12'd192 + 12'd840 + 12'd19);
wire piano_condition_70 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd192 + 12'd1050 && pos_x < 12'd192 + 12'd1050 + 12'd19);
wire piano_condition_82 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd192 + 12'd1260 && pos_x < 12'd192 + 12'd1260 + 12'd19);
wire piano_condition_12 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd222 && pos_x < 12'd222 + 12'd19);
wire piano_condition_24 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd222 + 12'd210 && pos_x < 12'd222 + 12'd210 + 12'd19);
wire piano_condition_36 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd222 + 12'd420 && pos_x < 12'd222 + 12'd420 + 12'd19);
wire piano_condition_48 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd222 + 12'd630 && pos_x < 12'd222 + 12'd630 + 12'd19);
wire piano_condition_60 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd222 + 12'd840 && pos_x < 12'd222 + 12'd840 + 12'd19);
wire piano_condition_72 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd222 + 12'd1050 && pos_x < 12'd222 + 12'd1050 + 12'd19);
wire piano_condition_84 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd222 + 12'd1260 && pos_x < 12'd222 + 12'd1260 + 12'd19);
wire piano_condition_14 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd252 && pos_x < 12'd252 + 12'd19);
wire piano_condition_26 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd252 + 12'd210 && pos_x < 12'd252 + 12'd210 + 12'd19);
wire piano_condition_38 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd252 + 12'd420 && pos_x < 12'd252 + 12'd420 + 12'd19);
wire piano_condition_50 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd252 + 12'd630 && pos_x < 12'd252 + 12'd630 + 12'd19);
wire piano_condition_62 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd252 + 12'd840 && pos_x < 12'd252 + 12'd840 + 12'd19);
wire piano_condition_74 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd252 + 12'd1050 && pos_x < 12'd252 + 12'd1050 + 12'd19);
wire piano_condition_86 = (pos_y > 12'd51 && pos_y < 12'd110 && pos_x > 12'd252 + 12'd1260 && pos_x < 12'd252 + 12'd1260 + 12'd19);
//钢琴白块
wire piano_condition_1  = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd22 && pos_x < 12'd22 + 12'd30 && color_test == WRITE);
wire piano_condition_3  = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd52 && pos_x < 12'd52 + 12'd30 && color_test == WRITE);
wire piano_condition_4  = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd82 && pos_x < 12'd82 + 12'd30 && color_test == WRITE);
wire piano_condition_16 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd82 + 12'd210 && pos_x < 12'd82 + 12'd210 + 12'd30 && color_test == WRITE);
wire piano_condition_28 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd82 + 12'd420 && pos_x < 12'd82 + 12'd420 + 12'd30 && color_test == WRITE);
wire piano_condition_40 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd82 + 12'd630 && pos_x < 12'd82 + 12'd630 + 12'd30 && color_test == WRITE);
wire piano_condition_52 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd82 + 12'd840 && pos_x < 12'd82 + 12'd840 + 12'd30 && color_test == WRITE);
wire piano_condition_64 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd82 + 12'd1050 && pos_x < 12'd82 + 12'd1050 + 12'd30 && color_test == WRITE);
wire piano_condition_76 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd82 + 12'd1260 && pos_x < 12'd82 + 12'd1260 + 12'd30 && color_test == WRITE);
wire piano_condition_6  = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd112 && pos_x < 12'd112 + 12'd30 && color_test == WRITE);
wire piano_condition_18 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd112 + 12'd210 && pos_x < 12'd112 + 12'd210 + 12'd30 && color_test == WRITE);
wire piano_condition_30 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd112 + 12'd420 && pos_x < 12'd112 + 12'd420 + 12'd30 && color_test == WRITE);
wire piano_condition_42 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd112 + 12'd630 && pos_x < 12'd112 + 12'd630 + 12'd30 && color_test == WRITE);
wire piano_condition_54 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd112 + 12'd840 && pos_x < 12'd112 + 12'd840 + 12'd30 && color_test == WRITE);
wire piano_condition_66 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd112 + 12'd1050 && pos_x < 12'd112 + 12'd1050 + 12'd30 && color_test == WRITE);
wire piano_condition_78 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd112 + 12'd1260 && pos_x < 12'd112 + 12'd1260 + 12'd30 && color_test == WRITE);
wire piano_condition_8  = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd142 && pos_x < 12'd142 + 12'd30 && color_test == WRITE);
wire piano_condition_20 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd142 + 12'd210 && pos_x < 12'd142 + 12'd210 + 12'd30 && color_test == WRITE);
wire piano_condition_32 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd142 + 12'd420 && pos_x < 12'd142 + 12'd420 + 12'd30 && color_test == WRITE);
wire piano_condition_44 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd142 + 12'd630 && pos_x < 12'd142 + 12'd630 + 12'd30 && color_test == WRITE);
wire piano_condition_56 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd142 + 12'd840 && pos_x < 12'd142 + 12'd840 + 12'd30 && color_test == WRITE);
wire piano_condition_68 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd142 + 12'd1050 && pos_x < 12'd142 + 12'd1050 + 12'd30 && color_test == WRITE);
wire piano_condition_80 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd142 + 12'd1260 && pos_x < 12'd142 + 12'd1260 + 12'd30 && color_test == WRITE);
wire piano_condition_9  = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd172 && pos_x < 12'd172 + 12'd30 && color_test == WRITE);
wire piano_condition_21 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd172 + 12'd210 && pos_x < 12'd172 + 12'd210 + 12'd30 && color_test == WRITE);
wire piano_condition_33 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd172 + 12'd420 && pos_x < 12'd172 + 12'd420 + 12'd30 && color_test == WRITE);
wire piano_condition_45 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd172 + 12'd630 && pos_x < 12'd172 + 12'd630 + 12'd30 && color_test == WRITE);
wire piano_condition_57 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd172 + 12'd840 && pos_x < 12'd172 + 12'd840 + 12'd30 && color_test == WRITE);
wire piano_condition_69 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd172 + 12'd1050 && pos_x < 12'd172 + 12'd1050 + 12'd30 && color_test == WRITE);
wire piano_condition_81 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd172 + 12'd1260 && pos_x < 12'd172 + 12'd1260 + 12'd30 && color_test == WRITE);
wire piano_condition_11 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd202 && pos_x < 12'd202 + 12'd30 && color_test == WRITE);
wire piano_condition_23 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd202 + 12'd210 && pos_x < 12'd202 + 12'd210 + 12'd30 && color_test == WRITE);
wire piano_condition_35 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd202 + 12'd420 && pos_x < 12'd202 + 12'd420 + 12'd30 && color_test == WRITE);
wire piano_condition_47 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd202 + 12'd630 && pos_x < 12'd202 + 12'd630 + 12'd30 && color_test == WRITE);
wire piano_condition_59 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd202 + 12'd840 && pos_x < 12'd202 + 12'd840 + 12'd30 && color_test == WRITE);
wire piano_condition_71 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd202 + 12'd1050 && pos_x < 12'd202 + 12'd1050 + 12'd30 && color_test == WRITE);
wire piano_condition_83 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd202 + 12'd1260 && pos_x < 12'd202 + 12'd1260 + 12'd30 && color_test == WRITE);
wire piano_condition_13 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd232 && pos_x < 12'd232 + 12'd30 && color_test == WRITE);
wire piano_condition_25 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd232 + 12'd210 && pos_x < 12'd232 + 12'd210 + 12'd30 && color_test == WRITE);
wire piano_condition_37 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd232 + 12'd420 && pos_x < 12'd232 + 12'd420 + 12'd30 && color_test == WRITE);
wire piano_condition_49 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd232 + 12'd630 && pos_x < 12'd232 + 12'd630 + 12'd30 && color_test == WRITE);
wire piano_condition_61 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd232 + 12'd840 && pos_x < 12'd232 + 12'd840 + 12'd30 && color_test == WRITE);
wire piano_condition_73 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd232 + 12'd1050 && pos_x < 12'd232 + 12'd1050 + 12'd30 && color_test == WRITE);
wire piano_condition_85 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd232 + 12'd1260 && pos_x < 12'd232 + 12'd1260 + 12'd30 && color_test == WRITE);
wire piano_condition_15 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd262 && pos_x < 12'd262 + 12'd30 && color_test == WRITE);
wire piano_condition_27 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd262 + 12'd210 && pos_x < 12'd262 + 12'd210 + 12'd30 && color_test == WRITE);
wire piano_condition_39 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd262 + 12'd420 && pos_x < 12'd262 + 12'd420 + 12'd30 && color_test == WRITE);
wire piano_condition_51 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd262 + 12'd630 && pos_x < 12'd262 + 12'd630 + 12'd30 && color_test == WRITE);
wire piano_condition_63 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd262 + 12'd840 && pos_x < 12'd262 + 12'd840 + 12'd30 && color_test == WRITE);
wire piano_condition_75 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd262 + 12'd1050 && pos_x < 12'd262 + 12'd1050 + 12'd30 && color_test == WRITE);
wire piano_condition_87 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd262 + 12'd1260 && pos_x < 12'd262 + 12'd1260 + 12'd30 && color_test == WRITE);
wire piano_condition_88 = (pos_y >= 12'd51 && pos_y <= 12'd140 && pos_x > 12'd1552 && pos_x < 12'd1552 + 12'd30 && color_test == WRITE);

always@(posedge pclk or negedge rst_n)
begin
    if(!rst_n)
        pixel_color_d3 <= 16'h0;
    else if(region_active)
    begin
        if(pos_y >= 12'd45 && pos_y <= 12'd145)
            //钢琴动态变换界面
            begin
                if      (piano_condition_1 ) begin if(7'd1  == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd1  == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_2 ) begin if(7'd2  == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd2  == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_3 ) begin if(7'd3  == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd3  == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_4 ) begin if(7'd4  == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd4  == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_5 ) begin if(7'd5  == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd5  == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_6 ) begin if(7'd6  == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd6  == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_7 ) begin if(7'd7  == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd7  == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_8 ) begin if(7'd8  == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd8  == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_9 ) begin if(7'd9  == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd9  == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_10) begin if(7'd10 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd10 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_11) begin if(7'd11 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd11 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_12) begin if(7'd12 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd12 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_13) begin if(7'd13 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd13 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_14) begin if(7'd14 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd14 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_15) begin if(7'd15 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd15 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_16) begin if(7'd16 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd16 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_17) begin if(7'd17 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd17 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_18) begin if(7'd18 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd18 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_19) begin if(7'd19 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd19 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_20) begin if(7'd20 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd20 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_21) begin if(7'd21 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd21 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_22) begin if(7'd22 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd22 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_23) begin if(7'd23 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd23 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_24) begin if(7'd24 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd24 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_25) begin if(7'd25 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd25 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_26) begin if(7'd26 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd26 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_27) begin if(7'd27 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd27 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_28) begin if(7'd28 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd28 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_29) begin if(7'd29 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd29 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_30) begin if(7'd30 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd30 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_31) begin if(7'd31 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd31 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_32) begin if(7'd32 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd32 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_33) begin if(7'd33 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd33 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_34) begin if(7'd34 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd34 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_35) begin if(7'd35 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd35 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_36) begin if(7'd36 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd36 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_37) begin if(7'd37 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd37 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_38) begin if(7'd38 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd38 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_39) begin if(7'd39 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd39 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_40) begin if(7'd40 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd40 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_41) begin if(7'd41 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd41 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_42) begin if(7'd42 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd42 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_43) begin if(7'd43 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd43 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_44) begin if(7'd44 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd44 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_45) begin if(7'd45 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd45 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_46) begin if(7'd46 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd46 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_47) begin if(7'd47 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd47 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_48) begin if(7'd48 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd48 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_49) begin if(7'd49 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd49 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_50) begin if(7'd50 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd50 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_51) begin if(7'd51 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd51 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_52) begin if(7'd52 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd52 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_53) begin if(7'd53 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd53 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_54) begin if(7'd54 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd54 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_55) begin if(7'd55 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd55 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_56) begin if(7'd56 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd56 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_57) begin if(7'd57 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd57 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_58) begin if(7'd58 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd58 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_59) begin if(7'd59 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd59 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_60) begin if(7'd60 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd60 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_61) begin if(7'd61 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd61 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_62) begin if(7'd62 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd62 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_63) begin if(7'd63 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd63 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_64) begin if(7'd64 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd64 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_65) begin if(7'd65 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd65 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_66) begin if(7'd66 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd66 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_67) begin if(7'd67 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd67 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_68) begin if(7'd68 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd68 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_69) begin if(7'd69 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd69 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_70) begin if(7'd70 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd70 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_71) begin if(7'd71 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd71 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_72) begin if(7'd72 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd72 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_73) begin if(7'd73 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd73 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_74) begin if(7'd74 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd74 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_75) begin if(7'd75 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd75 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_76) begin if(7'd76 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd76 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_77) begin if(7'd77 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd77 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_78) begin if(7'd78 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd78 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_79) begin if(7'd79 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd79 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_80) begin if(7'd80 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd80 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_81) begin if(7'd81 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd81 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_82) begin if(7'd82 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd82 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_83) begin if(7'd83 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd83 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_84) begin if(7'd84 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd84 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_85) begin if(7'd85 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd85 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_86) begin if(7'd86 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd86 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_87) begin if(7'd87 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd87 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
				else if (piano_condition_88) begin if(7'd88 == fft_K[0])begin if(select_color)pixel_color_d3 <= RED; else pixel_color_d3 <= GREEN; end else if(7'd88 == fft_K[1])pixel_color_d3 <= GRAY; else pixel_color_d3 <= pixel_color_d2; end
                else     pixel_color_d3 <= pixel_color_d2;
            end
        else if(pos_y >= 12'd320 && pos_y <= 12'd855)
        begin
            if     (fft_region_active_1 && pos_y > 12'd340 && pos_y <= 12'd500 && 12'd500 - pos_y == THR)
                pixel_color_d3 <= RED;
            else if(fft_region_active_2 && pos_y > 12'd510 && pos_y <= 12'd670 && 12'd670 - pos_y == THR)
                pixel_color_d3 <= RED;
            else if(fft_region_active_3 && pos_y > 12'd680 && pos_y <= 12'd840 && 12'd840 - pos_y == THR)
                pixel_color_d3 <= RED;
            else
                pixel_color_d3 <= pixel_color_d2;
        end
        else
            pixel_color_d3 <= pixel_color_d2;
    end
    else
        pixel_color_d3 <= pixel_color_d2;
end

//******VGA第五层
reg [15:0]pixel_color_d4;
reg [11:0]ROM_mode_cnt;
wire [11:0]ROM_MEM_0_cnt 			= ROM_mode_cnt;
wire [11:0]ROM_PARA_0_cnt 			= ROM_mode_cnt;
wire [11:0]ROM_THR_0_cnt 			= ROM_mode_cnt;
wire [11:0]ROM_Music_Select_0_cnt 	= ROM_mode_cnt;

wire [15:0]ROM_MEM_0_data;
wire [15:0]ROM_PARA_0_data;
wire [15:0]ROM_THR_0_data;
wire [15:0]ROM_Music_Select_0_data;
wire [15:0]ROM_mode_data = 	(led0)?(ROM_THR_0_data):
							((led1)?(ROM_PARA_0_data):
							((led2)?(ROM_Music_Select_0_data):
							( ROM_MEM_0_data )));

always@(posedge pclk or negedge rst_n)
begin
	if(!rst_n)
		ROM_mode_cnt <= 12'd0;
	else if(pos_y >= 12'd751 && pos_y <= 12'd770)
	begin
		if(pos_x >= 12'd1251 && pos_x <= 12'd1370)
			ROM_mode_cnt <= ROM_mode_cnt + 12'd1;
		else
			ROM_mode_cnt <= ROM_mode_cnt;
	end
	else
		ROM_mode_cnt <= 12'd0;
end

always@(posedge pclk or negedge rst_n)
begin
	if(!rst_n)
		pixel_color_d4 <= 16'h0;
	else if(pos_x >= 12'd1251 && pos_x <= 12'd1370 && pos_y >= 12'd751 && pos_y <= 12'd770)
	begin
		pixel_color_d4 <= ~ROM_mode_data;
	end
	else
		pixel_color_d4 <= pixel_color_d3;
end

ROM_MEM ROM_MEM_0 (
  .a(ROM_MEM_0_cnt),      // input wire [11 : 0] a
  .spo(ROM_MEM_0_data)  // output wire [15 : 0] spo
);
ROM_PARA ROM_PARA_0 (
  .a(ROM_PARA_0_cnt),      // input wire [11 : 0] a
  .spo(ROM_PARA_0_data)  // output wire [15 : 0] spo
);
ROM_THR ROM_THR_0 (
  .a(ROM_THR_0_cnt),      // input wire [11 : 0] a
  .spo(ROM_THR_0_data)  // output wire [15 : 0] spo
);
ROM_Music_Select ROM_Music_Select_0 (
  .a(ROM_Music_Select_0_cnt),      // input wire [11 : 0] a
  .spo(ROM_Music_Select_0_data)  // output wire [15 : 0] spo
);
//******VGA最终输出层
wire [15:0]pixel_color;
assign pixel_color = pixel_color_d4;  
 VGA_display  VGA_display_S0(
       .pclk                    (pclk           ),
       .rst_n                   (rst_n          ),
        //exchange data
       .pixel_color             (pixel_color    ),
       .pos_x                   (pos_x          ),
       .pos_y                   (pos_y          ),
       .video_active            (video_active   ),
        //VGA port
       .rgb_r                   (rgb_r          ),
       .rgb_g                   (rgb_g          ),
       .rgb_b                   (rgb_b          ),
       .hs                      (hs             ),
       .vs                      (vs             )
        );   
 //******************************VGA-over*************************
endmodule
