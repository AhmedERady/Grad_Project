from TLFunctions import *
from threading import Thread
import time
import os

# User Input: Enter image folder & image name <WITH .type (png/jpg/ect)>
image_folder = "Apple___healthy"
image_name   = "AppleHealthy1.JPG"

img_path = os.path.join(os.path.dirname(__file__), "..", "eval", image_folder, image_name)

print("=== API: START ===\n")

total_time = time.time()

img = load_img(img_path)

API_out = model(img)
display(API_out)
print("Total time =", time.time() - total_time)
print()
