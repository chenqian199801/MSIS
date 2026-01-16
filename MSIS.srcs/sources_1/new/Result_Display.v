module Result_Display(
    input [3:0]music_list,
    input [7:0]score,
    
    input pclk,
    input rst_n,
    input [11:0]pos_x,
    input [11:0]pos_y,
    
    output [15:0]music_list_data,
    output [15:0]score_data
    );
    
//*****************************************music*****************************************
reg [13:0]music_cnt;
always@(posedge pclk or negedge rst_n)
begin
    if(!rst_n)
        music_cnt <= 14'd0;
    else if(pos_y >= 12'd181 && pos_y <= 12'd220)
    begin
        if(pos_x >= 12'd221 && pos_x <= 12'd620)
            music_cnt <= music_cnt + 14'd1;
        else
            music_cnt <= music_cnt;
    end
    else
        music_cnt <= 14'd0;
end
wire [13:0]ROM_Lib_Music_0_0_cnt = music_cnt;
wire [13:0]ROM_Lib_Music_1_0_cnt = music_cnt;
wire [13:0]ROM_Lib_Music_2_0_cnt = music_cnt;
wire [13:0]ROM_Lib_Music_3_0_cnt = music_cnt;
wire [13:0]ROM_Lib_Music_4_0_cnt = music_cnt;
wire [13:0]ROM_Lib_Music_5_0_cnt = music_cnt;
wire [13:0]ROM_Lib_Music_0_1_0_cnt = music_cnt;
wire [15:0]ROM_Lib_Music_0_1_0_data;
wire [15:0]ROM_Lib_Music_0_0_data;
wire [15:0]ROM_Lib_Music_1_0_data;
wire [15:0]ROM_Lib_Music_2_0_data;
wire [15:0]ROM_Lib_Music_3_0_data;
wire [15:0]ROM_Lib_Music_4_0_data;
wire [15:0]ROM_Lib_Music_5_0_data; 
assign music_list_data = (music_list == 4'd0)?(ROM_Lib_Music_0_0_data):((music_list == 4'd1)?(ROM_Lib_Music_1_0_data):((music_list == 4'd2)?(ROM_Lib_Music_2_0_data):((music_list == 4'd3)?(ROM_Lib_Music_3_0_data):((music_list == 4'd4)?(ROM_Lib_Music_4_0_data):((music_list == 4'd5)?(ROM_Lib_Music_5_0_data):((music_list == 4'd6)?(ROM_Lib_Music_0_1_0_data):(16'hffff)))))));   
ROM_Lib_Music_0_1 ROM_Lib_Music_0_1_0 (
  .a(ROM_Lib_Music_0_1_0_cnt),      // input wire [13 : 0] a
  .spo(ROM_Lib_Music_0_1_0_data)  // output wire [15 : 0] spo
);
ROM_Lib_Music_0 ROM_Lib_Music_0_0 (
      .a(ROM_Lib_Music_0_0_cnt),      // input wire [13 : 0] a
      .spo(ROM_Lib_Music_0_0_data)  // output wire [15 : 0] spo
    );    
ROM_Lib_Music_1 ROM_Lib_Music_1_0 (
      .a(ROM_Lib_Music_1_0_cnt),      // input wire [13 : 0] a
      .spo(ROM_Lib_Music_1_0_data)  // output wire [15 : 0] spo
    );
ROM_Lib_Music_2 ROM_Lib_Music_2_0 (
      .a(ROM_Lib_Music_2_0_cnt),      // input wire [13 : 0] a
      .spo(ROM_Lib_Music_2_0_data)  // output wire [15 : 0] spo
    );
ROM_Lib_Music_3 ROM_Lib_Music_3_0 (
      .a(ROM_Lib_Music_3_0_cnt),      // input wire [13 : 0] a
      .spo(ROM_Lib_Music_3_0_data)  // output wire [15 : 0] spo
    );
ROM_Lib_Music_4 ROM_Lib_Music_4_0 (
      .a(ROM_Lib_Music_4_0_cnt),      // input wire [13 : 0] a
      .spo(ROM_Lib_Music_4_0_data)  // output wire [15 : 0] spo
    );
ROM_Lib_Music_5 ROM_Lib_Music_5_0 (
      .a(ROM_Lib_Music_5_0_cnt),      // input wire [13 : 0] a
      .spo(ROM_Lib_Music_5_0_data)  // output wire [15 : 0] spo
    );

//*****************************************score*****************************************  
//input [7:0]score,  output [15:0]score_data
reg [9:0]digital_ge_cnt;
reg [9:0]digital_shi_cnt;
reg [9:0]digital_bai_cnt;
always@(posedge pclk or negedge rst_n)
begin
    if(!rst_n)
    begin
        digital_ge_cnt  <= 10'd0;
        digital_shi_cnt <= 10'd0;
        digital_bai_cnt <= 10'd0;
    end
    else if(pos_y >= 12'd241 && pos_y <= 12'd280)
    begin
        if(pos_x >= 12'd221 && pos_x <= 12'd240)
        begin
            digital_ge_cnt  <= digital_ge_cnt;
            digital_shi_cnt <= digital_shi_cnt;
            digital_bai_cnt <= digital_bai_cnt + 10'd1; 
        end
        else if(pos_x >= 12'd241 && pos_x <= 12'd260)
        begin
            digital_ge_cnt  <= digital_ge_cnt;
            digital_shi_cnt <= digital_shi_cnt + 10'd1;
            digital_bai_cnt <= digital_bai_cnt; 
        end
        else if(pos_x >= 12'd261 && pos_x <= 12'd280)
        begin
            digital_ge_cnt  <= digital_ge_cnt + 10'd1;
            digital_shi_cnt <= digital_shi_cnt;
            digital_bai_cnt <= digital_bai_cnt; 
        end
        else
        begin
            digital_ge_cnt  <= digital_ge_cnt;
            digital_shi_cnt <= digital_shi_cnt;
            digital_bai_cnt <= digital_bai_cnt; 
        end
    end
    else
    begin
        digital_ge_cnt  <= 10'd0;
        digital_shi_cnt <= 10'd0;
        digital_bai_cnt <= 10'd0;
    end
end

wire [9:0]ROM_Digital_0_ge_cnt = digital_ge_cnt;
wire [9:0]ROM_Digital_1_ge_cnt = digital_ge_cnt;
wire [9:0]ROM_Digital_2_ge_cnt = digital_ge_cnt;
wire [9:0]ROM_Digital_3_ge_cnt = digital_ge_cnt;
wire [9:0]ROM_Digital_4_ge_cnt = digital_ge_cnt;
wire [9:0]ROM_Digital_5_ge_cnt = digital_ge_cnt;
wire [9:0]ROM_Digital_6_ge_cnt = digital_ge_cnt;
wire [9:0]ROM_Digital_7_ge_cnt = digital_ge_cnt;
wire [9:0]ROM_Digital_8_ge_cnt = digital_ge_cnt;
wire [9:0]ROM_Digital_9_ge_cnt = digital_ge_cnt;
wire [15:0]ROM_Digital_0_ge_data;
wire [15:0]ROM_Digital_1_ge_data;
wire [15:0]ROM_Digital_2_ge_data;
wire [15:0]ROM_Digital_3_ge_data;
wire [15:0]ROM_Digital_4_ge_data;
wire [15:0]ROM_Digital_5_ge_data;
wire [15:0]ROM_Digital_6_ge_data;
wire [15:0]ROM_Digital_7_ge_data;
wire [15:0]ROM_Digital_8_ge_data;
wire [15:0]ROM_Digital_9_ge_data;
wire [15:0]ROM_Digital_ge_data = (score%10 == 0)?(ROM_Digital_0_ge_data):
                                 ((score%10 == 1)?(ROM_Digital_1_ge_data):
                                 ((score%10 == 2)?(ROM_Digital_2_ge_data):
                                 ((score%10 == 3)?(ROM_Digital_3_ge_data):
                                 ((score%10 == 4)?(ROM_Digital_4_ge_data):
                                 ((score%10 == 5)?(ROM_Digital_5_ge_data):
                                 ((score%10 == 6)?(ROM_Digital_6_ge_data):
                                 ((score%10 == 7)?(ROM_Digital_7_ge_data):
                                 ((score%10 == 8)?(ROM_Digital_8_ge_data):
                                 ( ROM_Digital_9_ge_data )))))))));
wire [9:0]ROM_Digital_0_shi_cnt = digital_shi_cnt;
wire [9:0]ROM_Digital_1_shi_cnt = digital_shi_cnt;
wire [9:0]ROM_Digital_2_shi_cnt = digital_shi_cnt;
wire [9:0]ROM_Digital_3_shi_cnt = digital_shi_cnt;
wire [9:0]ROM_Digital_4_shi_cnt = digital_shi_cnt;
wire [9:0]ROM_Digital_5_shi_cnt = digital_shi_cnt;
wire [9:0]ROM_Digital_6_shi_cnt = digital_shi_cnt;
wire [9:0]ROM_Digital_7_shi_cnt = digital_shi_cnt;
wire [9:0]ROM_Digital_8_shi_cnt = digital_shi_cnt;
wire [9:0]ROM_Digital_9_shi_cnt = digital_shi_cnt;
wire [15:0]ROM_Digital_0_shi_data;
wire [15:0]ROM_Digital_1_shi_data;
wire [15:0]ROM_Digital_2_shi_data;
wire [15:0]ROM_Digital_3_shi_data;
wire [15:0]ROM_Digital_4_shi_data;
wire [15:0]ROM_Digital_5_shi_data;
wire [15:0]ROM_Digital_6_shi_data;
wire [15:0]ROM_Digital_7_shi_data;
wire [15:0]ROM_Digital_8_shi_data;
wire [15:0]ROM_Digital_9_shi_data;
wire [15:0]ROM_Digital_shi_data = ((score%100)/10 == 0 && score != 100)?(16'hffff):
                                    (( score == 100      )?(ROM_Digital_0_shi_data):
                                    (((score%100)/10 == 1)?(ROM_Digital_1_shi_data):
                                    (((score%100)/10 == 2)?(ROM_Digital_2_shi_data):
                                    (((score%100)/10 == 3)?(ROM_Digital_3_shi_data):
                                    (((score%100)/10 == 4)?(ROM_Digital_4_shi_data):
                                    (((score%100)/10 == 5)?(ROM_Digital_5_shi_data):
                                    (((score%100)/10 == 6)?(ROM_Digital_6_shi_data):
                                    (((score%100)/10 == 7)?(ROM_Digital_7_shi_data):
                                    (((score%100)/10 == 8)?(ROM_Digital_8_shi_data):
                                    (  ROM_Digital_9_shi_data     ))))))))));
wire [9:0]ROM_Digital_1_bai_cnt = digital_bai_cnt;
wire [15:0]ROM_Digital_1_bai_data;
wire [15:0]ROM_Digital_bai_data = (score == 100)?(ROM_Digital_1_bai_data):(16'hffff);
 
wire region1 = (pos_y >= 12'd241 && pos_y <= 12'd280 && pos_x >= 12'd221 && pos_x <= 12'd240);
wire region2 = (pos_y >= 12'd241 && pos_y <= 12'd280 && pos_x >= 12'd241 && pos_x <= 12'd260);
wire region3 = (pos_y >= 12'd241 && pos_y <= 12'd280 && pos_x >= 12'd261 && pos_x <= 12'd280);

assign score_data = (region1)?(ROM_Digital_bai_data):((region2)?(ROM_Digital_shi_data):(ROM_Digital_ge_data));

ROM_Digital_0 ROM_Digital_0_ge (
      .a(ROM_Digital_0_ge_cnt),      // input wire [9 : 0] a
      .spo(ROM_Digital_0_ge_data)  // output wire [15 : 0] spo
    );
ROM_Digital_1 ROM_Digital_1_ge (
      .a(ROM_Digital_1_ge_cnt),      // input wire [9 : 0] a
      .spo(ROM_Digital_1_ge_data)  // output wire [15 : 0] spo
    );
ROM_Digital_2 ROM_Digital_2_ge (
      .a(ROM_Digital_2_ge_cnt),      // input wire [9 : 0] a
      .spo(ROM_Digital_2_ge_data)  // output wire [15 : 0] spo
    );
ROM_Digital_3 ROM_Digital_3_ge (
      .a(ROM_Digital_3_ge_cnt),      // input wire [9 : 0] a
      .spo(ROM_Digital_3_ge_data)  // output wire [15 : 0] spo
    );
ROM_Digital_4 ROM_Digital_4_ge (
      .a(ROM_Digital_4_ge_cnt),      // input wire [9 : 0] a
      .spo(ROM_Digital_4_ge_data)  // output wire [15 : 0] spo
    );
ROM_Digital_5 ROM_Digital_5_ge (
      .a(ROM_Digital_5_ge_cnt),      // input wire [9 : 0] a
      .spo(ROM_Digital_5_ge_data)  // output wire [15 : 0] spo
    );
ROM_Digital_6 ROM_Digital_6_ge (
      .a(ROM_Digital_6_ge_cnt),      // input wire [9 : 0] a
      .spo(ROM_Digital_6_ge_data)  // output wire [15 : 0] spo
    );
ROM_Digital_7 ROM_Digital_7_ge (
      .a(ROM_Digital_7_ge_cnt),      // input wire [9 : 0] a
      .spo(ROM_Digital_7_ge_data)  // output wire [15 : 0] spo
    );
ROM_Digital_8 ROM_Digital_8_ge (
      .a(ROM_Digital_8_ge_cnt),      // input wire [9 : 0] a
      .spo(ROM_Digital_8_ge_data)  // output wire [15 : 0] spo
    );
ROM_Digital_9 ROM_Digital_9_ge (
      .a(ROM_Digital_9_ge_cnt),      // input wire [9 : 0] a
      .spo(ROM_Digital_9_ge_data)  // output wire [15 : 0] spo
    ); 
ROM_Digital_0 ROM_Digital_0_shi (
      .a(ROM_Digital_0_shi_cnt),      // input wire [9 : 0] a
      .spo(ROM_Digital_0_shi_data)  // output wire [15 : 0] spo
    );
ROM_Digital_1 ROM_Digital_1_shi (
      .a(ROM_Digital_1_shi_cnt),      // input wire [9 : 0] a
      .spo(ROM_Digital_1_shi_data)  // output wire [15 : 0] spo
    );
ROM_Digital_2 ROM_Digital_2_shi (
      .a(ROM_Digital_2_shi_cnt),      // input wire [9 : 0] a
      .spo(ROM_Digital_2_shi_data)  // output wire [15 : 0] spo
    );
ROM_Digital_3 ROM_Digital_3_shi (
      .a(ROM_Digital_3_shi_cnt),      // input wire [9 : 0] a
      .spo(ROM_Digital_3_shi_data)  // output wire [15 : 0] spo
    );
ROM_Digital_4 ROM_Digital_4_shi (
      .a(ROM_Digital_4_shi_cnt),      // input wire [9 : 0] a
      .spo(ROM_Digital_4_shi_data)  // output wire [15 : 0] spo
    );
ROM_Digital_5 ROM_Digital_5_shi (
      .a(ROM_Digital_5_shi_cnt),      // input wire [9 : 0] a
      .spo(ROM_Digital_5_shi_data)  // output wire [15 : 0] spo
    );
ROM_Digital_6 ROM_Digital_6_shi (
      .a(ROM_Digital_6_shi_cnt),      // input wire [9 : 0] a
      .spo(ROM_Digital_6_shi_data)  // output wire [15 : 0] spo
    );
ROM_Digital_7 ROM_Digital_7_shi (
      .a(ROM_Digital_7_shi_cnt),      // input wire [9 : 0] a
      .spo(ROM_Digital_7_shi_data)  // output wire [15 : 0] spo
    );
ROM_Digital_8 ROM_Digital_8_shi (
      .a(ROM_Digital_8_shi_cnt),      // input wire [9 : 0] a
      .spo(ROM_Digital_8_shi_data)  // output wire [15 : 0] spo
    );
ROM_Digital_9 ROM_Digital_9_shi (
      .a(ROM_Digital_9_shi_cnt),      // input wire [9 : 0] a
      .spo(ROM_Digital_9_shi_data)  // output wire [15 : 0] spo
    ); 
ROM_Digital_1 ROM_Digital_1_bai (
      .a(ROM_Digital_1_bai_cnt),      // input wire [9 : 0] a
      .spo(ROM_Digital_1_bai_data)  // output wire [15 : 0] spo
    );         
endmodule
