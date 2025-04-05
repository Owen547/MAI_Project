import re

def get_cx_source_input_index (last_line, source_cx, blocks, name):

    match = re.match(r"Node:\s+\d+\s+\S+\s+\((\d+),(\d+),\S+\)\s+(\S+): (\d+)", last_line)  

    x = int(match.group(1))
    y = int(match.group(2))
    pin_number = int(match.group(4))  

    OPIN_type = match.group(3)

    if (OPIN_type == "Pin") : #its an output from a CLB

        for block in blocks:

            if (block["x"] == x) and (block["y"] == y) :

                    block['luts'][pin_number - 12] = name 
                    block['inputs'][pin_number] = name

                    break   

        #4 cases: 
        # CHANX: above and below
        # CHANY: above and below

        if (source_cx[0] == "CHANX") : #its chanx

            if (source_cx[2] < y): #cx is below clb

                source_input_index = pin_number - 12 + 5

            else: #cx is above clb

                source_input_index = pin_number - 12 + 13

        else: #its chany

            if (source_cx[1] < x): #cx is left of CLB

                source_input_index = pin_number - 12 + 8

            else: #cx is right of CLB

                source_input_index = pin_number - 12


    else : #its a IO block pad

        #4 cases
        #chanx: bottom or top edge
        #Chany left or right edge

        if (source_cx[0] == "CHANX") : #its chanx

            if (source_cx[2] == 0): #cx is bottom edge IO

                source_input_index = ((pin_number - 1) / 3) + 13

            else: #cx is top edge IO

                source_input_index = ((pin_number - 1) / 3) + 5

        else: #its chany

            if (source_cx[1] == 0): #cx is left edge IO

                source_input_index = ((pin_number - 1) / 3)

            else: #cx its right edge IO

                    source_input_index = ((pin_number - 1) / 3) + 8

    return int(source_input_index), blocks


def get_cx_output_index_switch (current_cx):

    #2 cases chanx or chany
    #

    if (current_cx[0] == "CHANX"): #chanx connector 

        if ((current_cx[3] % 2) == 0) : # right ouput

            output_index = (current_cx[3]/2) + 8

        else : #left output

            output_index = ((current_cx[3] - 1)/2)
            

    else: #its a chany connector

        if (current_cx[3] % 2 == 0) : # top output

            output_index = (current_cx[3]/2) + 3

        else : #bottom output

            output_index = ((current_cx[3] - 1)/2) + 11

    return int(output_index)

def get_cx_output_index_CLB_IO (blocks, name, current_cx, line):

    match = re.match(r"Node:\s+\d+\s+\S+\s+\((\d+),(\d+),\S+\)\s+(\S+): (\d+)", line)  

    x = int(match.group(1))
    y = int(match.group(2))
    pin_number = int(match.group(4))  

    if (match.group(3) == "Pin"): #cx output is to CLB

        for block in blocks:

            if (block["x"] == x) and (block["y"] == y) : #save e

                block['inputs'][pin_number] = name

                break

        # 4 situations
        #chanx left, right output
        #Chany left, rioght output
        
        if (current_cx[0] == "CHANX"): #chanx connector 

            if (8 < pin_number < 12) : #top output

                output_index =  5 + (pin_number - 9)

            else : #bottom output

                output_index =  13 + (pin_number - 3)
                

        else: #its a chany connector

            if (5 < pin_number < 9) : # left output

                output_index = (pin_number - 6)

            else : #right output

                output_index = 8 + (pin_number)
                
    else : #cx output is to IO

        # 4 situations
        #chanx top, bottom output
        #Chany left, right output

        if (current_cx[0] == "CHANX"): #chanx connector 

            if (current_cx [2] == 0) : #bottom edge io

                output_index = pin_number / 3 + 13
            
            else: #top edge io

                output_index = pin_number / 3 + 5

        else : #chany connector
            
            if (current_cx [1] == 0) :#left edge io

                output_index = pin_number / 3 

            else : #right edge io
                
                output_index = pin_number / 3 + 8


    return int(output_index), blocks

def get_cx_input_index (current_cx):
    #2 cases chanx or chany
    #

    if (current_cx[0] == "CHANX"): #chanx connector 

        if ((current_cx[3] % 2) == 0) : # left input

            input_index = (current_cx[3]/2)

        else : #rigt input

            input_index = ((current_cx[3] - 1)/2) + 8
            

    else: #its a chany connector

        if ((current_cx[3] % 2) == 0) : #bottom input

            input_index = (current_cx[3]/2) + 11

        else : #top input

            input_index = ((current_cx[3] - 1)/2) + 3

    return int(input_index)


def configure_connector(connectors, current_cx, source_input_index, output_index) : 

    for connector in connectors:

        if (connector["x"] == current_cx[1]) and (connector["y"] == current_cx[2] and connector["chan"] == current_cx[0]):
    
            break

    input_sel = format(source_input_index, f'04b')

    output_index = (output_index * 4) + 4

    connector["config"][(output_index-4):(output_index)] = input_sel   

    return connectors


def extract_switch_configs(current_cx, last_cx, switches, logfile):

    last_chan = last_cx[0]
    last_cx_x = last_cx[1]
    last_cx_y = last_cx[2]
    last_track = last_cx[3]


    chan = current_cx[0]
    cx_x = current_cx[1]
    cx_y = current_cx[2]
    track = current_cx[3]

    if (last_chan == "CHANX"):

        #is it left or right input

        if (last_track % 2 == 0) :  #left input...

            for switch in switches :

                if (switch["x"] == last_cx_x) and (switch["y"] == last_cx_y) :

                    break

            #top output

            if (last_cx_y == cx_y - 1) and (last_cx_x == cx_x) :

                output_index = int(((last_track/2) * 2 * 4) + 4 )
                input_sel = format(1, f'02b')
                switch["config"][output_index-2:output_index] = input_sel

            #right output

            elif (last_cx_x == cx_x - 1) and (last_cx_y == cx_y) :

                output_index =  int(((last_track/2) * 2 * 4) + 6)
                input_sel = format(1, f'02b')
                switch["config"][output_index-2:output_index] = input_sel

            #bottom output

            elif (last_cx_y == cx_y) and (last_cx_x == cx_x) :
    
                output_index =  int(((last_track/2) * 2 * 4) + 8)
                input_sel = format(1, f'02b')
                switch["config"][output_index-2:output_index] = input_sel

            else :

                logfile.write("INFO: didn't identify left input switchbox output, must be unroutable\n") 
                logfile.write(f"last_cx: {last_cx}\n")
                logfile.write(f"current_cx: {current_cx}\n")

        else : #right input

            for switch in switches :

                if (switch["x"] == (last_cx_x - 1)) and (switch["y"] == last_cx_y) :

                    break
            
            #top output

            if (last_cx_y == cx_y - 1) and (last_cx_x == cx_x + 1):

                output_index = int((((last_track-1)/2) * 2 * 4) + 4 )
                input_sel = format(2, f'02b')
                switch["config"][output_index-2:output_index] = input_sel


            #left output

            elif (last_cx_x == cx_x + 1) and (last_cx_y == cx_y) and (chan == "CHANX") :

                output_index =  int((((last_track-1)/2) * 2 * 4) + 2)
                input_sel = format(2, f'02b')
                switch["config"][output_index-2:output_index] = input_sel

            #bottom output

            elif (last_cx_y == cx_y) and (last_cx_x == cx_x + 1) and (chan == "CHANY") :
    
                output_index =  int((((last_track-1)/2) * 2 * 4) + 8)
                input_sel = format(3, f'02b')
                switch["config"][output_index-2:output_index] = input_sel

            else :

                logfile.write("INFO: didn't identify right input switchbox output, must be unroutable\n") 
                logfile.write(f"last_cx: {last_cx}\n")
                logfile.write(f"current_cx: {current_cx}\n")

    else : #it's CHANY

        if ((last_track % 2) == 0) : #bottom input

            for switch in switches :

                if (switch["x"] == (last_cx_x)) and (switch["y"] == (last_cx_y)) :

                    break

            #top output

            if (last_cx_y == cx_y - 1) and (last_cx_x == cx_x):

                output_index = int(((last_track/2) * 2 * 4) + 4 )
                input_sel = format(3, f'02b')
                switch["config"][output_index-2:output_index] = input_sel

            #right output

            elif (last_cx_y == cx_y) and (last_cx_x == cx_x - 1):

                output_index =  int(((last_track/2) * 2 * 4) + 6)
                input_sel = format(3, f'02b')
                switch["config"][output_index-2:output_index] = input_sel

            #left output

            elif (last_cx_y == cx_y) and (last_cx_x == cx_x) :
    
                output_index =  int(((last_track/2) * 2 * 4) + 2)
                input_sel = format(3, f'02b')
                switch["config"][output_index-2:output_index] = input_sel

            else :

                logfile.write("INFO: didn't identify bottom input switchbox output, must be unroutable\n") 
                logfile.write(f"last_cx: {last_cx}\n")
                logfile.write(f"current_cx: {current_cx}\n")


        else : #top input

            for switch in switches :

                if (switch["x"] == (last_cx_x)) and (switch["y"] == (last_cx_y - 1)) :

                    break

            #right output

            if (last_cx_y == cx_y + 1) and (last_cx_x == cx_x - 1):

                output_index = int((((last_track-1)/2) * 2 * 4) + 6 )
                input_sel = format(2, f'02b')
                switch["config"][output_index-2:output_index] = input_sel

            #left output

            elif (last_cx_y == cx_y + 1) and (last_cx_x == cx_x) and (chan == "CHANX"):

                output_index =  int((((last_track-1)/2) * 2 * 4) + 2)
                input_sel = format(1, f'02b')
                switch["config"][output_index-2:output_index] = input_sel

            #bottom output

            elif (last_cx_y == cx_y + 1) and (last_cx_x == cx_x) and (chan =="CHANY") :
    
                output_index =  int((((last_track-1)/2) * 2 * 4) + 8)
                input_sel = format(2, f'02b')
                switch["config"][output_index-2:output_index] = input_sel

            else :

                logfile.write("INFO: didn't identify top input switchbox output, must be unroutable\n")                               
                logfile.write(f"last_cx: {last_cx}\n")
                logfile.write(f"current_cx: {current_cx}\n")

        # if (switch["x"] == 0) and (switch["y"] == 0) :
                
        #         logfile.write("INFO: left bottom corner case\n") 
        #         logfile.write(f"last_cx: {last_cx}\n")
        #         logfile.write(f"current_cx: {current_cx}\n")
 

    return switches


def extract_routing_configs(file_path, blocks, connectors, switches, logfile) :

    with open(file_path, 'r') as file :

        last_line = ''

        expecting_routing = 0

        for line in file :
            
            if (expecting_routing) :
                
                if (line.startswith("Net")) :
                    
                    match = re.match(r"Net \d+ \((.*)\)", line)

                    name = match.group(1)

                    visited_nodes = [] #not sure if this is necessary, might be handled by source/last cx functionality 

                elif ("OPIN" in last_line): #determine the source connector, then set connector output

                    match = re.match (r"Node:\s+\d+\s+(\S+)\s+\((\d+),(\d+),\S+\)\s+Track: (\d+)", line)

                    chan = match.group(1)
                    cx_x = int(match.group(2))
                    cx_y = int(match.group(3))
                    track = int(match.group(4))

                    source_cx = (chan, cx_x, cx_y, track)

                    current_cx = source_cx

                    last_cx = source_cx

                    source_input_index, blocks = get_cx_source_input_index(last_line, source_cx, blocks, name)

                    output_index = get_cx_output_index_switch(current_cx)

                    connectors = configure_connector(connectors, current_cx, source_input_index, output_index)

                elif("IPIN" in line) : #determine if it is source cx (special case) and then set connector output

                    if (current_cx == source_cx) : #special case where 

                        input_index = source_input_index

                        match = re.match(r"Node:\s+\d+\s+\S+\s+\((\d+),(\d+),\S+\)\s+(\S+): (\d+)", line)  

                        x = int(match.group(1))
                        y = int(match.group(2))
                        pin_number = int(match.group(4))  

                        if (match.group(3) == "Pin"): #cx output is to CLB

                            for block in blocks:

                                if (block["x"] == x) and (block["y"] == y) : #save e

                                    block['inputs'][pin_number] = name

                                    break
                    
                    else :

                        input_index = get_cx_input_index (current_cx)
                        
                    output_index, blocks = get_cx_output_index_CLB_IO(blocks, name, current_cx, line)
                    
                    configure_connector(connectors, current_cx, input_index, output_index)

                elif ("CHAN" in line):

                    match = re.match (r"Node:\s+\d+\s+(\S+)\s+\((\d+),(\d+),\S+\)\s+Track: (\d+)", line)

                    chan = match.group(1)
                    cx_x = int(match.group(2))
                    cx_y = int(match.group(3))
                    track = int(match.group(4))

                    last_cx = current_cx
        
                    current_cx = (chan, cx_x, cx_y, track)

                    if current_cx in visited_nodes :

                        last_cx = current_cx 

                    else :
                        
                        visited_nodes.append(current_cx)   

                    if (current_cx != last_cx and current_cx != source_cx) :

                        switches = extract_switch_configs(current_cx, last_cx, switches, logfile)

            elif line.startswith("Routing") :

                expecting_routing = 1

            last_line = line

            

    return blocks, connectors, switches
        