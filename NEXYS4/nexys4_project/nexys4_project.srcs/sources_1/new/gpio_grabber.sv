`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.09.2018 20:30:38
// Design Name: 
// Module Name: gpio_grabber
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

module gpio_grabber(spi_if spi,
                    gpio_if.dut gpio_top,
                    gpio_if.grabber gpio_dut
                    );
                    
    //Memory registers
    reg [7:0] control_register = 8'h0;
    reg [15:0] sw_data = 16'h0;
    reg [15:0] sw_select = 16'h0;
    reg [4:0] btn_data = 5'h0;
    reg [4:0] btn_select = 5'h0;
    reg [15:0] led_data = 16'h0;
    reg [5:0] rgb_data = 6'h0;
    
    reg [7:0][7:0] sev_seg_disp_data = {8{8'h0}};
    
    reg [6:0] segments_data = 7'h0;
    reg dp_data = 1'b0;
    reg [7:0] digits_data = 8'h0;
    
    wire [4:0] btn = {gpio_dut.btn_center, gpio_dut.btn_up, gpio_dut.btn_left, gpio_dut.btn_right, gpio_dut.btn_down};
    wire [5:0] rgb = {gpio_dut.led17_R, gpio_dut.led17_G, gpio_dut.led17_B,
                        gpio_dut.led16_R, gpio_dut.led16_G, gpio_dut.led16_B};
    
    //GPIOs and display synchronization registers
    reg [1:0][15:0] sw_sr;
    reg [1:0][4:0] btn_sr;
    reg [1:0][15:0] led_sr;
    reg [1:0][5:0] rgb_sr;
    reg [1:0][6:0] segments_sr;
    reg [1:0] dp_sr;
    reg [1:0][7:0] digits_sr;
    
    //GPIOs and display signals
    parameter gpio_cycles_to_sample = main_clk_freq / gpio_sampling_rate;
    reg [31:0] gpio_sampling_cnt = 32'h0;
    parameter display_cycles_to_sample = main_clk_freq / display_sampling_rate;
    reg [31:0] display_sampling_cnt = 32'h0;
    

    //SPI synchronization registers
    reg [2:0] ss_sr;
    reg [2:0] sclk_sr;
    reg [1:0] mosi_sr;
    
    //SPI signals
    wire sclk_rising_edge = (sclk_sr[2:1] == 2'b01);
    wire sclk_falling_edge = (sclk_sr[2:1] == 2'b10);
    reg [2:0] receive_bit_cnt;
    reg [2:0] send_bit_cnt;
    reg [7:0] data_received =8'b0;
    reg [7:0] data_to_send = 8'haa;;
    
    assign spi.miso = data_to_send[7];
    
    //Muxes for switches and buttons
    genvar i;
    for (i = 0; i < 16; i = i + 1)
    begin
        assign gpio_dut.sw[i] = sw_select[i] ? sw_data[i] : gpio_top.sw[i];
    end
    
    assign gpio_dut.btn_center  = btn_select[center]    ? btn_data[center]  : gpio_top.btn_center;
    assign gpio_dut.btn_up      = btn_select[up]        ? btn_data[up]      : gpio_top.btn_up;
    assign gpio_dut.btn_left    = btn_select[left]      ? btn_data[left]    : gpio_top.btn_left;
    assign gpio_dut.btn_right   = btn_select[right]     ? btn_data[right]   : gpio_top.btn_right;
    assign gpio_dut.btn_down    = btn_select[down]      ? btn_data[down]    : gpio_top.btn_down;
    
    //Pass data from dut to top
    assign gpio_top.led = gpio_dut.led;
    assign gpio_top.led16_B = gpio_dut.led16_B;
    assign gpio_top.led16_G = gpio_dut.led16_G;
    assign gpio_top.led16_R = gpio_dut.led16_R;
    assign gpio_top.led17_B = gpio_dut.led17_B;
    assign gpio_top.led17_G = gpio_dut.led17_G;
    assign gpio_top.led17_R = gpio_dut.led17_R;
    
    assign gpio_top.segments = gpio_dut.segments;
    assign gpio_top.dp = gpio_dut.dp;
    assign gpio_top.digits = gpio_dut.digits;
    
    //Synchronization chain for dut
    always_ff@(posedge gpio_top.clk)
    begin : gpio_synch_chain
        sw_sr <= {sw_sr[0], gpio_dut.sw};
        btn_sr <= {btn_sr[0], btn};
        led_sr <= {led_sr[0], gpio_dut.led};        
        rgb_sr <= {rgb_sr[0], rgb};        
        segments_sr <= {segments_sr[0], gpio_dut.segments};
        dp_sr <= {dp_sr[0], gpio_dut.dp};
        digits_sr <= {digits_sr[0], gpio_dut.digits};
    end : gpio_synch_chain
    
    //Sampling of gpio
    always_ff@(posedge gpio_top.clk)
    begin : gpio_sampling
        if (gpio_sampling_cnt == gpio_cycles_to_sample - 1) begin
            gpio_sampling_cnt <= 32'h0;
            sw_data <= sw_sr[1];
            btn_data <= btn_sr[1];
            led_data <= led_sr[1];
            rgb_data <= rgb_sr[1];
        end else begin
            gpio_sampling_cnt <= gpio_sampling_cnt + 1;
        end
    end : gpio_sampling
    
    always_ff@(posedge gpio_top.clk)
    begin : display_sampling
        if (display_sampling_cnt == display_cycles_to_sample - 1) begin
            display_sampling_cnt <= 32'h0;
            segments_data <= segments_sr[1];
            dp_data <= dp_sr[1];
            digits_data <= digits_sr[1];
        end else begin
            display_sampling_cnt <= display_sampling_cnt + 1;
        end
    end : display_sampling
    
    always_comb
    begin : display_decode
        integer i;
        for (i = 0; i < 8; i = i + 1)
        begin
            sev_seg_disp_data[i] = !digits_data[i] ? {dp_data, segments_data} : sev_seg_disp_data[i]; 
        end
            
    end : display_decode
            
    //Synchronization chain for SPI
    always_ff@(posedge spi.clk)
    begin : spi_synch_chain
        ss_sr <= {ss_sr[1:0], spi.ss};
        sclk_sr <= {sclk_sr[1:0], spi.sclk};
        mosi_sr <= {mosi_sr[0], spi.mosi};
    end : spi_synch_chain
    
    //SPI send/receive block
    always_ff@(posedge spi.clk)
    begin : spi_send_receive
        if (ss_sr[2] == ~ss_active) begin
            receive_bit_cnt <= 3'b0;
            send_bit_cnt <= 3'b0;
        end else begin
            if (sclk_falling_edge) begin
                send_bit_cnt <= send_bit_cnt + 1;
                data_to_send = {data_to_send[6:0], 1'b0};
            end
            if (sclk_rising_edge) begin
                receive_bit_cnt <= receive_bit_cnt + 1;
                data_received <= {data_received[6:0], spi.mosi};
            end
        end
    end : spi_send_receive
                    
endmodule
