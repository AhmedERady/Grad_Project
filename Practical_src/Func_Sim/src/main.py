from TLFunctions import *
from threading import Thread
import time
import os

# User Input: Enter image folder & image name <WITH .type (png/jpg/ect)>
image_folder = "Apple___healthy"
image_name   = "AppleHealthy1.JPG"

img_path = os.path.join(os.path.dirname(__file__), "..", "eval", image_folder, image_name)

# API_in, API_start, API_out, API_fin
socket_ref = [0 for i in range(4)]

# temp_ker_mat, temp_inp_mat, ker_row, ker_col, inp_row, inp_col, FPGA_start, FPGA_out, FPGA_fin
SM_ref = [0 for i in range(9)]

API_thread  = Thread(target=api, args=(socket_ref,SM_ref))
FPGA_thread = Thread(target=fpga, args=(SM_ref,))

print("=== Sim: START ===\n")

total_time = time.time()

API_thread.start()
time.sleep(.25)
FPGA_thread.start()
time.sleep(.25)

# Write API_in, API_start
print("UI: Write API_in, API_start to socket_ref")
socket_ref[0] = img_path
socket_ref[1] = 1

# Read API_fin
while socket_ref[3] == 0:
	time.sleep(0.000001)

print("\nUI: Read API_fin from socket_ref")

# Write API_fin
socket_ref[3] = 0

# Read API_out
print("UI: Read API_out from socket_ref\n")
prediction = socket_ref[2]

display(prediction)

print("UI: Total time = ", time.time()-total_time)

print("\n=== Sim: END ===")
print("CTRL+C to exit")
