create_clock -name clock -period 10 [get_ports clk]
create_clock -name config_clock -period 2 [get_ports config_clk]