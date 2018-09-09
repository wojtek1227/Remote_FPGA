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
    
    //LED and display synchronization registers
    reg [1:0][15:0] led_sr;
    reg [1:0][5:0] rgb_sr;
    reg [1:0][6:0] segments_sr;
    reg [1:0] dp_sr;
    reg [1:0][7:0] digits_sr;
    
    //GPIOs and display signals
    parameter gpio_cycles_to_sample = main_clk_freq / gpio_sampling_rate;
    logic [31:0] gpio_sampling_cnt = 32'h0;
    parameter display_cycles_to_sample = main_clk_freq / display_sampling_rate;
    logic [31:0] display_sampling_cnt = 32'h0;
    

    //SPI synchronization registers
    logic [2:0] ss_sr;
    logic [2:0] sclk_sr;
    logic [1:0] mosi_sr;
    
    //SPI signals
    wire sclk_rising_edge = (sclk_sr[2:1] == 2'b01);
    wire sclk_falling_edge = (sclk_sr[2:1] == 2'b10);
    logic [2:0] received_bit_cnt;
    logic [2:0] send_bit_cnt;
    logic [7:0] rx_data_reg =8'b0;
    logic [7:0] tx_data_reg = 8'haa;;
    logic [7:0] data_to_send = 8'h0;
    logic data_ready = 1'b0;
    
    //FSM signals
    typedef enum logic[1:0] {inst_s = 2'b0, addr_s = 2'b01, data_s = 2'b10} state_t;
    logic fsm_read = 1'b0;
    logic fsm_clear = 1'b0;
    logic [7:0] fsm_address = 8'h0;
    logic [7:0] fsm_data_to_write = 8'h0;
    state_t fsm_state = inst_s;
    state_t fsm_next_state = inst_s;
    logic fsm_timeout_cnt;
    parameter fsm_cycles_to_timeout = main_clk_freq/fsm_timeout;
    
    //
    assign spi.miso = tx_data_reg[7];
    
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
        led_sr <= {led_sr[0], gpio_dut.led};        
        rgb_sr <= {rgb_sr[0], rgb};        
        segments_sr <= {segments_sr[0], gpio_dut.segments};
        dp_sr <= {dp_sr[0], gpio_dut.dp};
        digits_sr <= {digits_sr[0], gpio_dut.digits};
    end : gpio_synch_chain
    
    //Sampling of LED
    always_ff@(posedge gpio_top.clk)
    begin : gpio_sampling
        if (gpio_sampling_cnt == gpio_cycles_to_sample - 1) begin
            gpio_sampling_cnt <= 32'h0;
            led_data <= led_sr[1];
            rgb_data <= rgb_sr[1];
        end else begin
            gpio_sampling_cnt <= gpio_sampling_cnt + 1;
        end
    end : gpio_sampling
    
    //Sampling of 7seg display
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
            received_bit_cnt <= 3'b0;
            send_bit_cnt <= 3'b0;
        end else begin
            if (sclk_falling_edge) begin
                if (send_bit_cnt == 3'h7) begin
                    tx_data_reg <= data_to_send;
                    send_bit_cnt <= 8'b0;
                end else begin
                    send_bit_cnt <= send_bit_cnt + 1;
                    tx_data_reg = {tx_data_reg[6:0], 1'b0};
                end
            end
            if (sclk_rising_edge) begin
                received_bit_cnt <= received_bit_cnt + 1;
                rx_data_reg <= {rx_data_reg[6:0], spi.mosi};
            end
        end
    end : spi_send_receive
    
    always_ff@(posedge gpio_top.clk)
    begin : spi_data_ready
        if ((received_bit_cnt == 3'h7) && sclk_rising_edge)
            data_ready <= 1'b1;
        else
            data_ready <= 1'b0;     
    end : spi_data_ready
    
    always_ff@(posedge gpio_top.clk)
    begin : state_update
        if (data_ready) begin
            case(fsm_state)
                inst_s: begin
                            data_to_send <= 8'h0;
                            case(rx_data_reg)
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
                            if (rx_data_reg < mem_addr_end) begin
                                if (fsm_clear) begin
                                    assert (fsm_clear) $display ("OK. Clear performed");
                                    memory_clear(rx_data_reg);
                                    fsm_state <= inst_s;
                                    fsm_clear <= 1'b0;
                                end else if (fsm_read) begin
                                    assert (fsm_read) $display ("OK. Read performed");
                                    memory_read(rx_data_reg);
                                    fsm_read <= 1'b0;
                                    fsm_state <= inst_s;
                                end else begin
                                    fsm_address <= rx_data_reg;
                                    fsm_state <= data_s;
                                end
                            end else begin
                                fsm_state <= inst_s;
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
        case(address)
            8'h0: begin
                        sw_data <= 16'h0;
                        sw_select <= 16'h0;
                        btn_data <= 5'h0;
                        btn_select <= 5'h0;
                    end
            8'h1: sw_data[7:0] <= 8'h0;
            8'h2: sw_data[15:8] <= 8'h0;
            8'h3: sw_select[7:0] <= 8'h0;
            8'h4: sw_select[15:8] <= 8'h0; 
            8'h5: btn_data <= 5'h0;
            8'h6: btn_select <= 5'h0;
        endcase
    end
    endtask
    
    task memory_read;
    input [7:0] address;
    begin
        case(address)
            8'h1: data_to_send <= sw_data[7:0];
            8'h2: data_to_send <= sw_data[15:8];
            8'h3: data_to_send <= sw_select[7:0];
            8'h4: data_to_send <= sw_select[15:8];
            8'h5: data_to_send <= btn_data[4:0];
            8'h6: data_to_send <= btn_select[4:0];
            8'h7: data_to_send <= led_data[7:0];
            8'h8: data_to_send <= led_data[15:8];
            8'h9: data_to_send <= sev_seg_disp_data[0];
            8'ha: data_to_send <= sev_seg_disp_data[1];
            8'hb: data_to_send <= sev_seg_disp_data[2];
            8'hc: data_to_send <= sev_seg_disp_data[3];
            8'hd: data_to_send <= sev_seg_disp_data[4];
            8'he: data_to_send <= sev_seg_disp_data[5];
            8'hf: data_to_send <= sev_seg_disp_data[6];
            8'h10: data_to_send <= sev_seg_disp_data[7];
        endcase
    end
    endtask
    
    task memory_write;
    input [7:0] address;
    begin
        case(address)
            8'h1: sw_data[7:0]     <= rx_data_reg;
            8'h2: sw_data[15:8]    <= rx_data_reg;
            8'h3: sw_select[7:0]   <= rx_data_reg;
            8'h4: sw_select[15:8]  <= rx_data_reg;
            8'h5: btn_data[4:0]    <= rx_data_reg;
            8'h6: btn_select[4:0]  <= rx_data_reg;
        endcase
    end
    endtask                 
endmodule
