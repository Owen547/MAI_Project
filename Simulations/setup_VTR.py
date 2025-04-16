import sys

def main():#edit the mesh_arch_xml with mesh x and y

    # Remove the surrounding quotes using strip, and then split by whitespace
    numbers = sys.argv[1].strip('"').split()

    # Assign to two variables
    MESH_SIZE_X, MESH_SIZE_Y = numbers

    new_line = f"    <fixed_layout name=\"mesh\" width=\"{str(int(MESH_SIZE_X)+2)}\" height=\"{str(int(MESH_SIZE_Y)+2)}\">\n"

    output_lines = []
    
    with open("/home/owen/College/MAI_Project/VTR/Architectures/mesh_arch.xml", 'r') as file:
        for line in file:
            # Check if the line starts with the target text.
            if '<fixed_layout name=' in line:
                output_lines.append(new_line)
            else:
                output_lines.append(line)
    
    # Write back to the file.
    with open("/home/owen/College/MAI_Project/VTR/Architectures/mesh_arch.xml", 'w') as file:
        file.writelines(output_lines)

    #edit the width parameter in the 8 bit adder verilog
    best_width = 0

    for width in range (0, 1000):

        if (((3*width) + 2) < ((2*int(MESH_SIZE_X)) + (2*int(MESH_SIZE_Y)) * 3)):  
            best_width = width
        else:
            break

    new_line = f"    parameter WIDTH = {best_width}\n"

    output_lines = []
    
    with open("/home/owen/College/MAI_Project/VTR/target_designs/sequential/8_bit_adder_seq/top.v", 'r') as file:
        for line in file:
            # Check if the line starts with the target text.
            if 'parameter WIDTH =' in line:
                output_lines.append(new_line)
            else:
                output_lines.append(line)
    
    # Write back to the file.
    with open("/home/owen/College/MAI_Project/VTR/target_designs/sequential/8_bit_adder_seq/top.v", 'w') as file:
        file.writelines(output_lines)

if __name__ == '__main__':
    
    main ()
    
