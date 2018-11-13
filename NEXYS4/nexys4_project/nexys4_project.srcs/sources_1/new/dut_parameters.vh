`ifndef _dut_parameters_vh_
`define _dut_parameters_vh_


//`define _debug_

//DUT
`ifndef _debug_
parameter display_refresh_rate = 125; // Hz
`else
parameter display_refresh_rate = 1000000; // Hz
`endif



`ifndef _debug_
parameter slow_cnt_freq = 1;
parameter fast_cnt_freq = 10;
`else
parameter slow_cnt_freq = 1000000;
parameter fast_cnt_freq = 10000000;
`endif

`endif