import re

target_folder = "/home/owen/College/VTR_runs/arch_runs/chan_width/"

bitstream_file = "bitsream.txt"

MESH_SIZE_X = 0
MESH_SIZE_Y = 0

# read the mesh size from one of the files

def parse_place_file(file_path, logfile):
    blocks = []
    # Read the file
    with open(file_path, 'r') as file:
        # read the mesh size from one of the files
        for line in file:
            if line.startswith("Array size:"):
                match = re.match(r"Array size: (\d*) x (\d*)", line)
                MESH_SIZE_X = int(match.group(1))
                MESH_SIZE_Y = int(match.group(2))


                logfile.write("INFO: Mesh dimensions found to be: " + str(MESH_SIZE_X) + " x " + str(MESH_SIZE_Y) + "\n")

            if line.startswith('#---'):
                break
        
        # Now, start processing block data
        for line in file:
            
            # Use regex to match and extract the block information
            match = re.match(r"^(\S*)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)", line)
            if match:
                name = match.group(1)
                x = int(match.group(2))
                y = int(match.group(3))
                subblk = (int(match.group(4)), int(match.group(5)))
                
                # Store the block information as a dictionary
                blocks.append({
                    "name": name,
                    "type": "",
                    "x": x,
                    "y": y,
                    "subblk": subblk,
                    "bitstream": ""
                })

    logfile.write(f"INFO: printing placement data scraped from top.place...\n")  # Write each dictionary on a new line
    for block in blocks:
        logfile.write(f"{block}\n")  # Write each dictionary on a new line
    logfile.write(f"\n\n")  # Write each dictionary on a new line

    return blocks, MESH_SIZE_X, MESH_SIZE_Y


def extract_io_bits (blocks, MESH_SIZE_X, MESH_SIZE_Y, logfile):

    for block in blocks:

        if (block['y'] == (MESH_SIZE_Y - 1)) or (block['y'] == (0)) or (block['x'] == (MESH_SIZE_X - 1)) or (block['x'] == 0) :

            if block['name'].startswith("out"):

                block['type'] = "IO" # label block as IO
                block['bitstream'] = "01" # enable output, drive input low

            else : 

                block['type'] = "IO" # label block as IO
                block['bitstream'] = "10" #enable input, drive output low

        else: 

            block['type'] = "CLB" # label block as CLB


    logfile.write(f"INFO: printing blocks with IO bits...\n")  # Write each dictionary on a new line
    for block in blocks:
        logfile.write(f"{block}\n")  # Write each dictionary on a new line
    logfile.write(f"\n\n")  # Write each dictionary on a new line

    return blocks


def expand_inputs (lut_config, input, logfile):

    for i in range (1, (6 - (len(input)) + 1)):

        # logfile.write("DEBUG: missing values in string is " + str(6 - (len(input))) + "\n")

        input = "-" + input

    dont_cares = 0
    
    indexes = []
    index = 0

    for character in input:

        if (character == "-"):
            indexes.append(index)
            dont_cares += 1

        index += 1

    # logfile.write("DEBUG: " + str(dont_cares) + " dont cares found in string\n")

    for i in range(0, 2**dont_cares):
        # Format the number as binary with leading zeros
        binary_value = format(i, f'0{dont_cares}b')   

        # logfile.write("DEBUG: list of indexes found" + str(indexes) + "\n")
        for i in range (0, dont_cares):
            input_list = list(input)
            input_list[indexes[i]] = str(binary_value[i]) 
            input = ''.join(input_list)

        lut_config[int(input, 2)] = 1

    return lut_config
            

def extract_lut_configs (file_path, logfile) : 

    luts = []

    with open(file_path, 'r') as file:
       
        expecting_config = 0

        for line in file:

            if (expecting_config) :

                if (re.match(r"(\S+)", line)):

                    match = re.match(r"(\S+) (\d)", line)
                    input_binary = match.group(1)
                    output_binary = match.group(2)

                    # logfile.write("DEBUG: Attempting to expand " + input_binary + "\n")
                    
                    lut_config = expand_inputs(lut_config, input_binary, logfile)

                else :

                    for lut in luts: 

                        if lut["name"] == name: 

                            lut["config"] = lut_config
                            expecting_config = 0

            if line.startswith(".names"):
                
                lut_config = [0] * 64
                expecting_config = 1

                match = re.match(r".names\s+(.+) (\S+)", line)
                inputs = match.group(1)
                name = match.group(2)

                # Store the block information as a dictionary
                luts.append({
                    "name": name,
                    "inputs": inputs,
                    "config": ""
                })

        logfile.write(f"INFO: printing extracted LUT configurations ..\n")  # Write each dictionary on a new line

        for lut in luts:
            logfile.write(f"LUT name : {lut["name"]}\n")  # Write each dictionary on a new line
            logfile.write(f"Inputs : {lut["inputs"]}\n")
            # logfile.write(f"Config : {lut["config"]}\n\n")
            for i in range(0, 2**6):
                # Format the number as binary with leading zeros
                binary_value = format(i, f'06b')  
                logfile.write(f"{binary_value} {lut["config"][i]}\n")  # Write each dictionary on a new line
            logfile.write(f"\n\n")

        # logfile.write(f"\n\n")  # Write each dictionary on a new line


# Main function to run the script

def main():
    # Specify the file path to the netlist data
    
    with open ("logfile.txt", "w+") as logfile: 

        # Parse the place file
        blocks, MESH_SIZE_X, MESH_SIZE_Y = parse_place_file(target_folder + "top.place", logfile)

        blocks = sorted(blocks, key=lambda block: (-block['y'], block['x'], block['subblk'])) #order them by grid location, useful seeing as config is in shift register through design
        
        blocks = extract_io_bits(blocks, MESH_SIZE_X, MESH_SIZE_Y, logfile)

        lut_configs = extract_lut_configs(target_folder + "top.pre-vpr.blif", logfile)

        # now have luts and IO bits, still need to extract: which CLBs have which lUTS, switchbox settings and connection box settings
        # once I know which order the inputs enter the CLBs, from cx settings, I can get cx settings from lut_configs.
        


# Run the script
if __name__ == "__main__":
    main() 