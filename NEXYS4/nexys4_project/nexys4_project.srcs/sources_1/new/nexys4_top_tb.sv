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
`include "grabber_registers_addr.vh"


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
    
    logic [7:0] data_received;
    nexys4_top top(.*);

    initial
    begin
        init_spi;
        clk = 0;
        #10 sw = 16'hbeef;
        init_buttons;      
        #10;
        test_spi_read_write();
        test_spi_read_all();
        test_read_3x();
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
 
        end
    endtask
    
    task spi_receive;
        output [7:0] data_received;
        begin
            repeat (8) @(posedge sclk) data_received = {data_received[6:0] , miso};
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
            #(spi_period/2);
            ss = ~ss_active;
        end
    endtask

    task spi_write;
        input [7:0] address;
        input [7:0] data;
        begin
            $display("Writing %h in address %h @ %g\n", data, address, $time); 
            spi_send(WRITE);
            spi_send(address);
            spi_send(data);
        end
    endtask
    
    task spi_read;
        input [7:0] address;
        output [7:0] data;
        begin
            spi_send(READ);
            spi_send(address);
            fork
                spi_send(8'h0);
                spi_receive(data);
            join
        end
    endtask
    
    task spi_clear;
        input [7:0] address;
        begin
            $display("Clearing data in address %h @%g", address, $time);
            spi_send(CLEAR);
            spi_send(address);
        end
    endtask
    
    task test_spi_read_write;
        begin
            automatic logic [7:0] data;
            spi_write(1, 8'haa);
            spi_write(2, 8'haa);
            spi_write(3, 8'hff);
            spi_write(4, 8'hff);
            spi_write(5, 8'h1);
            spi_write(6, 8'hff);
            for(int i = 1; i < 7; i = i + 1)
            begin
                spi_read(i,data);
//                assert (data == i) $display("Read value is correct, time:%g", $time);
            end
        end
    endtask
    
    task test_spi_read_all;
        begin
            automatic logic [7:0] data;
            for(int i = 0; i < btn_select_addr + 1; i = i + 1)
            begin
                $display("Reading address %h, %g", i, $time);
                spi_read(i, data);
                $display("Reading address %h, data: %h, %g", i, data, $time);
            end
        end
    endtask
    
    task test_read_3x;
        begin
            automatic logic [7:0] data;
            $display("3x read test @:%g", $time);
            for(int i = 0; i < 9; i = i + 1)
            begin
                spi_read(8'h1, data);
                $display("Data read: %h at: %g", data, $time);
            end
        end
    endtask    

endmodule
