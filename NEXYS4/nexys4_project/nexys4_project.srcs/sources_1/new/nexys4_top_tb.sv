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
`include "parameters.vh"

module nexys4_top_tb();

    parameter period = 10;
    parameter spi_period = period*25;
    
    
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
    
    logic ss;
    logic sclk;
    logic mosi;
    logic miso;
    
    nexys4_top top(.*);
    initial
    begin
        clk = 0;
        #10 sw = 16'hdead;
        init_buttons;      
        init_spi;
        #10;
        spi_send(8'haa);

        #50000000 $finish;
    end
    
    always #(period/2) clk++;
    
    task init_buttons;
        btn_center = 1'b0;
        btn_up     = 1'b0;
        btn_left   = 1'b0;
        btn_right  = 1'b0;
        btn_down   = 1'b0;
    endtask
    
    task use_button;
        input [2:0] button;
        begin
        
        end
    endtask
    
    task init_spi;
        begin
            ss = ~ss_active;
            sclk = ~sclk_active;
            mosi = 1'b0;
            miso = 1'b0;
        end
    endtask
    
    task spi_send;
        input [7:0] data_to_send;
        integer i;
        begin
            ss = ss_active;
            for (i = 0; i < 7; i++)
            begin
                mosi = data_to_send[7-i];
                sclk = sclk_active;
                #(spi_period/2);
                sclk = ~sclk_active;
                #(spi_period/2);
            end
            mosi = data_to_send[0];
            sclk = sclk_active;
            #(spi_period/2);
            sclk = ~sclk_active;
            ss = ~ss_active;
            #(spi_period);
        end
    endtask

endmodule
