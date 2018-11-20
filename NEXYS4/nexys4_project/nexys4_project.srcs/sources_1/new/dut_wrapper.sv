`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.11.2018 20:38:25
// Design Name: 
// Module Name: dut_wrapper
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


module dut_wrapper(gpio_if.dut gpio);

//    dut_example dut(gpio);
    dut_vhdl dut(.led(gpio.led),
                .led16_B(gpio.led16_B),
                .led16_G(gpio.led16_G),
                .led16_R(gpio.led16_R),
                .led17_B(gpio.led17_B),
                .led17_G(gpio.led17_G),
                .led17_R(gpio.led17_R),
                .segments(gpio.segments),
                .dp(gpio.dp),
                .digits(gpio.digits),
                .btn_center(gpio.btn_center),
                .btn_up(gpio.btn_up),
                .btn_left(gpio.btn_left),
                .btn_right(gpio.btn_right),
                .btn_down(gpio.btn_down),
                .sw(gpio.sw));
endmodule
