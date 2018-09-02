`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.09.2018 19:09:45
// Design Name: 
// Module Name: dut_example
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


module dut_example(gpio_if gpio);
    
    reg [3:0] bcd;
    reg [3:0] display [7:0] = {4'hd, 4'he, 4'ha, 4'hd, 4'hb, 4'he, 4'he, 4'hf};
    reg [31:0] counter = 0;
    reg [3:0] current_digit = 0;
    
    
    assign gpio.led = gpio.sw;
    assign gpio.led16_R = 1;
    
    assign bcd = display[current_digit];
    assign gpio.digits = ~(1 << current_digit);
    
    always_ff@(posedge gpio.clk)
    begin : refresh_display
        if (counter == 100000 - 1) begin
            counter <= 0;
            current_digit <= current_digit + 1;
        end else begin
            counter <= counter + 1;
        end
    end : refresh_display
    
    always_comb
    begin : bcd_to_7seg
        case(bcd)
            4'h0: gpio.segments = 7'b0000001;
            4'h1: gpio.segments = 7'b1001111;
            4'h2: gpio.segments = 7'b0010010;
            4'h3: gpio.segments = 7'b0000110;
            4'h4: gpio.segments = 7'b1001100;
            4'h5: gpio.segments = 7'b0100100;
            4'h6: gpio.segments = 7'b0100000;
            4'h7: gpio.segments = 7'b0001111;
            4'h8: gpio.segments = 7'b0000000;
            4'h9: gpio.segments = 7'b0000100;
            4'ha: gpio.segments = 7'b0001000;
            4'hb: gpio.segments = 7'b1100000;
            4'hc: gpio.segments = 7'b0110001;
            4'hd: gpio.segments = 7'b1000010;
            4'he: gpio.segments = 7'b0110000;
            4'hf: gpio.segments = 7'b0111000;
            default: gpio.segments = 8'h1;
        endcase
    end : bcd_to_7seg
    
endmodule
