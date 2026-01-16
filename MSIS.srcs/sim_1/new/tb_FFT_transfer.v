`timescale 1ns / 1ps
module tb_FFT_transfer;

reg fft_clk;
reg rst_n;

reg[11:0]fft_input_data;
reg fft_input_valid;
wire fft_input_ready;

wire [11:0]fft_output_data;
wire fft_data_valid;
reg fft_output_ready;

initial begin 
    fft_clk = 1'b0;
    rst_n = 1'b0;
    fft_input_valid = 1'b1;
    fft_output_ready = 1'b1;
    fft_input_data = 12'd4095;
    #10 rst_n = 1'b1;
    end
always #5 fft_clk = ~fft_clk;

reg [31:0]clk_cnt;
always@(posedge fft_clk or negedge rst_n)
begin
    if(!rst_n)
        clk_cnt <= 32'd0;
    else 
        clk_cnt <= clk_cnt + 32'd1;
end
/*
reg state;
reg [7:0]state_cnt;
always@(posedge fft_clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        state <= 1'b0;
        state_cnt <= 8'd0;
        fft_input_data <= 12'd0;
    end
    else
    begin
        case(state)
            1'b0:begin if(state_cnt <= 8'd200)state_cnt <= state_cnt + 8'd1; else begin state_cnt <= 8'd0; state <= 1'b1; fft_input_data <= 12'd4095; end end
            1'b1:begin if(state_cnt <= 8'd200)state_cnt <= state_cnt + 8'd1; else begin state_cnt <= 8'd0; state <= 1'b0; fft_input_data <= 12'd0; end end
        endcase
    end
end
*/
//********
FFT_transfer    FFT_transfer_0(
    .fft_clk                        (fft_clk                ),//FFT模块时钟      
    .rst_n                          (rst_n                  ),
                           
    .fft_input_data                 (fft_input_data         ),//FFT模块输入数据                 
    .fft_input_valid                (fft_input_valid        ),
    .fft_input_ready                (fft_input_ready        ),
    
    .fft_output_data                (fft_output_data        ),//FFT模块输出数据                         
    .fft_data_valid                 (fft_data_valid         ),//                                
    .fft_output_ready               (fft_output_ready       )
    );
    
endmodule
