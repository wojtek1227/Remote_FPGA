`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wojciech Caputa
// 
// Create Date: 10.09.2018 00:25:03
// Design Name: 
// Module Name: spi_test
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

parameter period = 10;
parameter spi_period = period*25;

program spi_test(input wire miso, output reg ss, sclk, mosi);
    logic [7:0] data;
    initial begin
        init_spi;
        #100
        spi_write(8'h4, 8'hff);
        spi_write(8'h2, 8'hcd);
        spi_read(8'h8, data);
    end


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
            $display("Reading data in address %h @ %g\n", address, $time);
            spi_send(READ);
            spi_send(address);
            fork
                spi_send(8'h0);
                spi_receive(data);
            join
            $display ("Data received %h @ %g", data, $time);
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
endprogram
