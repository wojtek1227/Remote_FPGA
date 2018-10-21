<?xml version='1.0' encoding='UTF-8'?>
<Project Type="Project" LVVersion="18008000">
	<Item Name="My Computer" Type="My Computer">
		<Property Name="server.app.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.control.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.tcp.enabled" Type="Bool">false</Property>
		<Property Name="server.tcp.port" Type="Int">0</Property>
		<Property Name="server.tcp.serviceName" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.tcp.serviceName.default" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.vi.callsEnabled" Type="Bool">true</Property>
		<Property Name="server.vi.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="specify.custom.address" Type="Bool">false</Property>
		<Item Name="spi" Type="Folder">
			<Item Name="create_packet.vi" Type="VI" URL="../create_packet.vi"/>
			<Item Name="spi_clear.vi" Type="VI" URL="../spi_clear.vi"/>
			<Item Name="spi_write.vi" Type="VI" URL="../spi_write.vi"/>
		</Item>
		<Item Name="TypeDefs" Type="Folder">
			<Item Name="conn_proto" Type="Folder">
				<Item Name="packet_t.ctl" Type="VI" URL="../packet_t.ctl"/>
				<Item Name="packet_type_t.ctl" Type="VI" URL="../packet_type_t.ctl"/>
			</Item>
			<Item Name="gui" Type="Folder">
				<Item Name="seven_seg_digit.ctl" Type="VI" URL="../seven_seg_digit.ctl"/>
				<Item Name="Seven_seg_disp.xctl" Type="XControl" URL="../Seven_seg_disp.xctl"/>
			</Item>
			<Item Name="spi" Type="Folder">
				<Item Name="grabber_register_addr.ctl" Type="VI" URL="../grabber_register_addr.ctl"/>
				<Item Name="spi_instructions.ctl" Type="VI" URL="../spi_instructions.ctl"/>
			</Item>
		</Item>
		<Item Name="backup.vi" Type="VI" URL="../backup.vi"/>
		<Item Name="backup2.vi" Type="VI" URL="../backup2.vi"/>
		<Item Name="cluster_to_byte_data.vi" Type="VI" URL="../cluster_to_byte_data.vi"/>
		<Item Name="main.vi" Type="VI" URL="../main.vi"/>
		<Item Name="remote_fpga.vi" Type="VI" URL="../remote_fpga.vi"/>
		<Item Name="u8_to_sev_seg.vi" Type="VI" URL="../u8_to_sev_seg.vi"/>
		<Item Name="Untitled 1.vi" Type="VI" URL="../Untitled 1.vi"/>
		<Item Name="Dependencies" Type="Dependencies">
			<Item Name="vi.lib" Type="Folder">
				<Item Name="Version To Dotted String.vi" Type="VI" URL="/&lt;vilib&gt;/_xctls/Version To Dotted String.vi"/>
				<Item Name="VISA Configure Serial Port" Type="VI" URL="/&lt;vilib&gt;/Instr/_visa.llb/VISA Configure Serial Port"/>
				<Item Name="VISA Configure Serial Port (Instr).vi" Type="VI" URL="/&lt;vilib&gt;/Instr/_visa.llb/VISA Configure Serial Port (Instr).vi"/>
				<Item Name="VISA Configure Serial Port (Serial Instr).vi" Type="VI" URL="/&lt;vilib&gt;/Instr/_visa.llb/VISA Configure Serial Port (Serial Instr).vi"/>
				<Item Name="XControlSupport.lvlib" Type="Library" URL="/&lt;vilib&gt;/_xctls/XControlSupport.lvlib"/>
			</Item>
		</Item>
		<Item Name="Build Specifications" Type="Build"/>
	</Item>
</Project>
