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
    
    gpio_if gpio(clk);
    assign gpio.sw = sw;
    assign gpio.btn_center = btn_center;
    assign gpio.btn_up = btn_up;
    assign gpio.btn_left = btn_left;
    assign gpio.btn_right = btn_right;
    assign gpio.btn_down = btn_down;
    
    assign led = gpio.led;
    assign led16_B = gpio.led16_B;
    assign led16_G = gpio.led16_G;
    assign led16_R = gpio.led16_R;
    assign led17_B = gpio.led17_B;
    assign led17_G = gpio.led17_G;
    assign led17_R = gpio.led17_R;
    assign segments = gpio.segments;
    assign dp = gpio.dp;
    assign digits = gpio.digits;

    
    dut_example dut(.*);

endmodule
