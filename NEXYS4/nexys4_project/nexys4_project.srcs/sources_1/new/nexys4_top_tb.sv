`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wojciech Caputa
// 
// Create Date: 01.09.2018 19:55:31
// Design Name: 
// Module Name: nexys4_top_tb
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


module nexys4_top_tb();

    parameter period = 10;
    logic clk;        
    logic [15:0] sw;  
                 
    logic btn_center; 
    logic btn_up;     
    logic btn_left;   
    logic btn_right;  
    logic btn_down;   
                 
    logic [15:0] led; 
    logic led16_B;    
    logic led16_G;    
    logic led16_R;    
    logic led17_B;    
    logic led17_G;    
    logic led17_R;    
                 
    logic [6:0] segments;
    logic dp;        
    logic [7:0] digits;
    
    nexys4_top top(.*);
    initial
    begin
        clk = 0;
        #10 sw = 16'had;
        #25 btn_center = 0;
        #30 btn_down = 1;
        #45 btn_up = 0;
        #50 btn_left = 1;
        #60 btn_right = 0;      
        

        #50000000 $finish;
    end
    
    always #5 clk++;

endmodule
