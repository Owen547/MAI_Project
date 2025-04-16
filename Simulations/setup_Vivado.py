import sys

def main():

    # Remove the surrounding quotes using strip, and then split by whitespace
    numbers = sys.argv[1].strip('"').split()

    # Assign to two variables
    MESH_SIZE_X, MESH_SIZE_Y = numbers
    # MESH_SIZE_X, MESH_SIZE_Y = (3, 3)

    #edit top.v with correct mesh values

    meshx_new = f"    parameter MESH_SIZE_X = {str(MESH_SIZE_X)},  //declare number of CLB's in x axis.\n"
    meshy_new = f"    parameter MESH_SIZE_Y = {str(MESH_SIZE_Y)},  //declare number of CLB's in x axis.\n"

    output_lines = []

    with open("/home/owen/College/MAI_Project/Architecture/src/top.v", 'r') as file:

        for line in file:
            
            # Check if the line starts with the target text.
            if 'parameter MESH_SIZE_X = ' in line:
                output_lines.append(meshx_new)
            elif 'parameter MESH_SIZE_Y = ' in line: 
                output_lines.append(meshy_new)
            else:
                output_lines.append(line)

    # Write back to the file.
    with open("/home/owen/College/MAI_Project/Architecture/src/top.v", 'w') as file:

        file.writelines(output_lines)

    #edit top tb with new params

    output_lines = []

    with open("/home/owen/College/MAI_Project/Architecture/sim/DUT_UVM_tb/TOP_tb.v", 'r') as file:

        for line in file:
            
            # Check if the line starts with the target text.
            if 'parameter MESH_SIZE_X = ' in line:
                output_lines.append(meshx_new)
            elif 'parameter MESH_SIZE_Y = ' in line: 
                output_lines.append(meshy_new)
            else:
                output_lines.append(line)

    # Write back to the file.
    with open("/home/owen/College/MAI_Project/Architecture/sim/DUT_UVM_tb/TOP_tb.v", 'w') as file:

        file.writelines(output_lines)


    #edit stim gem with io verilog text

    new_lines = []

    with open("/home/owen/College/MAI_Project/VTR/Bit_gen/io_verilog.txt", 'r') as file:

        for line in file:

            new_lines.append(line)
    
    output_lines = []

    rejecting_lines = 0

    with open("/home/owen/College/MAI_Project/Architecture/sim/DUT_UVM_tb/TOP_STIM_GEN.v", 'r') as file:

        for line in file:

            if "    //////////////////////// Add assigns and signal declarations for target design here" in line:
                
                output_lines.append(line)

                for line2 in new_lines:

                    output_lines.append(line2)

                    output_lines.append("\n")

                rejecting_lines = 1

            elif "    //////////////////////// Instantiate target design to capture expected outputs" in line:

                output_lines.append(line)

                rejecting_lines = 0
            
            else:

                if not rejecting_lines:

                    output_lines.append(line)


    
    # Write back to the file.
    with open("/home/owen/College/MAI_Project/Architecture/sim/DUT_UVM_tb/TOP_STIM_GEN.v", 'w') as file:

        file.writelines(output_lines)

if __name__ == '__main__':
    
    main ()
    
