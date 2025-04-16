#!/bin/bash

# Define an array of values.
values=("1 1" "2 2" "3 3" "5 3" "4 5" "5 5" "5 6" "6 6" "7 6" "7 7" "8 7" "9 6" "9 7" "8 8" "7 10" "11 7" "9 9" "8 11" "9 10" "10 10") #given as "MESH_SIZE_X MESH_SIZE_Y"
# values=("1 1") #given as "MESH_SIZE_X MESH_SIZE_Y"
# Loop until the list of values is empty.
while [ ${#values[@]} -gt 0 ]; do
# Take the first value from the array.
value="${values[0]}"

echo -n "Starting run for $value...                 "

# Call the Python script, passing the value as an argument.
python3 /home/owen/College/MAI_Project/Simulations/setup_VTR.py "$value"

#run VTR
echo -n "Starting sequential run...                 "
$VTR_ROOT/vtr_flow/scripts/run_vtr_flow.py \
/home/owen/College/MAI_Project/VTR/target_designs/sequential/8_bit_adder_seq/top.v \
~/College/MAI_Project/VTR/Architectures/mesh_arch.xml \
-include /home/owen/College/MAI_Project/VTR/target_designs/sequential/8_bit_adder_seq/full_adder.v \
-temp_dir ~/College/VTR_runs/sequential_run \
-top_module top \
-lut_size 6 \
--route_chan_width 10

#run bit gen
python3 /home/owen/College/MAI_Project/VTR/Bit_gen/bit_gen.py -seq

# call the script to setup the verilog for the simualtion
python3 /home/owen/College/MAI_Project/Simulations/setup_Vivado.py "$value"

# Make sure its in the Vivado directory
cd /home/owen/College/Vivado/sim_runs/clock_runs

#Run Vivado with the tcl script
vivado -mode tcl -source /home/owen/College/MAI_Project/Simulations/run.tcl

#call pyhton to scrape whatever other data ya want from the files
python3 /home/owen/College/MAI_Project/Simulations/post_Vivado.py "$value"

#go home man
cd /home/owen/College/MAI_Project/Simulations

echo ""

# Remove the first element from the array.
values=("${values[@]:1}")

done