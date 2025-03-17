import re

target_folder = "/home/owen/College/VTR_runs/arch_runs/test_run/"

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
                    "subblk": subblk
                })

            else:  logfile.write("ERROR: Regex failed to match in top.place\n")

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
            block['inputs'] = [""] * 12
            block['luts'] = [""] * 3


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


def extract_connector_configs(file_path, MESH_SIZE_X, MESH_SIZE_Y, connectors, blocks, logfile) :

    # initialise a list to swap from VTR trscks to CX input/outputs

    chanx_track_to_input = [0, 8, 1, 9, 2, 10, 3, 11, 4, 12] # Connector box: equivalence between VTR tracks and verilog design inputs
    cx_pin_to_output = [8, 9, 10, 13, 14, 15, 0, 1, 2, 5, 6, 7] # takes a clb input pin, and gives the output index its equivalent to in the verilog
    chany_track_to_input = [3, 11, 4, 12, 5, 13, 6, 14, 7, 15]

    #add CLB inputs in their order to the blocks data structure, I can later consolidate the lut_configs and CLB block descriptions to get CLB cx configs

    with open(file_path, 'r') as file :

        last_line = ''

        expecting_routing = 0

        for line in file :

            if line.startswith("Routing") :

                expecting_routing = 1
            
            elif (expecting_routing) :

                if (line.startswith("Net")) :
                    
                    match = re.match(r"Net \d+ \((.*)\)", line)

                    name = match.group(1)

                    # logfile.write("DEBUG: Entering routing for net " + name + "\n")

                else:

                    if "IPIN" in line : #cx outputs, to clb or io

                        match = re.match(r"Node:\s+\d+\s+(\S+)\s+\((\d+),(\d+),\S+\)\s+Track: (\d+)", last_line)

                        chan = match.group(1)
                        cx_x = int(match.group(2))
                        cx_y = int(match.group(3))
                        track = int(match.group(4))

                        # logfile.write("DEBUG: IPIN found in current line. Expecting cx output. CX chan, cx_x, cx_y, track: " + chan  + ", " + cx_x + ", " + cx_y + ", " + track + "\n")

                        match = re.match(r"Node:\s+\d+\s+\S+\s+\((\d+),(\d+),\S+\)\s+(\S+): (\d+)", line)

                        x = int(match.group(1))
                        y = int(match.group(2))
                        pin_number = int(match.group(4))

                        if (match.group(3) == "Pin") :

                            for block in blocks:

                                if (block["x"] == x) and (block["y"] == y) :

                                        block['inputs'][pin_number] = name

                                        break

                            for connector in connectors:

                                if (connector["x"] == cx_x) and (connector["y"] == cx_y and connector["chan"] == chan):

                                    output_index = 4 * (cx_pin_to_output[pin_number])

                                    if (chan == "CHANX") :
                                        
                                        input_select = format((chanx_track_to_input[track]), f'04b')

                                        connector["config"][output_index-1:output_index-4] = input_select
                                                        
                                    else : # ie its a CHANY cx

                                        input_select = format((chany_track_to_input[track]), f'04b')

                                        connector["config"][output_index-1:output_index-4] = input_select  

                                    break 
                        
                        elif (match.group(3) == "Pad") :
                            
                            for block in blocks:

                                if (block["name"] == "out:" + name) and (block["x"] == x) and (block["y"] == y) :

                                    output_index = block["subblk"][0] * 4 #offset the index to the left outputs

                                    break

                            if (int(cx_x) == 0):
                                
                                input_sel = format((chany_track_to_input[track]), f'04b') 
                                
                                connector["config"][output_index - 1 : output_index - 4] = input_sel  

                            elif (int(cx_x) == MESH_SIZE_X - 2):

                                output_index = output_index + (8 * 4) #offset the index to the right outputs
                                
                                input_sel = format((chany_track_to_input[track]), f'04b') 
                                
                                connector["config"][output_index - 1 : output_index - 4] = input_sel  

                            elif (int(cx_y) == MESH_SIZE_Y - 2):

                                output_index = output_index + (5 * 4) #offset the index to the top outputs
                                
                                input_sel = format((chanx_track_to_input[track]), f'04b') 
                                
                                connector["config"][output_index - 1 : output_index - 4] = input_sel  

                            elif (int(cx_y) == 0):

                                output_index = output_index + (13 * 4) #offset the index to the bottom outputs
                                
                                input_sel = format((chanx_track_to_input[track]), f'04b') 
                                
                                connector["config"][output_index - 1 : output_index - 4] = input_sel 

                            else :
                            
                                logfile.write("ERROR: expected IO/edge location of connector, coordinates did not support this :(\n")

                        else :

                            logfile.write("ERROR: expected pin or pad, found neither\n")


                    elif "OPIN" in last_line : #CX Inputs.. from io or clb

                        match = re.match(r"Node:\s+\d+\s+(\S+)\s+\((\d+),(\d+),\S+\)\s+Track: (\d+)", line)

                        chan = match.group(1)
                        cx_x = int(match.group(2))
                        cx_y = int(match.group(3))
                        track = int(match.group(4))

                        # logfile.write("DEBUG: OPIN found in current line. Expecting cx output. CX chan, cx_x, cx_y, track: " + chan  + ", " + cx_x + ", " + cx_y + ", " + track + "\n")

                        # logfile.write("DEBUG: line: " + line + "\nlast_line: " + last_line)

                        match = re.match(r"Node:\s+\d+\s+\S+\s+\((\d+),(\d+),\S+\)\s+(\S+): (\d+)", last_line)

                        x = int(match.group(1))
                        y = int(match.group(2))
                        pin_number = int(match.group(4))  

                        if (match.group(3) == "Pin") :

                            for block in blocks:

                                if (block["x"] == x) and (block["y"] == y) :

                                        block['luts'][pin_number - 12] = name 

                                        break                           

                            input_offset = pin_number - 12 

                            for connector in connectors:

                                if (connector["x"] == cx_x) and (connector["y"] == cx_y and connector["chan"] == chan):

                                    if (chan == "CHANX") :
                                        
                                        if (cx_y < y) :

                                            input_sel = format((5 + input_offset), f'04b')

                                        else :

                                            input_sel = format((13 + input_offset), f'04b')

                                        output_index = chanx_track_to_input[track]

                                        connector["config"][output_index-1:output_index-4] = input_sel
                                    
                                                        
                                    else : # i.e. its a CHANY cx

                                        if (cx_x < x) :

                                            input_sel = format((0 + input_offset), f'04b')

                                        else :

                                            input_sel = format((8 + input_offset), f'04b')  

                                        output_index = chany_track_to_input[track]

                                        connector["config"][output_index-1:output_index-4] = input_sel

                                    break
                        

                        elif (match.group(3) == "Pad") :

                            block_found = 0

                            for block in blocks:

                                if (block["x"] == int(x)) and (block["y"] == int(y) and (block["name"] == name)) :

                                        input_offset = block["subblk"][0]

                                        block_found = 1 

                                        break

                            if not block_found:

                                logfile.write("ERROR: Didn't find the block\nname, x, y, pin number, pin/pad: " + name + ", " + x + ", " + y + ", " + pin_number + ", " + match.group(3) + "\n")

                            for connector in connectors:

                                if (connector["x"] == cx_x) and (connector["y"] == cx_y and connector["chan"] == chan):

                                    if (int(cx_x) == 0) or (int(cx_x) == MESH_SIZE_X - 2) :

                                        if (int(x) < int(cx_x)) : 
                                            
                                            input_sel = format((0 + input_offset), f'04b')

                                        else :

                                            input_sel = format((8 + input_offset), f'04b')  

                                        output_index = chany_track_to_input[track]

                                        connector["config"][output_index-1:output_index-4] = input_sel

                                    elif (int(cx_x) > 0) and (int(cx_x) < (MESH_SIZE_X - 2)) :

                                        if (int(x) < int(cx_y)) : 

                                            input_sel = format((5 + input_offset), f'04b')

                                        else :

                                            input_sel = format((13 + input_offset), f'04b')

                                        output_index = chanx_track_to_input[track]

                                        connector["config"][output_index-1:output_index-4] = input_sel

                                    else:

                                        logfile.write("ERROR: couldn't find anything within the coordinates specified for cx input config extraction\n")
                                        
                                    break
                        else :

                            logfile.write("ERROR: expected pin or pad, found neither\n")

            last_line = line

    return connectors, blocks

# def extract_switch_configs(file_path, logfile):

#     return


# Main function to run the script

def main():
    # Specify the file path to the netlist data

    with open ("logfile.txt", "w+") as logfile: 


        # Parse the place file
        blocks, MESH_SIZE_X, MESH_SIZE_Y = parse_place_file(target_folder + "top.place", logfile)

        #initialise the connectors data structure
        connectors = []

        for y in range (0, (MESH_SIZE_Y - 1)) : 

            for x in range (0, (MESH_SIZE_X - 1)) :

                connectors.append({
                    "x": x,
                    "y": y,
                    "chan": "CHANX",
                    "config": [0] * 64
                })

                connectors.append({
                    "x": x,
                    "y": y,
                    "chan": "CHANY",
                    "config": [0] * 64
                })

        logfile.write("INFO: Initialised connectror data structure as ... \n\n")

        for connector in connectors:

            logfile.write(f"{connector}\n")

        logfile.write("\n\n")



        blocks = sorted(blocks, key=lambda block: (-block['y'], block['x'], block['subblk'])) #order them by grid location, useful seeing as config is in shift register through design
        
        blocks = extract_io_bits(blocks, MESH_SIZE_X, MESH_SIZE_Y, logfile)

        lut_configs = extract_lut_configs(target_folder + "top.pre-vpr.blif", logfile)

        # now have luts and IO bits, still need to extract: which CLBs have which lUTS, switchbox settings and connection box settings
        # once I know which order the inputs enter the CLBs, from cx settings, I can get cx settings from lut_configs.
        
        connectors, blocks = extract_connector_configs(target_folder + "top.route", MESH_SIZE_X, MESH_SIZE_Y, connectors, blocks, logfile) # returns cx configs. also adds clb inputs in order to the blocks data structure
        
        logfile.write(f"INFO: printing blocks...\n")  # Write each dictionary on a new line
        for block in blocks:
            logfile.write(f"{block}\n")  # Write each dictionary on a new line
        logfile.write(f"\n\n")  # Write each dictionary on a new line

        logfile.write("INFO: printing connectors... \n\n")
        for connector in connectors:
            logfile.write(f"{connector}\n")
        logfile.write("\n\n")




# Run the script
if __name__ == "__main__":
    main() 