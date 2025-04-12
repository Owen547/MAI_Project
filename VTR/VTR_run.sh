# $VTR_ROOT/vtr_flow/scripts/run_vtr_flow.py \
# ~/College/MAI_Project/VTR/target_designs/cominational/8_bit_adder.v \
# ~/College/MAI_Project/VTR/Architectures/mesh_arch.xml \
# --route_chan_width 100 

#combinational 8 bit adder
echo -n "Starting combinational run...              "
$VTR_ROOT/vtr_flow/scripts/run_vtr_flow.py \
~/College/MAI_Project/VTR/target_designs/combinational/8_bit_adder/top.v \
~/College/MAI_Project/VTR/Architectures/mesh_arch.xml \
-include ~/College/MAI_Project/VTR/target_designs/combinational/8_bit_adder/full_adder.v \
-temp_dir ~/College/VTR_runs/combinational_run \
-top_module top \
-lut_size 6 \
--route_chan_width 10 \
# --disp on

# sequential FSM
echo -n "Starting sequential run...                 "
$VTR_ROOT/vtr_flow/scripts/run_vtr_flow.py \
~/College/MAI_Project/VTR/target_designs/sequential/8_bit_adder_seq/top.v \
~/College/MAI_Project/VTR/Architectures/mesh_arch.xml \
-include ~/College/MAI_Project/VTR/target_designs/sequential/8_bit_adder_seq/full_adder.v \
-temp_dir ~/College/VTR_runs/sequential_run \
-top_module top \
-lut_size 6 \
--route_chan_width 10 \
--disp on


#run the test arch description on combinational
echo -n "Starting combinational test run...         "
$VTR_ROOT/vtr_flow/scripts/run_vtr_flow.py \
~/College/MAI_Project/VTR/target_designs/combinational/8_bit_adder/top.v \
~/College/MAI_Project/VTR/Architectures/mesh_arch_test.xml \
-include ~/College/MAI_Project/VTR/target_designs/combinational/8_bit_adder/full_adder.v \
-temp_dir ~/College/VTR_runs/combinational_test_run \
-top_module top \
-lut_size 6 \
--route_chan_width 10 \
# --disp on

#run the test arch description on sequential 8 bit adder
echo -n "Starting sequential test run...            "
$VTR_ROOT/vtr_flow/scripts/run_vtr_flow.py \
~/College/MAI_Project/VTR/target_designs/sequential/8_bit_adder_seq/top.v \
~/College/MAI_Project/VTR/Architectures/mesh_arch_test.xml \
-include ~/College/MAI_Project/VTR/target_designs/sequential/8_bit_adder_seq/full_adder.v \
-temp_dir ~/College/VTR_runs/sequential_test_run \
-top_module top \
-lut_size 6 \
--route_chan_width 10 \
# --disp on

#run the example arch on a sequential design
echo -n "Starting example sequential test run...    " 
$VTR_ROOT/vtr_flow/scripts/run_vtr_flow.py \
~/College/MAI_Project/VTR/target_designs/sequential/8_bit_adder_seq/top.v \
~/College/MAI_Project/VTR/Architectures/example_arch.xml \
-include ~/College/MAI_Project/VTR/target_designs/sequential/8_bit_adder_seq/full_adder.v \
-temp_dir ~/College/VTR_runs/example_sequential_run \
-top_module top \
-lut_size 6 \
--route_chan_width 100 \
# --disp on

