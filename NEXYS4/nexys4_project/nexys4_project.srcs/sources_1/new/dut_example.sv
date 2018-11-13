`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wojciech Caputa
// 
// Create Date: 01.09.2018 19:09:45
// Design Name: 
// Module Name: dut_example
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "parameters.vh"
`include "dut_parameters.vh"

module dut_example(gpio_if.dut gpio);

    //7Seg 
    parameter cycles_to_refresh_digit = main_clk_freq/display_refresh_rate/8;
    
    wire [3:0] single_digit;
    wire [7:0][3:0] all_digits ;
    logic [31:0] refresh_counter = 0;
    logic [2:0] current_digit = 0;
    logic [31:0] data_to_display;
    logic [7:0] dp_to_display;

    //Buttons and RGB
    parameter btn_sample_rate = 50;          //Buttons sampling rage in Hz
    parameter cycles_to_sample = main_clk_freq/btn_sample_rate;
    
    wire [4:0] buttons;                 //Array for buttons
    logic [1:0][4:0] buttons_r;           //Buttons synchronization registers
    logic [1:0][4:0] buttons_sampled;     //Sampled buttons values
    logic [4:0] buttons_rising_edge;
    logic [31:0] sampling_counter = 0;
    logic [2:0] led16 = 3'b001;
    logic [2:0] led17 = 3'b100;
    logic chose_led = 1'b0;
    
    //Counters
    logic [15:0] fast_cnt = 16'h0;
    logic [15:0] slow_cnt = 16'h0;
    logic fast_cnt_en;
    logic slow_cnt_en;
    logic fast_cnt_rst;
    logic slow_cnt_rst;
    logic fast_cnt_load;
    logic slow_cnt_load;
    logic [31:0] fast_cnt_int_cnt = 32'h0;
    logic [31:0] slow_cnt_int_cnt = 32'h0;
    parameter fast_cnt_period = main_clk_freq/fast_cnt_freq;
    parameter slow_cnt_period = main_clk_freq/slow_cnt_freq;

    assign buttons = {gpio.btn_center, gpio.btn_up, gpio.btn_left, gpio.btn_right, gpio.btn_down};
    
    always_ff@(posedge gpio.clk)
    begin : buttons_synch
        buttons_r <= {buttons_r[0], buttons};
    end : buttons_synch
    
    always_ff@(posedge gpio.clk)
    begin : check_buttons
        if (sampling_counter == cycles_to_sample - 1) begin
            buttons_sampled <= {buttons_sampled[0], buttons_r[1]};
            sampling_counter <= 0;
            if (buttons_rising_edge[center]) begin
                chose_led <= ~chose_led;//{chose_led[0], chose_led[1]};
            end else begin
                chose_led <= chose_led;
            end
            if (buttons_rising_edge[left]) begin
                led16 <= {led16[1:0], led16[2]};
            end else if (buttons_rising_edge[right]) begin
                led16 <= {led16[0], led16[2:1]};
            end else begin
                led16 <= led16;
            end
            if (buttons_rising_edge[up]) begin
                led17 <= {led17[1:0], led17[2]};
            end else if (buttons_rising_edge[down]) begin
                led17 <= {led17[0], led17[2:1]};
            end else begin
                led17 <= led17;
            end
        end else begin
            sampling_counter <= sampling_counter + 1;
        end
    end : check_buttons
    
    genvar i;
    for (i = 0; i < 5; i = i + 1)
    begin
        assign buttons_rising_edge[i] = ({buttons_sampled[1][i], buttons_sampled[0][i]} == 2'b01) ? 1 : 0;
    end

    assign gpio.led16_R = chose_led ? led16[2] : 0;
    assign gpio.led16_G = chose_led ? led16[1] : 0;
    assign gpio.led16_B = chose_led ? led16[0] : 0;
   
    assign gpio.led17_R = ~chose_led ? led17[2] : 0;
    assign gpio.led17_G = ~chose_led ? led17[1] : 0;
    assign gpio.led17_B = ~chose_led ? led17[0] : 0;
          
    //Switches and LEDs
    assign gpio.led = gpio.sw;
    
    assign data_to_display[15:0] = gpio.sw[0] ? slow_cnt : 16'hbeef;
    assign data_to_display[31:16] = gpio.sw[8] ? fast_cnt : 16'hdead;
    
    assign dp_to_display[7:4] = gpio.sw[15:12];
    assign dp_to_display[3:0] = gpio.sw[7:4];
    
    assign slow_cnt_en = gpio.sw[1];
    assign slow_cnt_rst = gpio.sw[2];
    assign slow_cnt_load = gpio.sw[3];
         
    assign fast_cnt_en = gpio.sw[9];  
    assign fast_cnt_rst = gpio.sw[10];     
    assign fast_cnt_load = gpio.sw[11];
    //Two counters to display on 7seg
    
    always_ff@(posedge gpio.clk)
    begin : fast_counter
        if (fast_cnt_rst) begin
            fast_cnt_int_cnt <= 0;
            fast_cnt <= 0;
        end else if (fast_cnt_load) begin
            fast_cnt <= slow_cnt; 
        end else if (fast_cnt_en) begin
            if (fast_cnt_int_cnt == fast_cnt_period - 1) begin
                fast_cnt_int_cnt <= 0;
                fast_cnt <= fast_cnt + 1;
            end else begin
                fast_cnt_int_cnt <= fast_cnt_int_cnt + 1;
            end
        end
    end : fast_counter
    
    always_ff@(posedge gpio.clk)
    begin : slow_counter
        if (slow_cnt_rst) begin
            slow_cnt_int_cnt <= 0;
            slow_cnt <= 0;
        end else if (slow_cnt_load) begin
            slow_cnt <= fast_cnt;
        end else if (slow_cnt_en) begin
            if (slow_cnt_int_cnt == slow_cnt_period - 1) begin
                slow_cnt_int_cnt <= 0;
                slow_cnt <= slow_cnt + 1;
            end else begin 
                slow_cnt_int_cnt <= slow_cnt_int_cnt + 1;
            end
        end
    end : slow_counter
        
    //7Seg multiplexing 
    assign {>>{all_digits}} = data_to_display;
    assign single_digit = all_digits[current_digit];
    assign gpio.digits = ~(1 << current_digit);
    assign gpio.dp = dp_to_display[current_digit];
    
    //Refresh display
    always_ff@(posedge gpio.clk)
    begin : refresh_display
        if (refresh_counter == cycles_to_refresh_digit - 1) begin
            refresh_counter <= 0;
            current_digit <= current_digit + 1;
        end else begin
            refresh_counter <= refresh_counter + 1;
        end
    end : refresh_display
    
    //7Seg encoder
    always_comb
    begin : single_digit_to_7seg
        case(single_digit)
            4'h0: gpio.segments = 7'b0000001;
            4'h1: gpio.segments = 7'b1001111;
            4'h2: gpio.segments = 7'b0010010;
            4'h3: gpio.segments = 7'b0000110;
            4'h4: gpio.segments = 7'b1001100;
            4'h5: gpio.segments = 7'b0100100;
            4'h6: gpio.segments = 7'b0100000;
            4'h7: gpio.segments = 7'b0001111;
            4'h8: gpio.segments = 7'b0000000;
            4'h9: gpio.segments = 7'b0000100;
            4'ha: gpio.segments = 7'b0001000;
            4'hb: gpio.segments = 7'b1100000;
            4'hc: gpio.segments = 7'b0110001;
            4'hd: gpio.segments = 7'b1000010;
            4'he: gpio.segments = 7'b0110000;
            4'hf: gpio.segments = 7'b0111000;
            default: gpio.segments = 8'h1;
        endcase
    end : single_digit_to_7seg
    
endmodule
