`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.09.2018 20:30:38
// Design Name: 
// Module Name: gpio_grabber
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

module gpio_grabber(spi_if.slave spi,
                    gpio_if.dut gpio_top,
                    gpio_if.grabber gpio_dut
                    );
                    
    //Memory registers
    reg [7:0] control_register = 8'h0;
    reg [15:0] sw_data = 16'h0;
    reg [15:0] sw_select = 16'h0;
    reg [4:0] btn_data = 5'h0;
    reg [4:0] btn_select = 5'h0;
    reg [15:0] led_data = 16'h0;
    reg [5:0] rgb_data = 6'h0;
    reg [7:0][7:0] sev_seg_disp_data = {8{8'h0}};
    
    wire [5:0] rgb = {gpio_dut.led17_R, gpio_dut.led17_G, gpio_dut.led17_B,
                        gpio_dut.led16_R, gpio_dut.led16_G, gpio_dut.led16_B};
    
    //Synchronization registers
    reg [15:0] led_sr;
    reg [5:0] rgb_sr;
    reg [1:0][6:0] segments_sr;
    reg [1:0] dp_sr;
    reg [1:0][7:0] digits_sr;
    
    //Muxes for switches and buttons
    genvar i;
    for (i = 0; i < 16; i = i + 1)
    begin
        assign gpio_dut.sw[i] = sw_select[i] ? sw_data[i] : gpio_top.sw[i];
    end
    
    assign gpio_dut.btn_center  = btn_select[center]    ? btn_data[center]  : gpio_top.btn_center;
    assign gpio_dut.btn_up      = btn_select[up]        ? btn_data[up]      : gpio_top.btn_up;
    assign gpio_dut.btn_left    = btn_select[left]      ? btn_data[left]    : gpio_top.btn_left;
    assign gpio_dut.btn_right   = btn_select[right]     ? btn_data[right]   : gpio_top.btn_right;
    assign gpio_dut.btn_down    = btn_select[down]      ? btn_data[down]    : gpio_top.btn_down;
    
    //Pass data from dut to top
    assign gpio_top.led = gpio_dut.led;
    assign gpio_top.led16_B = gpio_dut.led16_B;
    assign gpio_top.led16_G = gpio_dut.led16_G;
    assign gpio_top.led16_R = gpio_dut.led16_R;
    assign gpio_top.led17_B = gpio_dut.led17_B;
    assign gpio_top.led17_G = gpio_dut.led17_G;
    assign gpio_top.led17_R = gpio_dut.led17_R;
    
    assign gpio_top.segments = gpio_dut.segments;
    assign gpio_top.dp = gpio_dut.dp;
    assign gpio_top.digits = gpio_dut.digits;
    
    //Synchronization chain for dut
    always_ff@(posedge gpio_top.clk)
    begin : synch_chain
        led_sr <= gpio_dut.led;
        led_data <= led_sr;
        
        rgb_sr <= rgb;
        rgb_data <= rgb_sr;
        
        segments_sr <= {segments_sr[0], gpio_dut.segments};
        dp_sr <= {dp_sr[0], gpio_dut.dp};
        digits_sr <= {digits_sr[0], gpio_dut.digits};
    end : synch_chain

endmodule
