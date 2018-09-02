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


module dut_example(gpio_if.dut gpio);

    parameter clk_freq_MHz = 100000000;
    
    
    //7Seg related 
    parameter display_refresh_rate = 125; // Hz
    parameter cycles_to_refresh_digit = clk_freq_MHz/display_refresh_rate/8;
    
    reg [3:0] single_digit;
    reg [7:0][3:0] all_digits ;
    reg [31:0] refresh_counter = 0;
    reg [3:0] current_digit = 0;
    reg [31:0] data_to_display = 32'hdeadbeef;

    //Buttons and RGB
    parameter btn_sample_rate = 1000000;          //Buttons sampling rage in Hz
    parameter cycles_to_sample = clk_freq_MHz/btn_sample_rate;
    
    enum {center = 4, up = 3, left = 2, right = 1, down = 0} button;
    reg [4:0] buttons;                      //Array for buttons
    reg [1:0][4:0] buttons_r ;                   //Registers for synch buttons to clk
//    reg [4:0] buttons_r2 ;                   //Registers for synch buttons to clk
    reg [1:0][4:0] buttons_sampled;            //Registers for buttons sampled values
//    reg [4:0] buttons_sampled_2;            //Registers for buttons sampled values
    reg [4:0] buttons_rising_edge;
    reg [31:0] sampling_counter = 0;
    reg [2:0] led16 = 3'b001;
    reg [2:0] led17 = 3'b100;
    reg chose_led = 1'b0;

    assign buttons = {gpio.btn_center, gpio.btn_up, gpio.btn_left, gpio.btn_right, gpio.btn_down};
    
    always_ff@(posedge gpio.clk)
    begin : buttons_synch
        buttons_r <= {buttons_r[0], buttons};
    end : buttons_synch
    
    always_ff@(posedge gpio.clk)
    begin : buttons_edge_detect
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
    end : buttons_edge_detect
    
    genvar i;
    for (i = 0; i < 5; i = i + 1)
    begin
        assign buttons_rising_edge[i] = ({buttons_sampled[1][i], buttons_sampled[0][i]} == 2'b01) ? 1 : 0;
    end
//    assign buttons_rising_edge[0] = ({buttons_sampled_2[0], buttons_sampled_1[0]} == 2'b01);
//    assign buttons_rising_edge[1] = ({buttons_sampled_2[1], buttons_sampled_1[1]} == 2'b01);
//    assign buttons_rising_edge[2] = ({buttons_sampled_2[2], buttons_sampled_1[2]} == 2'b01);
//    assign buttons_rising_edge[3] = ({buttons_sampled_2[3], buttons_sampled_1[3]} == 2'b01);
//    assign buttons_rising_edge[4] = ({buttons_sampled_2[4], buttons_sampled_1[4]} == 2'b01);    


    assign gpio.led16_R = chose_led ? led16[2] : 0;
    assign gpio.led16_G = chose_led ? led16[1] : 0;
    assign gpio.led16_B = chose_led ? led16[0] : 0;
   
    assign gpio.led17_R = ~chose_led ? led17[2] : 0;
    assign gpio.led17_G = ~chose_led ? led17[1] : 0;
    assign gpio.led17_B = ~chose_led ? led17[0] : 0;
    
    //Switches and LEDs
    assign gpio.led = gpio.sw;
    
    //7Seg
    assign {>>{all_digits}} = data_to_display;
    assign single_digit = all_digits[current_digit];
    assign gpio.digits = ~(1 << current_digit);
    
    always_ff@(posedge gpio.clk)
    begin : refresh_display
        if (refresh_counter == cycles_to_refresh_digit - 1) begin
            refresh_counter <= 0;
            current_digit <= current_digit + 1;
        end else begin
            refresh_counter <= refresh_counter + 1;
        end
    end : refresh_display
    
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