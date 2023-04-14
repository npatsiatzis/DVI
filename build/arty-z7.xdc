## Constraints file.
## Clock signal 125 MHz
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { i_clk }]; 
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { i_clk }];

##Buttons
set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS33 } [get_ports { i_rst }]; 

##Tx
set_property -dict { PACKAGE_PIN L17   IOSTANDARD TMDS_33  } [get_ports { o_clk_n }];
set_property -dict { PACKAGE_PIN L16   IOSTANDARD TMDS_33  } [get_ports { o_clk_p }]; 
set_property -dict { PACKAGE_PIN K18   IOSTANDARD TMDS_33  } [get_ports { o_data_n[0] }]; 
set_property -dict { PACKAGE_PIN K17   IOSTANDARD TMDS_33  } [get_ports { o_data_p[0] }]; 
set_property -dict { PACKAGE_PIN J19   IOSTANDARD TMDS_33  } [get_ports { o_data_n[1] }]; 
set_property -dict { PACKAGE_PIN K19   IOSTANDARD TMDS_33  } [get_ports { o_data_p[1] }]; 
set_property -dict { PACKAGE_PIN H18   IOSTANDARD TMDS_33  } [get_ports { o_data_n[2] }]; 
set_property -dict { PACKAGE_PIN J18   IOSTANDARD TMDS_33  } [get_ports { o_data_p[2] }]; 