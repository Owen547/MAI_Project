# $VTR_ROOT/vtr_flow/scripts/run_vtr_flow.py \
# ~/College/MAI_Project/VTR/target_designs/cominational/8_bit_adder.v \
# ~/College/MAI_Project/VTR/Architectures/mesh_arch.xml \
# --route_chan_width 100 

#combinational 8 bit adder
$VTR_ROOT/vtr_flow/scripts/run_vtr_flow.py \
~/College/MAI_Project/VTR/target_designs/combinational/8_bit_adder/top.v \
~/College/MAI_Project/VTR/Architectures/mesh_arch.xml \
-include ~/College/MAI_Project/VTR/target_designs/combinational/8_bit_adder/full_adder.v \
-temp_dir ~/College/VTR_runs/arch_runs/test_run \
-top_module top \
-lut_size 6 \
--route_chan_width 10 \
--disp on

# sequential FSM
$VTR_ROOT/vtr_flow/scripts/run_vtr_flow.py \
~/College/MAI_Project/VTR/target_designs/sequential/FSM/top.v \
~/College/MAI_Project/VTR/Architectures/mesh_arch.xml \
-temp_dir ~/College/VTR_runs/arch_runs/chan_width \
-top_module top \
-lut_size 6 \
--route_chan_width 20 \
--disp on

#run the test mesh description
$VTR_ROOT/vtr_flow/scripts/run_vtr_flow.py \
~/College/MAI_Project/VTR/target_designs/combinational/8_bit_adder/top.v \
~/College/MAI_Project/VTR/Architectures/mesh_arch_test.xml \
-include ~/College/MAI_Project/VTR/target_designs/combinational/8_bit_adder/full_adder.v \
-temp_dir ~/College/VTR_runs/arch_runs/test_run \
-top_module top \
-lut_size 6 \
--route_chan_width 100 \
--disp on