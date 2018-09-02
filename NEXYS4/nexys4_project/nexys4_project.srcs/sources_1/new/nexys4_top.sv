`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wojciech Caputa
// 
// Create Date: 01.09.2018 13:50:56
// Design Name: 
// Module Name: nexys4_top
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


module nexys4_top(
    input wire clk,
    input wire [15:0] sw,
    
    input wire btn_center,
    input wire btn_up,
    input wire btn_left,
    input wire btn_right,
    input wire btn_down,
    
    output reg [15:0] led,
    output reg led16_B,
    output reg led16_G,
    output reg led16_R,
    output reg led17_B,
    output reg led17_G,
    output reg led17_R,
    
    output reg [6:0] segments,
    output reg dp,
    output reg [7:0] digits
    );
    
    spi_if spi(clk);
    gpio_if gpio_top(clk);
    gpio_if gpio_dut(clk);
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

    gpio_grabber grab(spi, gpio_top, gpio_dut);
    dut_example dut(gpio_dut);

endmodule
