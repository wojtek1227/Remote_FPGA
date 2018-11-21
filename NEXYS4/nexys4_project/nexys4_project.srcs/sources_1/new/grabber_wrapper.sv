`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.11.2018 19:42:46
// Design Name: 
// Module Name: grabber_wrapper
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


module grabber_wrapper(
    input logic [15:0] sw,
    output logic [15:0] led,
    output logic led16_B,
    output logic led16_G,
    output logic led16_R,
    output logic led17_B,
    output logic led17_G,
    output logic led17_R,
    output logic [6:0] segments,
    output logic dp,
    output logic [7:0] digits,
    input logic btn_center,
    input logic btn_up,
    input logic btn_left,
    input logic btn_right,
    input logic btn_down,
	
    output logic [15:0] sw_dut,
    input logic [15:0] led_dut,
    input logic led16_B_dut,
    input logic led16_G_dut,
    input logic led16_R_dut,
    input logic led17_B_dut,
    input logic led17_G_dut,
    input logic led17_R_dut,
    input logic [6:0] segments_dut,
    input logic dp_dut,
    input logic [7:0] digits_dut,
    output logic btn_center_dut,
    output logic btn_up_dut,
    output logic btn_left_dut,
    output logic btn_right_dut,
    output logic btn_down_dut,
	
    input logic sclk,
    input logic mosi,
    input logic ss,
    output logic miso,
    input logic clk
    );
    
    spi_if spi(.*);

    gpio_if gpio_top(clk);

    assign gpio_top.sw = sw;
    assign gpio_top.btn_center = btn_center;
    assign gpio_top.btn_up = btn_up;
    assign gpio_top.btn_left = btn_left;
    assign gpio_top.btn_right = btn_right;
    assign gpio_top.btn_down = btn_down;
    
    assign led = gpio_top.led;
    assign led16_B = gpio_top.led16_B;
    assign led16_G = gpio_top.led16_G;
    assign led16_R = gpio_top.led16_R;
    assign led17_B = gpio_top.led17_B;
    assign led17_G = gpio_top.led17_G;
    assign led17_R = gpio_top.led17_R;
    assign segments = gpio_top.segments;
    assign dp = gpio_top.dp;
    assign digits = gpio_top.digits;

    gpio_if gpio_dut(clk);
    
    assign sw_dut = gpio_dut.sw;
    assign gpio_dut.led = led_dut;
    assign gpio_dut.led16_B = led16_B_dut;
    assign gpio_dut.led16_G = led16_G_dut;
    assign gpio_dut.led16_R = led16_R_dut;
    assign gpio_dut.led17_B = led17_B_dut;
    assign gpio_dut.led17_G = led17_G_dut;
    assign gpio_dut.led17_R = led17_R_dut;
    assign gpio_dut.segments = segments_dut;
    assign gpio_dut.dp = dp_dut;
    assign gpio_dut.digits = digits_dut;
    assign btn_center_dut = gpio_dut.btn_center;
    assign btn_up_dut = gpio_dut.btn_up;
    assign btn_left_dut = gpio_dut.btn_left;
    assign btn_right_dut = gpio_dut.btn_right;
    assign btn_down_dut = gpio_dut.btn_down;
    
    gpio_grabber grabber(.*);
    
    
    
    
    
endmodule
