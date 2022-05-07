from LLFunctions import *
import time
import os
from ctypes import *

# Link between UI & System
def api(socket_ref, SM_ref):
  
  while 1:
    time.sleep(0.000001)

    # Read API_start
    if socket_ref[1] == 0:
      continue

    print("\nAPI: Read API_start from socket_ref")

    # Write API_start
    socket_ref[1] = 0

    # Read API_in
    print("API: Read API_in from socket_ref")
    API_in = socket_ref[0]
    img = load_img(API_in)

    # Load weights file
    weights_path = os.path.join(os.path.dirname(__file__), "..", "weights.hdf5")
    f = load_file(weights_path, 'r')
    
    API_out = model(img, SM_ref, f)

    # Write API_out, API_fin
    print("API: Write API_out to socket_ref")
    socket_ref[2] = API_out
    socket_ref[3] = 1

def model(model_in, SM_ref, f):

  print("API: Running model...")

  x = conv_block(model_in, 1, 2, "conv2d", SM_ref, f)
  x = conv_block(x,  1, 1, "dwsconv2d", SM_ref, f)
  x = conv_block(x,  2, 2, "dwsconv2d", SM_ref, f)
  x = conv_block(x,  3, 1, "dwsconv2d", SM_ref, f)
  x = conv_block(x,  4, 2, "dwsconv2d", SM_ref, f)
  x = conv_block(x,  5, 1, "dwsconv2d", SM_ref, f)
  x = conv_block(x,  6, 2, "dwsconv2d", SM_ref, f)
  x = conv_block(x,  7, 1, "dwsconv2d", SM_ref, f)
  x = conv_block(x,  8, 1, "dwsconv2d", SM_ref, f)
  x = conv_block(x,  9, 1, "dwsconv2d", SM_ref, f)
  x = conv_block(x, 10, 1, "dwsconv2d", SM_ref, f)
  x = conv_block(x, 11, 1, "dwsconv2d", SM_ref, f)
  x = conv_block(x, 12, 2, "dwsconv2d", SM_ref, f)
  x = conv_block(x, 13, 1, "dwsconv2d", SM_ref, f)
  x = np.apply_over_axes(np.mean, x, [1,2])
  x = conv_block(x,  1, 1, "conv_preds", SM_ref, f)
  x = np.reshape(x, [1,12])
  
  model_out = softmax(x)

  return model_out

# Compose the MobileNetV1 blocks as seen in the paper 
# https://arxiv.org/pdf/1704.04861.pdf page 4 fig 3
def conv_block(input, block_id, stride, block_type, SM_ref, f):

  if block_type=="conv2d":
    
    [kernel, beta, gamma, mean, var] = get_weights("conv%i"%block_id, False, f)
    [conv2d_out, out_height, out_width] = conv2d(input, kernel, "SAME", stride, False, SM_ref)
    conv_blk_out = relu(batchnorm(conv2d_out, mean, var, gamma, beta))

  elif block_type=="dwsconv2d":
    ### DW ###
    [kernel, beta, gamma, mean, var] = get_weights("conv_dw_%i"%block_id, True, f)
    
    if stride!=1:
      input = zero_pad(input)

    [conv2d_out, out_height, out_width] = conv2d(input, kernel,  "SAME" if stride == 1 else "VALID", stride, True, SM_ref)
    DW_out = relu(batchnorm(conv2d_out, mean, var, gamma, beta))

    ### PW ###
    [kernel, beta, gamma, mean, var] = get_weights("conv_pw_%i"%block_id, False, f)
    [conv2d_out, out_height, out_width] = conv2d(DW_out, kernel, "VALID", 1, False, SM_ref)
    conv_blk_out = relu(batchnorm(conv2d_out, mean, var, gamma, beta))

  elif block_type=="conv_preds":
    [kernel, bias] = get_weights(block_type, False, f)
    [conv2d_out, out_height, out_width] = conv2d(input, kernel, "VALID", stride, False, SM_ref)
    conv_blk_out = np.add(conv2d_out, bias)

  return conv_blk_out

# Conv2D main
def conv2d(input, kernel, padding, stride, dwconv2d, SM_ref):
  
  # Pad input accordingly
  [input_padded, out_height, out_width] = pad(input, kernel.shape, padding, stride)

  # Divide matrices
  [ker_mat, inp_mat] = conv2d_parallel_reshape(input_padded, kernel, [out_height, out_width], stride)

  # Call fctrl & append its output
  fctrl_mstr_out = fctrl_master(ker_mat, inp_mat, kernel.shape[2], SM_ref)

  if dwconv2d == True:
    fctrl_mstr_out = fctrl_mstr_out.T.reshape(1,out_height,out_width,input.shape[3])

  else:
    fctrl_mstr_out = np.sum(fctrl_mstr_out, axis=0)
    fctrl_mstr_out = fctrl_mstr_out.T.reshape(1,out_height,out_width,kernel.shape[3])

  conv2d_out = fctrl_mstr_out

  return conv2d_out, out_height, out_width

# Reshapes input into parallelised vectorized form
# Example https://docs.google.com/presentation/d/1BcPF5Ji_Xbrj3f8amATA8ELkaGIo4yf4hWRJ72eMCKQ/edit#slide=id.gdc4fae8ca3_0_30
def conv2d_parallel_reshape(input, kernel, output_shape, stride):

  [ker_height, ker_width, in_channels, out_channels] = kernel.shape
  [out_height, out_width] = output_shape

  inp_mat = input_reshape(input, kernel.shape, [out_height, out_width], stride)
  ker_mat = kernel_reshape(kernel)

  return ker_mat, inp_mat

# fctrl main
def fctrl_master(ker_mat, inp_mat, in_channels, SM_ref):
  
  ker_mat = ker_mat.round(2)
  inp_mat = inp_mat.round(2)

  fctrl_outs = []
  for i in range(ker_mat.shape[0]):
    temp_ker_mat = mat_index(i, ker_mat)
    temp_inp_mat = mat_index(i, inp_mat)

    ker_row = temp_ker_mat.shape[0]
    ker_col = temp_ker_mat.shape[1]

    inp_row = temp_inp_mat.shape[0]
    inp_col = temp_inp_mat.shape[1]

    # Calling a C function
    temp = fctrl(temp_ker_mat, temp_inp_mat, ker_row, ker_col, inp_row, inp_col, SM_ref)
    fctrl_outs.append(temp)

  fctrl_mstr_out = np.asarray(fctrl_outs, dtype=np.float16)
  fctrl_mstr_out = fctrl_mstr_out.round(2)

  return fctrl_mstr_out

# C Function
# Link between System & FPGA
def fctrl(temp_ker_mat, temp_inp_mat, ker_row, ker_col, inp_row, inp_col, SM_ref):

  # Write temp_ker_mat, temp_inp_mat, ker_row, ker_col, inp_row, inp_col
  SM_ref[0] = temp_ker_mat
  SM_ref[1] = temp_inp_mat
  SM_ref[2] = ker_row
  SM_ref[3] = ker_col
  SM_ref[4] = inp_row
  SM_ref[5] = inp_col

  # Loop & send ker values

  # Loop & send inp values

  # Write FPGA_start
  SM_ref[6] = 1

  # Read FPGA_fin
  while SM_ref[8] == 0:
    time.sleep(0.000001)

  # Write FPGA_fin
  SM_ref[8] = 0

  # Read FPGA_out
  FPGA_out = SM_ref[7]
  fctrl_out = FPGA_out

  return fctrl_out

# FPGA emulation
def fpga(SM_ref):

  # Simulating FPGA clock
  while 1:
    time.sleep(0.000001)
    
    # Read FPGA_start
    if SM_ref[6] == 0:
      continue

    # Write FPGA_start
    SM_ref[6] = 0

    # Read temp_ker_mat, temp_inp_mat, ker_row, ker_col, inp_row, inp_col
    FPGA_out = mat_mult(SM_ref[0], SM_ref[1], SM_ref[2], SM_ref[3], SM_ref[4], SM_ref[5])

    # Write FPGA_out
    SM_ref[7] = FPGA_out

    # Write FPGA_fin
    SM_ref[8] = 1
