# Primary clock template.
# TODO: uncomment and set the clock port name / period for your top module.
# create_clock -name clk -period 10.000 [get_ports clk]

# Example: input/output delay and false path templates
# set_input_delay  -clock clk 2.000 [get_ports {din[*]}]
# set_output_delay -clock clk 2.000 [get_ports {dout[*]}]
# set_false_path -from [get_ports rst]
