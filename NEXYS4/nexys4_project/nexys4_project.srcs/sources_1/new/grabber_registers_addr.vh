`ifndef _grabber_registers_addr_vh_
`define _grabber_registers_addr_vh_

//Instructions
parameter CLEAR = 8'hcd;
parameter WRITE = 8'had;
parameter READ  = 8'hed;

//Addresses
//RW registers
parameter sw_data_low_addr      = 8'h1;
parameter sw_data_high_addr     = 8'h2;
parameter sw_select_low_addr    = 8'h3;
parameter sw_select_high_addr   = 8'h4;
parameter btn_data_addr         = 8'h5;
parameter btn_select_addr       = 8'h6;
//Control registers
parameter control_register_addr = 8'h7;
//32bit display sampling counter overflow register Little endian addressing
//Byte 0 at 8'h7
//Byte 1 at 8'h8
//Byte 2 at 8'h9
//Byte 3 at 8'ha 
parameter display_sampling_cnt_ovf_addr  = 8'h8;
//32bit gpio sampling counter overflow register Little endian addressing
//Byte 0 at 8'hc
//Byte 1 at 8'hd
//Byte 2 at 8'he
//Byte 3 at 8'hf 
parameter gpio_sampling_cnt_ovf_addr = 8'hc;
//Increment this address when adding new RW registers
parameter rw_mem_end_addr       = 8'h10;

//RO registers
parameter ro_mem_addr_start     = 8'h80;
parameter rgb_data_addr         = 8'h80; 
parameter led_data_low_addr     = 8'h81;     
parameter led_data_high_addr    = 8'h82;     
parameter digit_0_data_addr     = 8'h83;     
parameter digit_1_data_addr     = 8'h84;     
parameter digit_2_data_addr     = 8'h85;     
parameter digit_3_data_addr     = 8'h86;     
parameter digit_4_data_addr     = 8'h87;     
parameter digit_5_data_addr     = 8'h88;     
parameter digit_6_data_addr     = 8'h89;    
parameter digit_7_data_addr     = 8'h8a;

parameter ro_mem_addr_end       = 8'h8b;

`endif /* _GRABBER_REGISTERS_ADDR_H_ */