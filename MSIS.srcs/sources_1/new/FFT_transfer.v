module FFT_transfer(
    input                           fft_clk,//FFT模块时钟      
    input                           rst_n,
                           
    input [11:0]                    fft_input_data,//FFT模块输入数据                 
    input                           fft_input_valid,
    output                          fft_input_ready,
    
    output reg [11:0]               fft_output_data,//FFT模块输出数据                         
    output                          fft_data_valid,//                                
    input                           fft_output_ready
    );
    
    //config
    wire config_valid;
    reg [3:0]config_cnt;
    always@(posedge fft_clk or negedge rst_n)
    begin
        if(!rst_n)
            config_cnt<=4'd0;
        else  if(config_cnt<=4'd10)
            config_cnt<=config_cnt+4'd1;
        else
            config_cnt<=config_cnt;
    end
    assign config_valid = (config_cnt<=4'd10);  
    
    //input
    reg[11:0]input_data;
    wire input_data_valid_d0;
    assign input_data_valid_d0=fft_input_valid;
    reg input_data_valid_d1;
    always@(posedge fft_clk or negedge rst_n)
    begin
       if(!rst_n)
       begin
            input_data<=12'd0;
            input_data_valid_d1<=12'd0;
       end
       else
       begin
            input_data<=fft_input_data-12'd2048;
            input_data_valid_d1<=input_data_valid_d0;
       end
    end
    
    //output
     wire[31:0]fft_data_temp;
     wire[11:0]RE_data,IM_data;
     assign RE_data=fft_data_temp[11:0];
     assign IM_data=fft_data_temp[27:16];
     wire[23:0]RE_squre,IM_squre;
     FFT_MUL FFT_MUL_0 (
                       .CLK(fft_clk),  // input wire CLK
                       .A(RE_data),      // input wire [11 : 0] A
                       .B(RE_data),      // input wire [11 : 0] B
                       .P(RE_squre)      // output wire [23 : 0] P
               );    
     FFT_MUL FFT_MUL_1 (
                     .CLK(fft_clk),  // input wire CLK
                     .A(IM_data),      // input wire [11 : 0] A
                     .B(IM_data),      // input wire [11 : 0] B
                     .P(IM_squre)      // output wire [23 : 0] P
                ); 
     wire[23:0]Amp_data;
     FFT_ADD FFT_ADD_0 (
                   .A(RE_squre),      // input wire [23 : 0] A
                   .B(IM_squre),      // input wire [23 : 0] B
                   .CLK(fft_clk),  // input wire CLK
                   .S(Amp_data)      // output wire [23 : 0] S
               );
     wire [15:0]Amp_data_Root;
     FFT_SquareRoot FFT_SquareRoot_0 (
                 .aclk(fft_clk),                                        // input wire aclk
                 .s_axis_cartesian_tvalid(1'b1),  // input wire s_axis_cartesian_tvalid
                 .s_axis_cartesian_tdata(Amp_data),    // input wire [23 : 0] s_axis_cartesian_tdata
                 .m_axis_dout_tvalid(),            // output wire m_axis_dout_tvalid
                 .m_axis_dout_tdata(Amp_data_Root)              // output wire [15 : 0] m_axis_dout_tdata
               );
     /*          
     wire[23:0]Amp_data_0;
     assign Amp_data_0=Amp_data_Root/amp_para; 
     
     reg[23:0]amp_para;
     always@(posedge fft_clk or negedge rst_n)
     begin
         if(!rst_n)
             amp_para<=24'd1100;
         else  if(key2_flag  && !led2)
         begin
             if(amp_para<24'd1100)   amp_para<=amp_para+24'd50;
             else amp_para<=amp_para;
         end
         else if(key1_flag   && !led2)
         begin
             if(amp_para>24'd50)    amp_para<=amp_para-24'd50;
             else amp_para<=amp_para;
         end
         else
             amp_para<=amp_para;
     end
     */
     
     always@(posedge fft_clk or negedge rst_n)
     begin
         if(!rst_n)
             fft_output_data<=9'd0;
         else
             fft_output_data<=Amp_data_Root[11:0];
     end
     //******
     wire fft_data_temp_valid;
     reg fft_data_temp_valid_d0,fft_data_temp_valid_d1,fft_data_temp_valid_d2;
     reg fft_data_temp_valid_d3,fft_data_temp_valid_d4,fft_data_temp_valid_d5,fft_data_temp_valid_d6,fft_data_temp_valid_d7,fft_data_temp_valid_d8;
     reg fft_data_temp_valid_d9,fft_data_temp_valid_d10,fft_data_temp_valid_d11,fft_data_temp_valid_d12,fft_data_temp_valid_d13,fft_data_temp_valid_d14,fft_data_temp_valid_d15;
     
     always@(posedge fft_clk or negedge rst_n)
     begin
         if(!rst_n)
         begin
             fft_data_temp_valid_d0<=1'b0;
             fft_data_temp_valid_d1<=1'b0;
             fft_data_temp_valid_d2<=1'b0;
             fft_data_temp_valid_d3<=1'b0;
             fft_data_temp_valid_d4<=1'b0;
             fft_data_temp_valid_d5<=1'b0;
             fft_data_temp_valid_d6<=1'b0;
             fft_data_temp_valid_d7<=1'b0;
             fft_data_temp_valid_d8<=1'b0;
             fft_data_temp_valid_d9<=1'b0;
             fft_data_temp_valid_d10<=1'b0;
             fft_data_temp_valid_d11<=1'b0;
             fft_data_temp_valid_d12<=1'b0;
             fft_data_temp_valid_d13<=1'b0;
             fft_data_temp_valid_d14<=1'b0;
             fft_data_temp_valid_d15<=1'b0;
         end
         else
         begin
             fft_data_temp_valid_d0<=fft_data_temp_valid;
             fft_data_temp_valid_d1<=fft_data_temp_valid_d0;
             fft_data_temp_valid_d2<=fft_data_temp_valid_d1;
             fft_data_temp_valid_d3<=fft_data_temp_valid_d2;
             fft_data_temp_valid_d4<=fft_data_temp_valid_d3;
             fft_data_temp_valid_d5<=fft_data_temp_valid_d4;
             fft_data_temp_valid_d6<=fft_data_temp_valid_d5;
             fft_data_temp_valid_d7<=fft_data_temp_valid_d6;
             fft_data_temp_valid_d8<=fft_data_temp_valid_d7;
             fft_data_temp_valid_d9<=fft_data_temp_valid_d8;
             fft_data_temp_valid_d10<=fft_data_temp_valid_d9;
             fft_data_temp_valid_d11<=fft_data_temp_valid_d10;
             fft_data_temp_valid_d12<=fft_data_temp_valid_d11;
             fft_data_temp_valid_d13<=fft_data_temp_valid_d12;
             fft_data_temp_valid_d14<=fft_data_temp_valid_d13;
             fft_data_temp_valid_d15<=fft_data_temp_valid_d14;
         end
     end
     assign fft_data_valid=fft_data_temp_valid_d15;
//******    
FFT FFT_0 (
      .aclk                             (fft_clk                        ),                  // input wire aclk
      .s_axis_config_tdata              (16'b0_01_10_10_10_10_10_11_1   ),                  // input wire [15 : 0] s_axis_config_tdata
      .s_axis_config_tvalid             (config_valid                   ),                // input wire s_axis_config_tvalid
//      .s_axis_config_tready             (),                // output wire s_axis_config_tready
      .s_axis_data_tdata                ({20'd0,input_data}             ),                      // input wire [31 : 0] s_axis_data_tdata
      .s_axis_data_tvalid               (input_data_valid_d1            ),                    // input wire s_axis_data_tvalid
      .s_axis_data_tready               (fft_input_ready                ),                    // output wire s_axis_data_tready
      .s_axis_data_tlast                (                               ),                      // input wire s_axis_data_tlast
      .m_axis_data_tdata                (fft_data_temp                  ),                      // output wire [31 : 0] m_axis_data_tdata
      .m_axis_data_tvalid               (fft_data_temp_valid            ),                    // output wire m_axis_data_tvalid
      .m_axis_data_tready               (fft_output_ready               ),                    // input wire m_axis_data_tready
      .m_axis_data_tlast                (                               )                      // output wire m_axis_data_tlast
    );  
endmodule
