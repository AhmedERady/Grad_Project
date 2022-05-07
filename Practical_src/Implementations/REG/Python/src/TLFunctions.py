from LLFunctions import *
import time
import os
from ctypes import *

def model(model_in):

  print("API: Running model...")
  x = conv_block(model_in, 1, 2, "conv2d")
  x = conv_block(x,  1, 1, "dwsconv2d")
  x = conv_block(x,  2, 2, "dwsconv2d")
  x = conv_block(x,  3, 1, "dwsconv2d")
  x = conv_block(x,  4, 2, "dwsconv2d")
  x = conv_block(x,  5, 1, "dwsconv2d")
  x = conv_block(x,  6, 2, "dwsconv2d")
  x = conv_block(x,  7, 1, "dwsconv2d")
  x = conv_block(x,  8, 1, "dwsconv2d")
  x = conv_block(x,  9, 1, "dwsconv2d")
  x = conv_block(x, 10, 1, "dwsconv2d")
  x = conv_block(x, 11, 1, "dwsconv2d")
  x = conv_block(x, 12, 2, "dwsconv2d")
  x = conv_block(x, 13, 1, "dwsconv2d")
  x = np.apply_over_axes(np.mean, x, [1,2])
  x = conv_block(x,  1, 1, "conv_preds")
  x = np.reshape(x, [1,12])
  
  model_out = softmax(x)

  return model_out

def conv_block(input, block_id, stride, block_type):

  if block_type=="conv2d":
    
    [kernel, beta, gamma, mean, var] = get_weights("conv%i"%block_id, False)
    [conv2d_out, out_height, out_width] = conv2d(input, kernel, "SAME", stride, False)
    conv_blk_out = relu(batchnorm(conv2d_out, mean, var, gamma, beta))

  elif block_type=="dwsconv2d":
    ### DW ###
    [kernel, beta, gamma, mean, var] = get_weights("conv_dw_%i"%block_id, True)
    
    if stride!=1:
      input = zero_pad(input)

    [conv2d_out, out_height, out_width] = conv2d(input, kernel,  "SAME" if stride == 1 else "VALID", stride, True)
    DW_out = relu(batchnorm(conv2d_out, mean, var, gamma, beta))

    ### PW ###
    [kernel, beta, gamma, mean, var] = get_weights("conv_pw_%i"%block_id, False)
    [conv2d_out, out_height, out_width] = conv2d(DW_out, kernel, "VALID", 1, False)
    conv_blk_out = relu(batchnorm(conv2d_out, mean, var, gamma, beta))

  elif block_type=="conv_preds":
    [kernel, bias] = get_weights(block_type, False)
    [conv2d_out, out_height, out_width] = conv2d(input, kernel, "VALID", stride, False)
    conv_blk_out = np.add(conv2d_out, bias)

  return conv_blk_out

# Conv2D main
def conv2d(input, kernel, padding, stride, dwconv2d):
  
  # Pad input accordingly
  [input_padded, out_height, out_width] = pad(input, kernel.shape, padding, stride)

  # Divide matrices
  [ker_mat, inp_mat] = conv2d_parallel_reshape(input_padded, kernel, [out_height, out_width], stride)

  # Send to fctrl to handle FPGA communication
  fctrl_mstr_out = fctrl_master(ker_mat, inp_mat)

  if dwconv2d == True:
    fctrl_mstr_out = fctrl_mstr_out.T.reshape(1,out_height,out_width,input.shape[3])

  else:
    fctrl_mstr_out = np.sum(fctrl_mstr_out, axis=0)
    fctrl_mstr_out = fctrl_mstr_out.T.reshape(1,out_height,out_width,kernel.shape[3])

  conv2d_out = fctrl_mstr_out

  return conv2d_out, out_height, out_width

def conv2d_parallel_reshape(input, kernel, output_shape, stride):

  [ker_height, ker_width, in_channels, out_channels] = kernel.shape
  [out_height, out_width] = output_shape

  inp_mat = input_reshape(input, kernel.shape, [out_height, out_width], stride)
  ker_mat = kernel_reshape(kernel)

  return ker_mat, inp_mat

# Transforms from 3D to 2D
def fctrl_master(ker_mat, inp_mat):

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

    temp = fctrl(temp_ker_mat, temp_inp_mat)
    fctrl_outs.append(temp)

  fctrl_mstr_out = np.asarray(fctrl_outs)
  fctrl_mstr_out = fctrl_mstr_out.round(2)

  return fctrl_mstr_out

# Transforms from 2D to 1D
def fctrl(temp_ker_mat, temp_inp_mat):

  ker_row = temp_ker_mat.shape[0]
  ker_col = temp_ker_mat.shape[1]
  inp_row = temp_inp_mat.shape[0]
  inp_col = temp_inp_mat.shape[1]

  # Fixed point
  temp_ker_mat = temp_ker_mat * 100
  temp_inp_mat = temp_inp_mat * 100

  output = []

  # Reset FPGA
  cLib.SM_write(MMul_master, s_wr, 0x0A)

  for i in range(ker_row):
    
    # Load ker_mat
    load_ker(temp_ker_mat[i,:])

    for j in range(inp_col):
      # Load inp_mat
      load_inp(temp_inp_mat[:,j])

      # Reset FPGA
      cLib.SM_write(MMul_master, s_wr, 0x0A)

      # Setup sizes
      cLib.SM_write(MMul_master, i_wr, 1)
      cLib.SM_write(MMul_master, j_wr, 1)
      cLib.SM_write(MMul_master, k_wr, ker_col)

      # Start mult
      cLib.SM_write(MMul_master, s_wr, 0x06)

      # Polling for finish
      while cLib.SM_uread(MMul_master, s_rd) != 0x08:
        continue

      # Unload out_mat
      output.append(unload_out())

  x = np.asarray(output)
  x = x.reshape([ker_row, inp_col])
  
  fctrl_out = x

  return fctrl_out

def load_ker(temp_ker_mat):

  # Set status
  cLib.SM_write(MMul_master, s_wr, 0x11)
  
  # Get sizes
  ker_col = temp_ker_mat.shape[0]

  # Load
  for j in range(ker_col):
    cLib.SM_write(MMul_master, i_wr, 0)
    cLib.SM_write(MMul_master, j_wr, j)
    cLib.SM_write(MMul_master, n_wr, int(temp_ker_mat[j]))

  return

def load_inp(temp_inp_mat):

  # Set status
  cLib.SM_write(MMul_master, s_wr, 0x21)

  # Get sizes
  inp_row = temp_inp_mat.shape[0]

  # Load
  for i in range(inp_row):
    cLib.SM_write(MMul_master, i_wr, i)
    cLib.SM_write(MMul_master, k_wr, 0)
    cLib.SM_write(MMul_master, n_wr, int(temp_inp_mat[i]))

  return

def unload_out():

  # Set status
  cLib.SM_write(MMul_master, s_wr, 0x48)

  # Unload 1x1
  cLib.SM_write(MMul_master, i_wr, 0)
  cLib.SM_write(MMul_master, k_wr, 0)

  h = cLib.SM_sread(MMul_master, k_rd)
  h = h<<16
  l = cLib.SM_uread(MMul_master, n_rd)
  t = h|l
  t = t/10000

  output = t

  return output

# __init__
# Hack: get clib ref here & now
path = os.path.join(os.path.dirname(__file__), "fctrl.so")
cLib = CDLL(path)

fd = cLib.open_driver()
lw_bus_map = cLib.LW_map(fd)
MMul_master = cLib.MMul_reference(lw_bus_map)

# Write offsets
i_wr = 0
j_wr = 1
k_wr = 2
n_wr = 3
s_wr = 4

# Read offsets
i_rd = 5
j_rd = 6
k_rd = 7
n_rd = 8
s_rd = 9
