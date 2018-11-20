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
    input logic [15:0] sw_top,
    output logic [15:0] led_top,
    output logic led16_B_top,
    output logic led16_G_top,
    output logic led16_R_top,
    output logic led17_B_top,
    output logic led17_G_top,
    output logic led17_R_top,
    output logic [6:0] segments_top,
    output logic dp_top,
    output logic [7:0] digits_top,
    input logic btn_center_top,
    input logic btn_up_top,
    input logic btn_left_top,
    input logic btn_right_top,
    input logic btn_down_top,
	
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
    input logic miso,
    input logic clk
    );
    
    spi_if spi(.*);

    gpio_if gpio_top(clk);

    assign gpio_top.sw = sw_top;
    assign gpio_top.btn_center = btn_center_top;
    assign gpio_top.btn_up = btn_up_top;
    assign gpio_top.btn_left = btn_left_top;
    assign gpio_top.btn_right = btn_right_top;
    assign gpio_top.btn_down = btn_down_top;
    
    assign led_top = gpio_top.led;
    assign led16_B_top = gpio_top.led16_B;
    assign led16_G_top = gpio_top.led16_G;
    assign led16_R_top = gpio_top.led16_R;
    assign led17_B_top = gpio_top.led17_B;
    assign led17_G_top = gpio_top.led17_G;
    assign led17_R_top = gpio_top.led17_R;
    assign segments_top = gpio_top.segments;
    assign dp_top = gpio_top.dp;
    assign digits_top = gpio_top.digits;

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
    assign btn_up_dut = gpio_dut.btn_center;
    assign btn_left_dut = gpio_dut.btn_center;
    assign btn_right_dut = gpio_dut.btn_center;
    assign btn_down_dut = gpio_dut.btn_center;
    
    gpio_grabber grabber(.*);
    
    
    
    
    
endmodule
