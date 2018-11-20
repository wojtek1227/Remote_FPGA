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
    
    input wire ss,
    input wire sclk,
    input wire mosi,
    output wire miso,   
     
    output wire [15:0] led,
    output wire led16_B,
    output wire led16_G,
    output wire led16_R,
    output wire led17_B,
    output wire led17_G,
    output wire led17_R,
    
    output wire [6:0] segments,
    output wire dp,
    output wire [7:0] digits
    );
    
    gpio_if gpio_dut(clk);

    grabber_wrapper grabber(
    .sw_top(sw),      
    .led_top(led),    
    .led16_B_top(led16_B),       
    .led16_G_top(led16_G),       
    .led16_R_top(led16_R),       
    .led17_B_top(led17_B),       
    .led17_G_top(led17_G),       
    .led17_R_top(led17_R),       
    .segments_top(segments),
    .dp_top(dp),            
    .digits_top(digits),  
    .btn_center_top(btn_center),     
    .btn_up_top(btn_up),         
    .btn_left_top(btn_left),       
    .btn_right_top(btn_right),      
    .btn_down_top(btn_down),       
    
    .sw_dut(gpio_dut.sw),     
    .led_dut(gpio_dut.led),     
    .led16_B_dut(gpio_dut.led16_B),        
    .led16_G_dut(gpio_dut.led16_G),        
    .led16_R_dut(gpio_dut.led16_R),        
    .led17_B_dut(gpio_dut.led17_B),        
    .led17_G_dut(gpio_dut.led17_G),        
    .led17_R_dut(gpio_dut.led17_R),        
    .segments_dut(gpio_dut.segments), 
    .dp_dut(gpio_dut.dp),             
    .digits_dut(gpio_dut.digits),   
    .btn_center_dut(gpio_dut.btn_center),    
    .btn_up_dut(gpio_dut.btn_up),        
    .btn_left_dut(gpio_dut.btn_left),      
    .btn_right_dut(gpio_dut.btn_right),     
    .btn_down_dut(gpio_dut.btn_down),  
        
    .sclk(sclk),               
    .mosi(mosi),               
    .ss(ss),                 
    .miso(miso),               
    .clk(clk)
    );             
    dut_wrapper wrapper(gpio_dut);
    

endmodule
