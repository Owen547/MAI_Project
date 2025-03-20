import re
from extract_routing import *

target_folder = "/home/owen/College/VTR_runs/arch_runs/test_run/"

bitstream_file = "bitsream.txt"

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

    io_locations = []

    for y in range(MESH_SIZE_Y-1, -1, -1):

        for x in range(0, MESH_SIZE_X):

            if (x == 0 and 0 < y < MESH_SIZE_Y-1) or (x == MESH_SIZE_X - 1 and 0 < y < MESH_SIZE_Y-1) or (y == 0 and 0 < x < MESH_SIZE_X-1) or ((y == MESH_SIZE_Y -1  and 0 < x < MESH_SIZE_X-1)): 

                for subblk in range(0, 3):

                    io_locations.append({
                            "x": x,
                            "y": y,
                            "subblk": subblk
                    })

    logfile.write(f"\nINFO: Printing io_locations... \n")
    for location in io_locations:
        logfile.write(f"{location}\n")  # Write each dictionary on a new line
    logfile.write(f"\n\n")  # Write each dictionary on a new line


    with open ("./io_verilog.txt", "w") as io_file:

        for block in blocks:

            if (block['y'] == (MESH_SIZE_Y - 1)) or (block['y'] == (0)) or (block['x'] == (MESH_SIZE_X - 1)) or (block['x'] == 0) :

                if block['name'].startswith("out"):

                    block['type'] = "IO" # label block as IO
                    block['bitstream'] = "01" # enable output, drive input low

                    if ("~") in block['name']: 

                        match = re.match(r"out:(\S+)~(\d+)", block['name'])
                        
                        data_out_index = 0

                        for io_location in io_locations :

                            if io_location["x"] == block["x"] and io_location["y"] == block["y"] and io_location["subblk"] == block["subblk"][0] :

                                io_file.write(f"assign {match.group(1)}[{match.group(2)}] = data_out[{data_out_index}];\n")
                            
                            else:

                                data_out_index = data_out_index + 1
                    else:

                        match = re.match(r"out:(\S+)", block['name'])
                        
                        data_out_index = 0

                        for io_location in io_locations :

                            if io_location["x"] == block["x"] and io_location["y"] == block["y"] and io_location["subblk"] == block["subblk"][0] :

                                io_file.write(f"assign {match.group(1)} = data_out[{data_out_index}];\n")
                            
                            else:

                                data_out_index = data_out_index + 1

                else : 

                    block['type'] = "IO" # label block as IO
                    block['bitstream'] = "10" #enable input, drive output low

                    if ("~") in block['name']: 

                        match = re.match(r"(\S+)~(\d+)", block['name'])
                        
                        data_in_index = 0

                        for io_location in io_locations :

                            if io_location["x"] == block["x"] and io_location["y"] == block["y"] and io_location["subblk"] == block["subblk"][0] :

                                io_file.write(f"assign data_in[{data_in_index}] = {match.group(1)}[{match.group(2)}];\n")
                            
                            else:

                                data_in_index = data_in_index + 1
                    else :

                        match = re.match(r"(\S+)", block['name'])
                        
                        data_in_index = 0

                        for io_location in io_locations :

                            if io_location["x"] == block["x"] and io_location["y"] == block["y"] and io_location["subblk"] == block["subblk"][0] :

                                io_file.write(f"assign data_in[{data_in_index}] = {match.group(1)};\n")
                            
                            else:

                                data_in_index = data_in_index + 1

            else: 

                block['type'] = "CLB" # label block as CLB
                block['inputs'] = [""] * 16
                block['luts'] = [""] * 3
                block["cx_config"] = [0] * (18 * 4)


    logfile.write(f"INFO: printing blocks with IO bits...\n")  # Write each dictionary on a new line
    for block in blocks:
        logfile.write(f"{block}\n")  # Write each dictionary on a new line
    logfile.write(f"\n\n")  # Write each dictionary on a new line

    return blocks


def expand_inputs (lut_config, input, logfile):

    for i in range (1, (6 - (len(input)) + 1)):

        # logfile.write("DEBUG: missing values in string is " + str(6 - (len(input))) + "\n")

        input = input + '-'

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
                
                lut_config = [0] * 65
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

    return luts


def extract_clb_internal_cx_config(luts, blocks, logfile):

    for block in blocks:

        if (block["type"] == "CLB") :

            output_offset = 0

            for lut_name in block["luts"] : #get all the ble names in a CLB
                                
                if (lut_name != '') : #for non open bles
                    
                    for lut in luts :
                        
                        if (lut["name"] == lut_name) :

                            break

                output_index = (output_offset*4) + 4

                input_sel = 0

                for input in (lut["inputs"]).split(" ", ) :

                    for i in range (0, 16):

                        if (block["inputs"][i] == input) :

                            input_sel = format(1 + i, f'04b')
                    
                            block["cx_config"][output_index-4:output_index] = input_sel

                            output_index = output_index + 4

                output_offset = output_offset + 6

    return blocks


def write_bitstream(file_path, MESH_SIZE_X, MESH_SIZE_Y, blocks, luts, connectors, switches, logfile):

    with open(file_path, 'w') as file :

        #top io


        for x_index in range (1, MESH_SIZE_X-1) :

            # file.write("\n IO block... \n")

            for subblock in range(0, 3):

                block_found = 0

                for block in blocks:

                    if (block["x"] == x_index) and (block["y"] == MESH_SIZE_Y - 1) and (block["subblk"][0] == subblock) :

                        file.write(block["bitstream"])

                        block_found  = 1

                if not block_found :

                    file.write("00") 

            # file.write("\n IO block finished... \n")

        # loop through the normal rows

        for y_index in range(MESH_SIZE_Y - 2, -1, -1) :

            for x_index in range (0, MESH_SIZE_X - 1) : # switch row

                # file.write("\n SWBX block... \n")

                for switch in switches:

                    if (switch["x"] == x_index and switch["y"] == y_index) :

                        result = ""

                        for item in switch["config"] :
                            
                            result = result + str(item)
                        
                        file.write(result)

                # file.write("\n Finished SWBX block... \n")

                if (x_index < MESH_SIZE_X - 2) :
                    
                    # file.write("\n CX block... \n")

                    for connector in connectors :

                        if (connector["x"] == x_index + 1) and (connector["y"] == y_index) and (connector["chan"] == "CHANX") :

                            result = ""

                            for item in connector["config"] :
                                
                                result = result + str(item)

                            file.write(result)

                    # file.write("\n Finished CX block... \n")

            if (y_index > 0 ) : #clb row


                for x_index in range (0, MESH_SIZE_X) :

                    if (x_index == 0): #left io
                        
                        # file.write("\n IO block... \n")

                        for subblock in range(0, 3):

                            block_found = 0

                            for block in blocks:

                                if (block["x"] == x_index) and (block["y"] == y_index) and (block["subblk"][0] == subblock) :

                                    file.write(block["bitstream"])

                                    block_found  = 1

                            if not block_found :

                                file.write("00")   

                        # file.write("\n FinishedIO block... \n")

                        # file.write("\n CX block... \n")

                        for connector in connectors :

                            if (connector["x"] == x_index) and (connector["y"] == y_index) and (connector["chan"] == "CHANY") :

                                    result = ""

                                    for item in connector["config"] :
                                        
                                        result = result + str(item)

                                    file.write(result)
                        
                        # file.write("\n Finished CX block... \n")

                    elif (x_index < MESH_SIZE_X - 1) : #middle cols

                        block_found = 0

                        # file.write("\n CLB block... \n")

                        for block in blocks:

                            if (block["x"] == x_index) and (block["y"] == y_index) :

                                result = ""

                                for item in block["cx_config"] :
                                    
                                    result = result + str(item)

                                file.write(result)
                                
                                for lut_name in block["luts"] : #get all the ble names in a CLB
                                    
                                    if (lut_name != '') : #for non open bles

                                        for lut in luts :

                                            if (lut_name == lut["name"]) :

                                                result = ""

                                                for item in lut["config"] :
                                                    
                                                    result = result + str(item)

                                                file.write(result)

                                    else :

                                        for i in range(0, 65) :

                                            file.write("0")

                                block_found = 1

                                break

                        if not block_found:

                            for i in range (0, 267) :

                                file.write("0")

                        # file.write("\nFinished CLB block... \n")

                        # file.write("\n CX block... \n")

                        for connector in connectors :

                            if (connector["x"] == x_index) and (connector["y"] == y_index) and (connector["chan"] == "CHANY") :

                                    result = ""

                                    for item in connector["config"] :
                                        
                                        result = result + str(item)

                                    file.write(result)

                        # file.write("\nFinished CX block... \n")
                                
                    else : #right io, middle rows

                        # file.write("\nIO block... \n")

                        for subblock in range(0, 3):

                            block_found = 0

                            for block in blocks:

                                if (block["x"] == x_index) and (block["y"] == y_index) and (block["subblk"][0] == subblock) :

                                    file.write(block["bitstream"])

                                    block_found  = 1

                            if not block_found :

                                file.write("00") 

                        # file.write("\nFinished IO block... \n")

        #bottom io

        for x_index in range (1, MESH_SIZE_X - 1) :

            # file.write("\nIO block... \n")

            for subblock in range(0, 3):

                block_found = 0

                for block in blocks:

                    if (block["x"] == x_index) and (block["y"] == 0) and (block["subblk"][0] == subblock) :

                        file.write(block["bitstream"])

                        block_found  = 1

                if not block_found :

                    file.write("00")   

            # file.write("\nFinished IO block... \n")
              
    

    return


# Main function to run the script

def main():

    with open ("logfile.txt", "w+") as logfile: 

        # Parse the place file, extract clb and io placements as well as grid size
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
        
        #initialise the switchbox data structure
        switches = []

        for y in range (0, MESH_SIZE_Y - 1) : 

            for x in range (0, MESH_SIZE_X - 1) :

                switches.append({
                    "x": x,
                    "y": y,
                    "config": [0] * 40
                })
                

        # # initialise connectors with swbx in to swbx out
        # connectors = initialise_connector_configs(connectors, logfile)

        #order them by grid location top left to bottom right
        blocks = sorted(blocks, key=lambda block: (-block['y'], block['x'], block['subblk'])) 
        
        #extract the io config bits from place file, ie in or out for sub block.
        blocks = extract_io_bits(blocks, MESH_SIZE_X, MESH_SIZE_Y, logfile)

        #extract the lut configurations, ble names and inputs from top.pre-vpr.blif
        luts = extract_lut_configs(target_folder + "top.pre-vpr.blif", logfile)

        #get connector configs from top.route. this will assign inputs and output, may overwrite initialisation of cx
        #for example a lut output connects to a track.
        # connectors, blocks = extract_connector_configs(target_folder + "top.route", MESH_SIZE_X, MESH_SIZE_Y, connectors, blocks, logfile) # returns cx configs. also adds clb inputs in order to the blocks data structure

        # #extract the switch configs from the top.route file. Switch muxes are intitialised to drive 0. This will overwrite that to take an input
        # switches = extract_switch_configs(target_folder + "top.route", switches, logfile)

        blocks, connectors, switches = extract_routing_configs(target_folder + "top.route", blocks, connectors, switches, logfile)

        #using the luts that were extracted from the blif, lut locations from top.route, the configuration for the crossbar in the clbs is extracted
        blocks = extract_clb_internal_cx_config(luts, blocks, logfile)

        #print all the data to the log for debug.
        logfile.write("INFO: printing switches... \n\n")
        for switch in switches:
            logfile.write(f"{switch}\n")
        logfile.write("\n\n")

        logfile.write(f"INFO: printing blocks...\n\n") 
        for block in blocks:
            logfile.write(f"{block}\n")
        logfile.write(f"\n\n")  

        logfile.write("INFO: printing connectors... \n\n")
        for connector in connectors:
            logfile.write(f"{connector}\n")
        logfile.write("\n\n")

        logfile.write("INFO: printing LUTs... \n\n")
        for lut in luts:
            logfile.write(f"{lut}\n")
        logfile.write("\n\n")

        #print the bitstream using all the stored configurations
        write_bitstream("./bitstream.txt", MESH_SIZE_X, MESH_SIZE_Y, blocks, luts, connectors, switches, logfile)

# Run the script
if __name__ == "__main__":
    main() 