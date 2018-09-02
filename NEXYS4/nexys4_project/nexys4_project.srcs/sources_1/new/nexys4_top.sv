`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
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
    gpio_if gpio(.*);
//    gpio_if gpio();
//    .clk(clk),          
//    .sw(sw),
//    .btn_center     (btn_center),    
//    .btn_up         (btn_up),        
//    .btn_left       (btn_left),      
//    .btn_right      (btn_right),     
//    .btn_down       (btn_down),                    
//    .led            (led),          
//    .led16_B        (led16_B),       
//    .led16_G        (led16_G),       
//    .led16_R        (led16_R),       
//    .led17_B        (led17_B),       
//    .led17_G        (led17_G),       
//    .led17_R        (led17_R),                                    
//    .segments       (segments),     
//    .dp             (dp),            
//    .digits         (digits)        
//    );
    
    dut_example dut(.*);
//    assign led = sw;
//    assign led16_B = 1;
//    assign led16_G = 0;
//    assign led16_R = 0;
    
//    assign led17_B = 0;
//    assign led17_G = 0;
//    assign led17_R = 1;
    
//    assign segments = 0;
//    assign dp = 0;
//    assign digits = 0;

endmodule
