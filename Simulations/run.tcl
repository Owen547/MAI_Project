open_project ./project.xpr

reset_run *

launch_runs impl_1

wait_on_run impl_1

open_run impl_1

report_utilization -file /home/owen/College/MAI_Project/Vivado/seq_sim_runs/8_bit_adder/run_util.txt

report_timing -file /home/owen/College/MAI_Project/Vivado/seq_sim_runs/8_bit_adder/run_timing.txt

report_power -file /home/owen/College/MAI_Project/Vivado/seq_sim_runs/8_bit_adder/run_power.txt

# launch_simulation -mode post-implementation -type timing

exit

#write the resource utilization and timing summary (to be scraped after woth python) and some power summary or something


#run the simulation