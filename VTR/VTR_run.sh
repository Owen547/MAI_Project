$VTR_ROOT/vtr_flow/scripts/run_vtr_flow.py \
~/College/MAI_Project/VTR/target_designs/cominational/8_bit_adder.v \
~/College/MAI_Project/VTR/Architectures/mesh_arch.xml \
--route_chan_width 100 

$VTR_ROOT/vtr_flow/scripts/run_vtr_flow.py \
~/College/MAI_Project/VTR/target_designs/combinational/8_bit_adder/top.v \
~/College/MAI_Project/VTR/Architectures/mesh_arch.xml \
-include ~/College/MAI_Project/VTR/target_designs/combinational/8_bit_adder/full_adder.v \
--route_chan_width 100 \
--disp on