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


interface gpio_if(
    //Switches
    input logic clk,
    input logic [15:0] sw,
    
    //Leds
    output logic [15:0] led,
    output logic led16_B,
    output logic led16_G,
    output logic led16_R,
    output logic led17_B,
    output logic led17_G,
    output logic led17_R,
    
    //7 segment display
    //Cathodes
    output logic [6:0] segments, //a|b|c|d|e|f|g
    output logic dp,
    //Anodes
    output logic [7:0] digits,
    
    //Buttons
    input logic btn_center,
    input logic btn_up,
    input logic btn_left,
    input logic btn_right,
    input logic btn_down
    );
    //===================================
    //Modport for user's DUT
    //===================================
//    modport dut (input clk, sw, btn_center, btn_up, btn_left, btn_right, btn_down,
//                output led, led16_B, led16_G, led16_R, led17_B, led17_G, led17_R,
//                segments, dp, digits);
                
    //===================================
    //Modport for testbench and grabber
    //===================================
//    modport grabber (input clk, led, led16_B, led16_G, led16_R, led17_B, led17_G,
//                    led17_R, segments, dp, digits,
//                    output sw, btn_center, btn_up, btn_left, btn_right, btn_down);
endinterface
