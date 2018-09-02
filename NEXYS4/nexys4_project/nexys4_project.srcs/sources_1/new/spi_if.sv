`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.09.2018 12:38:12
// Design Name: 
// Module Name: spi_if
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


interface spi_if(input wire clk);
    logic sck;
    logic mosi;
    logic miso;
    logic ss;
    
    //===================================
    //Modport for user's DUT
    //===================================
    modport master (input clk, miso,
                    output sck, mosi, ss);
                
    //===================================
    //Modport for testbench and grabber
    //===================================
    modport slave (input clk, sck, mosi, ss,
                   output miso);
endinterface
