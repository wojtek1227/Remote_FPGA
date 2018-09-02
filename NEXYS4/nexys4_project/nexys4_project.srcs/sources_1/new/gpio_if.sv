`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wojciech Caputa
// 
// Create Date: 01.09.2018 12:03:10
// Design Name: 
// Module Name: gpio_if
// Project Name: nexys4_project
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


interface gpio_if(input wire clk);
    //Switches
    logic [15:0] sw;
    
    //Leds
    logic [15:0] led;
    logic led16_B;
    logic led16_G;
    logic led16_R;
    logic led17_B;
    logic led17_G;
    logic led17_R;
    
    //7 segment display
    //Cathodes
    logic [6:0] segments; //a|b|c|d|e|f|g
    logic dp;
    //Anodes
    logic [7:0] digits;
    
    //Buttons
    logic btn_center;
    logic btn_up;
    logic btn_left;
    logic btn_right;
    logic btn_down;

    //===================================
    //Modport for user's DUT
    //===================================
    modport dut (input clk, sw, btn_center, btn_up, btn_left, btn_right, btn_down,
                output led, led16_B, led16_G, led16_R, led17_B, led17_G, led17_R,
                segments, dp, digits);
                
    //===================================
    //Modport for testbench and grabber
    //===================================
    modport grabber (input clk, led, led16_B, led16_G, led16_R, led17_B, led17_G,
                    led17_R, segments, dp, digits,
                    output sw, btn_center, btn_up, btn_left, btn_right, btn_down);
endinterface
