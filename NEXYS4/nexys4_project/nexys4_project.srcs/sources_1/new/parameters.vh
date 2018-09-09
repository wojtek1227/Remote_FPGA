`ifndef _parameters_vh_
`define _parameters_vh_


`define _debug_
//TOP
parameter main_clk_freq = 100000000; //Hz

//DUT
`ifndef _debug_
parameter display_refresh_rate = 125; // Hz
`else
parameter display_refresh_rate = 1000000; // Hz
`endif
//Grabber
`ifndef _debug_
parameter gpio_sampling_rate  = 50; //Hz
`else
parameter gpio_sampling_rate  = 10000000; //Hz
`endif
parameter display_sampling_rate = main_clk_freq; //Hz
parameter fsm_timeout = 1; //s

//SPI
parameter ss_active = 1'b0;
parameter sclk_active = 1'b0;


//Numbers of buttons
parameter center = 4;
parameter up = 3;
parameter left = 2;
parameter right = 1;
parameter down = 0;

//RGBs ids
parameter led16_B_id = 0;
parameter led16_G_id = 1;
parameter led16_R_id = 2;
parameter led17_B_id = 3;
parameter led17_G_id = 4;
parameter led17_R_id = 5;

//Instructions
parameter number_of_inst = 4;
parameter RESET = 8'hca;
parameter CLEAR = 8'hcd;
parameter WRITE = 8'had;
parameter READ = 8'hed;
//Addresses
parameter sw_data_low_addr      = 8'h1;
parameter sw_data_high_addr     = 8'h2;
parameter sw_select_low_addr    = 8'h3;
parameter sw_select_high_addr   = 8'h4;
parameter btn_data_addr         = 8'h5;
parameter btn_select_addr       = 8'h6;
parameter led_data_low_addr     = 8'h7;
parameter led_data_high_addr    = 8'h8;
parameter digit_0_addr          = 8'h9;
parameter digit_1_addr          = 8'ha;
parameter digit_2_addr          = 8'hb;
parameter digit_3_addr          = 8'hc;
parameter digit_4_addr          = 8'hd;
parameter digit_5_addr          = 8'he;
parameter digit_6_addr          = 8'hf;
parameter digit_7_addr          = 8'h10;
parameter mem_addr_end          = 8'h11;

`endif