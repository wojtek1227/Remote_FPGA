`ifndef _parameters_vh_
`define _parameters_vh_


//`define _debug_
//TOP
parameter main_clk_freq = 100000000; //Hz

//Grabber
`ifndef _debug_
parameter gpio_sampling_rate  = 50; //Hz
`else
parameter gpio_sampling_rate  = 10000000; //Hz
`endif
parameter display_sampling_rate = main_clk_freq; //Hz

//Register default values
parameter control_register_init_value = 8'h3;
parameter sw_data_init_value = 16'h0;
parameter sw_select_init_value = 16'h0;
parameter btn_data_init_value = 5'h0;
parameter btn_select_init_value = 5'h0;
parameter default_gpio_cycles_to_sample = main_clk_freq / gpio_sampling_rate;
parameter default_display_cycles_to_sample = main_clk_freq / display_sampling_rate;
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


`endif