
set verilog_header "C:/Users/caput/OneDrive/Praca_Magisterska/Remote_FPGA/NEXYS4/nexys4_project/nexys4_project.srcs/sources_1/new/grabber_registers_addr.vh"
set c_header "C:/Users/caput/OneDrive/Praca_Magisterska/Remote_FPGA/ZYBO/remote_fpga/remote_fpga.sdk/remote_fpga/src/spi/grabber_registers_addr.h"

set verilog_header_fp [open $verilog_header "r"]
set c_header_fp [open $c_header w+]
set verilog_data [split [read $verilog_header_fp] "\n"]

# Data processing

foreach line $verilog_data {
	if {[lindex $line 0]=="parameter"} {
		set line_to_add {}
		lappend line_to_add #define
		set address_name [string toupper [lindex $line 1]]
		set address_value [string map {8'h 0x} [lindex $line 3]]
		lappend line_to_add $address_name
		lappend line_to_add $address_value
		set line_to_add [join $line_to_add]
		puts $c_header_fp $line_to_add
	} elseif {[lindex $line 0]=="\`ifndef"} {
		puts $c_header_fp "#ifndef _GRABBER_REGISTERS_ADDR_H_"
	} elseif {[lindex $line 0]=="\`define"} {
		puts $c_header_fp "#define _GRABBER_REGISTERS_ADDR_H_"
		puts $c_header_fp ""
	} elseif {[lindex $line 0]=="\`endif"} {
		puts $c_header_fp ""
		puts $c_header_fp "#endif /* _GRABBER_REGISTERS_ADDR_H_ */"
	} else {
		puts $c_header_fp $line
	}
}

close $verilog_header_fp
close $c_header_fp

