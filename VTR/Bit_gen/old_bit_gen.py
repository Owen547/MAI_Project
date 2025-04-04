# def extract_cx_output(name, MESH_SIZE_X, MESH_SIZE_Y, line, last_line, connectors, blocks, logfile): 

#     # initialise a list to swap from VTR trscks to CX input/outputs

#     chanx_track_to_input = [0, 8, 1, 9, 2, 10, 3, 11, 4, 12] # Connector box: equivalence between VTR tracks and verilog design inputs
#     cx_pin_to_output = [8, 9, 10, 13, 14, 15, 0, 1, 2, 5, 6, 7] # takes a clb input pin, and gives the output index its equivalent to in the verilog
#     chany_track_to_input = [3, 11, 4, 12, 5, 13, 6, 14, 7, 15]

#     match = re.match(r"Node:\s+\d+\s+(\S+)\s+\((\d+),(\d+),\S+\)\s+Track: (\d+)", last_line)

#     chan = match.group(1)
#     cx_x = int(match.group(2))
#     cx_y = int(match.group(3))
#     track = int(match.group(4))

#     # logfile.write("DEBUG: IPIN found in current line. Expecting cx output. CX chan, cx_x, cx_y, track: " + chan  + ", " + cx_x + ", " + cx_y + ", " + track + "\n")

#     match = re.match(r"Node:\s+\d+\s+\S+\s+\((\d+),(\d+),\S+\)\s+(\S+): (\d+)", line)

#     x = int(match.group(1))
#     y = int(match.group(2))
#     pin_number = int(match.group(4))

#     if (match.group(3) == "Pin") :

#         for block in blocks:

#             if (block["x"] == x) and (block["y"] == y) :

#                     block['inputs'][pin_number] = name

#                     break

#         for connector in connectors:

#             if (connector["x"] == cx_x) and (connector["y"] == cx_y and connector["chan"] == chan):

#                 output_index = (4 * (cx_pin_to_output[pin_number])) + 4

#                 if (chan == "CHANX") :
                    
#                     input_sel = format((chanx_track_to_input[track]), f'04b')

#                     connector["config"][(output_index-4):(output_index)] = input_sel
                                    
#                 else : # ie its a CHANY cx

#                     input_sel = format((chany_track_to_input[track]), f'04b')

#                     connector["config"][(output_index-4):(output_index)] = input_sel  

#                 break 
    
#     elif (match.group(3) == "Pad") :
        
#         for connector in connectors:

#             if (connector["x"] == cx_x) and (connector["y"] == cx_y and connector["chan"] == chan):

#                 break
        
#         for block in blocks:

#             if (block["name"] == "out:" + name) and (block["x"] == x) and (block["y"] == y) :

#                 output_index = (block["subblk"][0] * 4 ) + 4 #offset the index to the left outputs

#                 break

#         if (int(cx_x) == 0):
            
#             input_sel = format((chany_track_to_input[track]), f'04b') 
            
#             connector["config"][(output_index-4):(output_index)] = input_sel  

#         elif (int(cx_x) == MESH_SIZE_X - 2):

#             output_index = output_index + (8 * 4) #offset the index to the right outputs
            
#             input_sel = format((chany_track_to_input[track]), f'04b') 
            
#             connector["config"][(output_index-4):(output_index)] = input_sel  

#         elif (int(cx_y) == MESH_SIZE_Y - 2):

#             output_index = output_index + (5 * 4) #offset the index to the top outputs
            
#             input_sel = format((chanx_track_to_input[track]), f'04b') 
            
#             connector["config"][(output_index-4):(output_index)] = input_sel  

#         elif (int(cx_y) == 0):

#             output_index = output_index + (13 * 4) #offset the index to the bottom outputs
            
#             input_sel = format((chanx_track_to_input[track]), f'04b') 
            
#             connector["config"][(output_index-4):(output_index)] = input_sel 

#         else :
        
#             logfile.write("ERROR: expected IO/edge location of connector, coordinates did not support this :(\n")

#     else :

#         logfile.write("ERROR: expected pin or pad, found neither\n")

#     return connectors, blocks
    
# def extract_cx_input(name, MESH_SIZE_X, MESH_SIZE_Y, line, last_line, connectors, blocks, logfile):

#     # initialise a list to swap from VTR trscks to CX input/outputs

#     chanx_track_to_input = [0, 8, 1, 9, 2, 10, 3, 11, 4, 12] # Connector box: equivalence between VTR tracks and verilog design inputs
#     cx_pin_to_output = [8, 9, 10, 13, 14, 15, 0, 1, 2, 5, 6, 7] # takes a clb input pin, and gives the output index its equivalent to in the verilog
#     chany_track_to_input = [3, 11, 4, 12, 5, 13, 6, 14, 7, 15]

#     match = re.match(r"Node:\s+\d+\s+(\S+)\s+\((\d+),(\d+),\S+\)\s+Track: (\d+)", line)

#     chan = match.group(1)
#     cx_x = int(match.group(2))
#     cx_y = int(match.group(3))
#     track = int(match.group(4))

#     # logfile.write("DEBUG: OPIN found in current line. Expecting cx output. CX chan, cx_x, cx_y, track: " + chan  + ", " + cx_x + ", " + cx_y + ", " + track + "\n")

#     # logfile.write("DEBUG: line: " + line + "\nlast_line: " + last_line)

#     match = re.match(r"Node:\s+\d+\s+\S+\s+\((\d+),(\d+),\S+\)\s+(\S+): (\d+)", last_line)

#     x = int(match.group(1))
#     y = int(match.group(2))
#     pin_number = int(match.group(4))  

#     if (match.group(3) == "Pin") :

#         for block in blocks:

#             if (block["x"] == x) and (block["y"] == y) :

#                     block['luts'][pin_number - 12] = name 
#                     block['inputs'][1 + pin_number] = name

#                     break                           

#         input_offset = pin_number - 12 

#         for connector in connectors:

#             if (connector["x"] == cx_x) and (connector["y"] == cx_y and connector["chan"] == chan):

#                 if (chan == "CHANX") :
                    
#                     if (cx_y < y) :

#                         input_sel = format((5 + input_offset), f'04b')

#                     else :

#                         input_sel = format((13 + input_offset), f'04b')

#                     output_index = (chanx_track_to_input[track] * 4) + 4

#                     connector["config"][(output_index-4):(output_index)] = input_sel
                
                                    
#                 else : # i.e. its a CHANY cx

#                     if (cx_x < x) :

#                         input_sel = format((0 + input_offset), f'04b')

#                     else :

#                         input_sel = format((8 + input_offset), f'04b')  

#                     output_index = (chany_track_to_input[track] * 4) + 4

#                     connector["config"][(output_index-4):(output_index)] = input_sel

#                 break


#     elif (match.group(3) == "Pad") :

#         block_found = 0

#         for block in blocks:

#             if (block["x"] == int(x)) and (block["y"] == int(y) and (block["name"] == name)) :

#                     input_offset = block["subblk"][0]

#                     block_found = 1 

#                     break

#         if not block_found:

#             logfile.write("ERROR: Didn't find the block\nname, x, y, pin number, pin/pad: " + name + ", " + x + ", " + y + ", " + pin_number + ", " + match.group(3) + "\n")

#         for connector in connectors:

#             if (connector["x"] == cx_x) and (connector["y"] == cx_y and connector["chan"] == chan):

#                 if (int(cx_x) == 0) or (int(cx_x) == MESH_SIZE_X - 2) :

#                     if (int(cx_x) == 0) : 
                        
#                         input_sel = format((0 + input_offset), f'04b')

#                     else :

#                         input_sel = format((8 + input_offset), f'04b')  

#                     output_index = (chany_track_to_input[track] * 4) + 4

#                     connector["config"][(output_index-4):(output_index)] = input_sel

#                 elif (int(cx_x) > 0) and (int(cx_x) < (MESH_SIZE_X - 2)) :

#                     if (int(cx_y) == 0) : 

#                         input_sel = format((5 + input_offset), f'04b')

#                     else :

#                         input_sel = format((13 + input_offset), f'04b')

#                     output_index = (chanx_track_to_input[track] * 4) + 4

#                     connector["config"][(output_index-4):(output_index)] = input_sel

#                 else:

#                     logfile.write("ERROR: couldn't find anything within the coordinates specified for cx input config extraction\n")
                    
#                 break
#     else :

#         logfile.write("ERROR: expected pin or pad, found neither\n")

#     return connectors, blocks

# def extract_connector_configs(file_path, MESH_SIZE_X, MESH_SIZE_Y, connectors, blocks, logfile) :

#     # # initialise a list to swap from VTR trscks to CX input/outputs

#     # chanx_track_to_input = [0, 8, 1, 9, 2, 10, 3, 11, 4, 12] # Connector box: equivalence between VTR tracks and verilog design inputs
#     # cx_pin_to_output = [8, 9, 10, 13, 14, 15, 0, 1, 2, 5, 6, 7] # takes a clb input pin, and gives the output index its equivalent to in the verilog
#     # chany_track_to_input = [3, 11, 4, 12, 5, 13, 6, 14, 7, 15]

#     #add CLB inputs in their order to the blocks data structure, I can later consolidate the lut_configs and CLB block descriptions to get CLB cx configs

#     with open(file_path, 'r') as file :

#         last_line = ''

#         expecting_routing = 0

#         for line in file :
            
#             if (expecting_routing) :

#                 if (line.startswith("Net")) :
                    
#                     match = re.match(r"Net \d+ \((.*)\)", line)

#                     name = match.group(1)

#                     # logfile.write("DEBUG: Entering routing for net " + name + "\n")

#                 else:

#                     if "IPIN" in line : #cx outputs, to clb or io

#                         connectors, blocks = extract_cx_output(name, MESH_SIZE_X, MESH_SIZE_Y, line, last_line, connectors, blocks, logfile)
                        
#                         # logfile.write("skipping..\n")

#                     elif "OPIN" in last_line : #CX Inputs.. from io or clb

#                         connectors, blocks = extract_cx_input(name, MESH_SIZE_X, MESH_SIZE_Y, line, last_line, connectors, blocks, logfile)



#             elif line.startswith("Routing") :

#                 expecting_routing = 1

#             last_line = line

#     return connectors, blocks

# # def initialise_connector_configs(connectors, logfile):

# #     for connector in connectors :

# #         if (connector["chan"] == "CHANX")  :
            
# #             for i in range(0, 5) :
                
# #                 output_index = ((8 * 4) + 4) + (i * 4)
# #                 input_sel = format(i, f'04b')
# #                 connector["config"][output_index - 4:output_index] = input_sel

# #             for i in range(8, 13) :

# #                 output_index = 4 + ((i-8) * 4)
# #                 input_sel = format(i, f'04b')
# #                 connector["config"][output_index - 4:output_index] = input_sel
        
# #         else :
                        
# #             for i in range(3, 8) :
                
# #                 output_index = ((3 * 4) + 4) + ((i-3) * 4)
# #                 input_sel = format(i, f'04b')
# #                 connector["config"][output_index - 4:output_index] = input_sel

# #             for i in range(11, 16) :

# #                 output_index = ((11 * 4) + 4) + ((i-11) * 4)
# #                 input_sel = format(i, f'04b')
# #                 connector["config"][output_index - 4:output_index] = input_sel

# #     return connectors


# def extract_switch_configs(file_path, switches, logfile):

#     with open(file_path, 'r') as file :

#         last_line = ''

#         expecting_routing = 0

#         for line in file :
            
#             if (expecting_routing) :

#                 if (line.startswith("Net")) :
                    
#                     match = re.match(r"Net \d+ \((.*)\)", line)

#                     name = match.group(1)

#                     # logfile.write("DEBUG: Entering routing for net " + name + "\n")

#                 else:

#                     if ("CHAN" in line) and ("CHAN" in last_line): #cx outputs, to clb or io

#                         match = re.match(r"Node:\s+\d+\s+(\S+)\s+\((\d+),(\d+),\S+\)\s+Track: (\d+)", last_line)

#                         last_chan = match.group(1)
#                         last_cx_x = int(match.group(2))
#                         last_cx_y = int(match.group(3))
#                         last_track = int(match.group(4))

#                         match = re.match(r"Node:\s+\d+\s+(\S+)\s+\((\d+),(\d+),\S+\)\s+Track: (\d+)", line)

#                         chan = match.group(1)
#                         cx_x = int(match.group(2))
#                         cx_y = int(match.group(3))
#                         track = int(match.group(4))

#                         if (last_chan == "CHANX"):

#                             #is it left or right input

#                             if (last_track % 2 == 0) :  #left input...

#                                 for switch in switches :

#                                     if (switch["x"] == last_cx_x) and (switch["y"] == last_cx_y) :

#                                         break

#                                 #top output

#                                 if (last_cx_y < cx_y):

#                                     output_index = int(((last_track/2) * 2 * 4) + 4 )
#                                     input_sel = format(1, f'02b')
#                                     switch["config"][output_index-2:output_index] = input_sel


#                                 #right output

#                                 elif (last_cx_x < cx_x) :

#                                     output_index =  int(((last_track/2) * 2 * 4) + 6)
#                                     input_sel = format(1, f'02b')
#                                     switch["config"][output_index-2:output_index] = input_sel

#                                 #bottom output

#                                 elif (last_cx_y == cx_y) and (last_cx_x == cx_x) :
                        
#                                     output_index =  int(((last_track/2) * 2 * 4) + 8)
#                                     input_sel = format(1, f'02b')
#                                     switch["config"][output_index-2:output_index] = input_sel

#                                 else :

#                                     logfile.write("ERROR: didn't identify left input switchbox output\n")

#                             else : #right input

#                                 for switch in switches :

#                                     if (switch["x"] == (last_cx_x - 1)) and (switch["y"] == last_cx_y) :

#                                         break

#                                 #top output

#                                 if (last_cx_y < cx_y):

#                                     output_index = int((((last_track-1)/2) * 2 * 4) + 4 )
#                                     input_sel = format(2, f'02b')
#                                     switch["config"][output_index-2:output_index] = input_sel


#                                 #left output

#                                 elif (last_cx_x > cx_x) and (last_cx_y == cx_y) :

#                                     output_index =  int((((last_track-1)/2) * 2 * 4) + 2)
#                                     input_sel = format(2, f'02b')
#                                     switch["config"][output_index-2:output_index] = input_sel

#                                 #bottom output

#                                 elif (last_cx_y == cx_y) and (last_cx_x > cx_x) :
                        
#                                     output_index =  int((((last_track-1)/2) * 2 * 4) + 8)
#                                     input_sel = format(3, f'02b')
#                                     switch["config"][output_index-2:output_index] = input_sel

#                                 else :

#                                     logfile.write("ERROR: didn't identify right input switchbox output\n")
                                

#                         else : #it's CHANY

#                             if ((last_track % 2) == 0) : #bottom input

#                                 for switch in switches :

#                                     if (switch["x"] == (last_cx_x)) and (switch["y"] == (last_cx_y)) :

#                                         break

#                                 #top output

#                                 if (last_cx_y < cx_y):

#                                     output_index = int(((last_track/2) * 2 * 4) + 4 )
#                                     input_sel = format(3, f'02b')
#                                     switch["config"][output_index-2:output_index] = input_sel


#                                 #right output

#                                 elif (last_cx_x < cx_x) :

#                                     output_index =  int(((last_track/2) * 2 * 4) + 6)
#                                     input_sel = format(3, f'02b')
#                                     switch["config"][output_index-2:output_index] = input_sel

#                                 #left output

#                                 elif (last_cx_y == cx_y) and (last_cx_x == cx_x) :
                        
#                                     output_index =  int(((last_track/2) * 2 * 4) + 2)
#                                     input_sel = format(3, f'02b')
#                                     switch["config"][output_index-2:output_index] = input_sel

#                                 else :

#                                     logfile.write("ERROR: didn't identify bottom input switchbox output\n")

#                             else : #top input

#                                 for switch in switches :

#                                     if (switch["x"] == (last_cx_x)) and (switch["y"] == (last_cx_y - 1)) :

#                                         break

#                                 #right output

#                                 if (last_cx_y > cx_y) and (last_cx_x < cx_x):

#                                     output_index = int((((last_track-1)/2) * 2 * 4) + 6 )
#                                     input_sel = format(2, f'02b')
#                                     switch["config"][output_index-2:output_index] = input_sel

#                                 #left output

#                                 elif (last_cx_x == cx_x) and (last_cx_y > cx_y) :

#                                     output_index =  int((((last_track-1)/2) * 2 * 4) + 2)
#                                     input_sel = format(1, f'02b')
#                                     switch["config"][output_index-2:output_index] = input_sel

#                                 #bottom output

#                                 elif (last_cx_y == cx_y) and (last_cx_x == cx_x) :
                        
#                                     output_index =  int((((last_track-1)/2) * 2 * 4) + 8)
#                                     input_sel = format(2, f'02b')
#                                     switch["config"][output_index-2:output_index] = input_sel

#                                 else :

#                                     logfile.write("ERROR: didn't identify top input switchbox output\n")                               
                                

#             elif line.startswith("Routing") :

#                 expecting_routing = 1

#             last_line = line

#     return switches