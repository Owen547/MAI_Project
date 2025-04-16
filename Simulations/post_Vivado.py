import os
import shutil
import sys

def move_logs(source_dir, target_dir, log_filenames):
    """
    Check the source directory for specific log files and move them to the target directory.
    
    Args:
        source_dir (str): The directory to search for log files.
        target_dir (str): The directory to move found log files to.
        log_filenames (list): A list of log filenames to look for.
    """
    # Create the target directory if it does not exist.
    os.makedirs(target_dir, exist_ok=True)
    
    for log_file in log_filenames:
        source_file_path = os.path.join(source_dir, log_file)
        if os.path.exists(source_file_path):
            target_file_path = os.path.join(target_dir, log_file)
            
            # Move the file from source to target directory.
            shutil.move(source_file_path, target_file_path)
            print(f"Moved '{source_file_path}' to '{target_file_path}'.")
        else:
            print(f"File '{source_file_path}' not found.")

if __name__ == '__main__':

    # Remove the surrounding quotes using strip, and then split by whitespace
    numbers = sys.argv[1].strip('"').split()

    # Assign to two variables
    MESH_SIZE_X, MESH_SIZE_Y = numbers

    # Define the source directory containing the log files.
    source_directory = '/home/owen/College/MAI_Project/Vivado/seq_sim_runs/8_bit_adder'
    # Define the target directory where log files will be moved.
    target_directory = f"/home/owen/College/MAI_Project/Simulations/impl_runs/X_{MESH_SIZE_X}_Y_{MESH_SIZE_Y}"
    # Define a list of log filenames to search for.
    log_files = [
        'run_util.txt',
        'run_timing.txt',
        'run_power.txt',
        'log.txt'
    ]
    
    move_logs(source_directory, target_directory, log_files)