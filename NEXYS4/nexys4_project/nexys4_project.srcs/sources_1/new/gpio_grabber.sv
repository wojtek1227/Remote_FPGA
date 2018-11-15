`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wojciech Caputa
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
`include "grabber_registers_addr.vh"

module gpio_grabber(spi_if spi,
                    gpio_if.dut gpio_top,
                    gpio_if.grabber gpio_dut
                    );
                    
    //Memory registers
    logic [7:0] control_register = control_register_init_value;
    logic [15:0] sw_data = sw_data_init_value;
    logic [15:0] sw_select = sw_select_init_value;
    logic [4:0] btn_data = btn_data_init_value;
    logic [4:0] btn_select = btn_select_init_value;
    logic [15:0] led_data = 16'h0;
    logic [5:0] rgb_data = 6'h0;
    
    //Demuxed display data
    logic [7:0][7:0] sev_seg_disp_data = {8{8'h0}};
    
    //Overflow registers for sampling counters LE addresssing
    logic [31:0] display_sampling_cnt_ovf = default_display_cycles_to_sample;
    logic [31:0] gpio_sampling_cnt_ovf = default_gpio_cycles_to_sample;
    
    wire gpio_sampling_rst = control_register[0];
    wire display_sampling_rst = control_register[1];
     
    wire [4:0] btn = {gpio_dut.btn_center, 
                        gpio_dut.btn_up,
                        gpio_dut.btn_left, 
                        gpio_dut.btn_right,
                        gpio_dut.btn_down};
                        
    wire [5:0] rgb = {gpio_dut.led17_R, 
                        gpio_dut.led17_G, 
                        gpio_dut.led17_B,
                        gpio_dut.led16_R, 
                        gpio_dut.led16_G, 
                        gpio_dut.led16_B};
    
    //Sampled display data
    logic [6:0] segments_data = 7'h0;
    logic dp_data = 1'b0;
    logic [7:0] digits_data = 8'h0;
    
    //LED and display synchronization registers
    logic [1:0][15:0] led_sr;
    logic [1:0][5:0] rgb_sr;
    logic [1:0][6:0] segments_sr;
    logic [1:0] dp_sr;
    logic [1:0][7:0] digits_sr;
    
    //GPIOs and display signals
    
    logic [31:0] gpio_sampling_cnt = 32'h0;
    logic [31:0] display_sampling_cnt = 32'h0;
    

    //SPI synchronization registers
    logic [2:0] ss_sr;
    logic [2:0] sclk_sr;
    logic [1:0] mosi_sr;
    
    //SPI signals
    wire sclk_rising_edge = (sclk_sr[2:1] == 2'b01);
    wire sclk_falling_edge = (sclk_sr[2:1] == 2'b10);
    logic [2:0] spi_received_bit_cnt;
    logic [7:0] spi_rx_data_reg =8'b0;
    logic [7:0] spi_tx_data_reg = 8'h00;;
    logic [7:0] spi_data_to_send = 8'h0;
    logic spi_data_ready = 1'b0;
    
    //FSM signals
    typedef enum logic[1:0] {inst_s = 2'b0, addr_s = 2'b01, data_s = 2'b10} state_t;
    logic fsm_read = 1'b0;
    logic fsm_clear = 1'b0;
    logic [7:0] fsm_address = 8'h0;
    logic [7:0] fsm_data_to_write = 8'h0;
    state_t fsm_state = inst_s;
    state_t fsm_next_state = inst_s;
    logic fsm_timeout_cnt;
    
    //
    assign spi.miso = spi_tx_data_reg[7];
    
    //Muxes for switches and buttons
    for (genvar i = 0; i < 16; i = i + 1)
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
        led_sr <= {led_sr[0], gpio_dut.led};        
        rgb_sr <= {rgb_sr[0], rgb};        
        segments_sr <= {segments_sr[0], gpio_dut.segments};
        dp_sr <= {dp_sr[0], gpio_dut.dp};
        digits_sr <= {digits_sr[0], gpio_dut.digits};
    end : gpio_synch_chain
    
    //Sampling of LED
    always_ff@(posedge gpio_top.clk)
    begin : gpio_sampling
        if (gpio_sampling_rst) begin
            gpio_sampling_cnt <= 32'h0;
        end else begin
            if (gpio_sampling_cnt == gpio_sampling_cnt_ovf - 1) begin
                gpio_sampling_cnt <= 32'h0;
                led_data <= led_sr[1];
                rgb_data <= rgb_sr[1];
            end else begin
                gpio_sampling_cnt <= gpio_sampling_cnt + 1;
            end
        end
    end : gpio_sampling
    
    //Sampling of 7seg display
    always_ff@(posedge gpio_top.clk)
    begin : display_sampling
        if (display_sampling_rst) begin
            display_sampling_cnt <= 32'h0;
        end else begin 
            if (display_sampling_cnt == display_sampling_cnt_ovf - 1) begin
                display_sampling_cnt <= 32'h0;
                segments_data <= segments_sr[1];
                dp_data <= dp_sr[1];
                digits_data <= digits_sr[1];
            end else begin
                display_sampling_cnt <= display_sampling_cnt + 1;
            end
        end
    end : display_sampling
    
    //7seg display demux
    always_ff@(posedge gpio_top.clk)
    begin : display_demux
        integer i;
        for(i = 0; i < 8; i = i + 1)
        begin
            if (!digits_data[i]) begin
                sev_seg_disp_data[i] <= {dp_data, segments_data};
            end
        end
    end : display_demux
            
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
            spi_received_bit_cnt <= 3'b0;
            spi_tx_data_reg <= 8'h0;
        end else begin
            if (sclk_falling_edge) begin
                if (spi_received_bit_cnt == 3'h0) begin
                    spi_tx_data_reg <= spi_data_to_send;
                end else begin
                    spi_tx_data_reg = {spi_tx_data_reg[6:0], 1'b0};
                end
            end
            if (sclk_rising_edge) begin
                spi_received_bit_cnt <= spi_received_bit_cnt + 1;
                spi_rx_data_reg <= {spi_rx_data_reg[6:0], mosi_sr[1]};
            end
        end
    end : spi_send_receive
    
    always_ff@(posedge gpio_top.clk)
    begin : spi_data_received
        if ((spi_received_bit_cnt == 3'h7) && sclk_rising_edge)
            spi_data_ready <= 1'b1;
        else
            spi_data_ready <= 1'b0;     
    end : spi_data_received
    
    always_ff@(posedge gpio_top.clk)
    begin : state_update
        if (spi_data_ready) begin
            case(fsm_state)
                inst_s: begin
                            spi_data_to_send <= 8'h0;
                            case(spi_rx_data_reg)
                                CLEAR: begin
                                            fsm_clear <= 1'b1;
                                            fsm_state <= addr_s;
                                        end
                                WRITE: begin
                                            fsm_state <= addr_s;
                                        end
                                READ: begin
                                            fsm_read <= 1'b1;
                                            fsm_state <= addr_s;
                                        end
                                default: fsm_state <= inst_s;
                            endcase
                        end
                addr_s: begin
                            if (fsm_clear) begin
                                memory_clear(spi_rx_data_reg);
                                fsm_state <= inst_s;
                                fsm_clear <= 1'b0;
                            end else if (fsm_read) begin
                                memory_read(spi_rx_data_reg);
                                fsm_read <= 1'b0;
                                fsm_state <= inst_s;
                            end else begin
                                fsm_address <= spi_rx_data_reg;
                                fsm_state <= data_s;
                            end
                        end
                data_s: begin
                            memory_write(fsm_address);
                            fsm_state <= inst_s;                         
                        end
                default: fsm_state <= inst_s;
            endcase
        end
    end : state_update
    
    task memory_clear;
    input [7:0] address;
    begin
        if (address < rw_mem_end_addr) begin
            case(address)
                8'h0: begin
                            sw_data <= sw_data_init_value;
                            sw_select <= sw_select_init_value;
                            btn_data <= btn_data_init_value;
                            btn_select <= btn_select_init_value;
                            control_register <= control_register_init_value;
                            gpio_sampling_cnt_ovf <= default_gpio_cycles_to_sample;
                            display_sampling_cnt_ovf <= default_display_cycles_to_sample;
                        end
                sw_data_low_addr                : sw_data[7:0] <= sw_data_init_value[7:0];
                sw_data_high_addr               : sw_data[15:8] <= sw_data_init_value[15:8];
                sw_select_low_addr              : sw_select[7:0] <= sw_select_init_value[7:0];
                sw_select_high_addr             : sw_select[15:8] <= sw_select_init_value[15:8]; 
                btn_data_addr                   : btn_data <= btn_data_init_value;
                btn_select_addr                 : btn_select <= btn_select_init_value;
                control_register_addr           : control_register <= control_register_init_value;
                display_sampling_cnt_ovf_addr   : display_sampling_cnt_ovf <= default_display_cycles_to_sample;
                gpio_sampling_cnt_ovf_addr      : gpio_sampling_cnt_ovf <= default_gpio_cycles_to_sample;
            endcase
        end
    end
    endtask
    
    task memory_read;
    input [7:0] address;
    begin
        case(address)
            sw_data_low_addr    : spi_data_to_send <= sw_data[7:0];
            sw_data_high_addr   : spi_data_to_send <= sw_data[15:8];
            sw_select_low_addr  : spi_data_to_send <= sw_select[7:0];
            sw_select_high_addr : spi_data_to_send <= sw_select[15:8];
            btn_data_addr       : spi_data_to_send <= btn_data[4:0];
            btn_select_addr     : spi_data_to_send <= btn_select[4:0];
            rgb_data_addr       : spi_data_to_send <= rgb_data[5:0]; 
            led_data_low_addr   : spi_data_to_send <= led_data[7:0];
            led_data_high_addr  : spi_data_to_send <= led_data[15:8];
            digit_0_data_addr   : spi_data_to_send <= sev_seg_disp_data[0];
            digit_1_data_addr   : spi_data_to_send <= sev_seg_disp_data[1];
            digit_2_data_addr   : spi_data_to_send <= sev_seg_disp_data[2];
            digit_3_data_addr   : spi_data_to_send <= sev_seg_disp_data[3];
            digit_4_data_addr   : spi_data_to_send <= sev_seg_disp_data[4];
            digit_5_data_addr   : spi_data_to_send <= sev_seg_disp_data[5];
            digit_6_data_addr   : spi_data_to_send <= sev_seg_disp_data[6];
            digit_7_data_addr   : spi_data_to_send <= sev_seg_disp_data[7];
            control_register_addr               : spi_data_to_send <= control_register;
            display_sampling_cnt_ovf_addr       : spi_data_to_send <= display_sampling_cnt_ovf[7:0];
            display_sampling_cnt_ovf_addr + 1   : spi_data_to_send <= display_sampling_cnt_ovf[15:8];
            display_sampling_cnt_ovf_addr + 2   : spi_data_to_send <= display_sampling_cnt_ovf[23:16];
            display_sampling_cnt_ovf_addr + 3   : spi_data_to_send <= display_sampling_cnt_ovf[31:24];
            gpio_sampling_cnt_ovf_addr          : spi_data_to_send <= gpio_sampling_cnt_ovf[7:0];
            gpio_sampling_cnt_ovf_addr + 1      : spi_data_to_send <= gpio_sampling_cnt_ovf[15:8];
            gpio_sampling_cnt_ovf_addr + 2      : spi_data_to_send <= gpio_sampling_cnt_ovf[23:16];
            gpio_sampling_cnt_ovf_addr + 3      : spi_data_to_send <= gpio_sampling_cnt_ovf[31:24];
            default                             : spi_data_to_send <= 8'h0;
        endcase
    end
    endtask
    
    task memory_write;
    input [7:0] address;
    begin
        if (address < rw_mem_end_addr) begin
            case(address)
                sw_data_low_addr    : sw_data[7:0]     <= spi_rx_data_reg;
                sw_data_high_addr   : sw_data[15:8]    <= spi_rx_data_reg;
                sw_select_low_addr  : sw_select[7:0]   <= spi_rx_data_reg;
                sw_select_high_addr : sw_select[15:8]  <= spi_rx_data_reg;
                btn_data_addr       : btn_data[4:0]    <= spi_rx_data_reg;
                btn_select_addr     : btn_select[4:0]  <= spi_rx_data_reg;
                control_register_addr : control_register <= spi_rx_data_reg;
                display_sampling_cnt_ovf_addr       : display_sampling_cnt_ovf[7:0]     <= spi_rx_data_reg;
                display_sampling_cnt_ovf_addr + 1   : display_sampling_cnt_ovf[15:8]    <= spi_rx_data_reg;
                display_sampling_cnt_ovf_addr + 2   : display_sampling_cnt_ovf[23:16]   <= spi_rx_data_reg;
                display_sampling_cnt_ovf_addr + 3   : display_sampling_cnt_ovf[31:24]   <= spi_rx_data_reg;
                gpio_sampling_cnt_ovf_addr          : gpio_sampling_cnt_ovf[7:0]        <= spi_rx_data_reg;
                gpio_sampling_cnt_ovf_addr + 1      : gpio_sampling_cnt_ovf[15:8]       <= spi_rx_data_reg;
                gpio_sampling_cnt_ovf_addr + 2      : gpio_sampling_cnt_ovf[23:16]      <= spi_rx_data_reg;
                gpio_sampling_cnt_ovf_addr + 3      : gpio_sampling_cnt_ovf[31:24]      <= spi_rx_data_reg;
            endcase
        end
    end
    endtask                 
endmodule
