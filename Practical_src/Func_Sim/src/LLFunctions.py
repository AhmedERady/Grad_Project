import numpy as np
import h5py
import image_utils as image

# Get patches for vectorization & reshape for parallelisation
def input_reshape(input, kernel_shape, output_shape, stride):

  [inp_batch, inp_height, inp_width, in_channels] = input.shape
  [ker_height, ker_width, in_channels, out_channels] = kernel_shape
  [out_height, out_width] = output_shape

  patches = []
  for i in range(inp_batch):
    
    for h in range(out_height):
      vert_start = stride * h
      vert_end = vert_start + ker_height

      for w in range(out_width):
        horiz_start = stride * w
        horiz_end = horiz_start + ker_width

        for c in range(in_channels):
            patch = input[i, vert_start:vert_end, horiz_start:horiz_end, c]
            patches.append(patch)

  # Can be improved
  inp_mat = np.asarray(patches, dtype=np.float16).flatten().reshape([out_height*out_width, ker_height*ker_width*in_channels]).T
  inp_mat = inp_mat.reshape([in_channels, ker_height*ker_width, out_height*out_width])

  return inp_mat

# Reshape for parallelisation
def kernel_reshape(kernel):

  [ker_height, ker_width, in_channels, out_channels] = kernel.shape

  kernels = []
  for i in range(in_channels):
    for j in range(out_channels):
      kernels.append(kernel[:,:,i,j].flatten())

  ker_mat = np.asarray(kernels, dtype=np.float16)
  ker_mat = ker_mat.reshape(in_channels,out_channels,ker_height*ker_width)

  return ker_mat

def load_img(path):

  img = image.load_img(path, target_size=(128, 128))
  img = image.img_to_array(img)
  img = np.expand_dims(img, axis=0)
  img = img/255
  
  return img

def load_file(path, mode):
  return h5py.File(path, mode)

def pad(input, kernel_shape, padding, stride):

  [inp_batch, inp_height, inp_width, in_channels] = input.shape
  [ker_height, ker_width, in_channels, out_channels] = kernel_shape

  if padding=="VALID":
    out_height = int(np.floor((inp_height - ker_height + 2*0)/stride)+1)
    out_width = int(np.floor((inp_width - ker_width + 2*0)/stride)+1)
    input_pad = input

  if padding=="SAME":
    out_height = int(np.ceil(inp_height / stride))
    out_width = int(np.ceil(inp_width / stride))

    if inp_height % stride == 0:
        pad_along_height = max((ker_height - stride), 0)
    else:
        pad_along_height = max(ker_height - (inp_height % stride), 0)

    if inp_width % stride == 0:
        pad_along_width = max((ker_width - stride), 0)
    else:
        pad_along_width = max(ker_width - (inp_width % stride), 0)

    pad_top = pad_along_height // 2
    pad_bottom = pad_along_height - pad_top
    pad_left = pad_along_width // 2
    pad_right = pad_along_width - pad_left

    input_pad = np.zeros((inp_batch, inp_height + pad_along_height, inp_width + pad_along_width, in_channels))
    input_pad[0,pad_top:-pad_bottom, pad_left:-pad_right, :] = input

  return input_pad, out_height, out_width

# VHDL code emulation
def mat_mult(temp_ker_mat, temp_inp_mat, ker_row, ker_col, inp_row, inp_col):

  output = np.zeros([ker_row, inp_col])

  for i in range(ker_row):
    for j in range(inp_col):
      for x in range(ker_col):
        output[i][j] += (temp_ker_mat[i][x] * temp_inp_mat[x][j])

  return output

# Gets 3D returns 2D
def mat_index(i, m):
  
  m = m[i,:,:]

  return m

# Get weights that are already loaded in memory
def get_weights(name, dw_load, f):

  if dw_load == True:
    fl = name + "/"+ name + "/depthwise_kernel:0"
  
  elif name == "conv_preds":
    fl = name + "/"+ name + "/kernel:0"
    kernel = f.get(fl)[()]
    fl = name + "/"+ name + "/bias:0"
    bias = f.get(fl)[()]

    return kernel, bias

  else:
    fl = name + "/"+ name + "/kernel:0"

  kernel = f.get(fl)[()]
  fl = name + "_bn/"+ name + "_bn/beta:0"
  beta = f.get(fl)[()]
  fl = name + "_bn/"+ name + "_bn/gamma:0"
  gamma = f.get(fl)[()]
  fl = name + "_bn/"+ name + "_bn/moving_mean:0"
  mean = f.get(fl)[()]
  fl = name + "_bn/"+ name + "_bn/moving_variance:0"
  var = f.get(fl)[()]

  return kernel, beta, gamma, mean, var

def batchnorm(input, moving_mean, moving_var, gamma, beta):
  return (input - moving_mean) / np.sqrt(moving_var + 0.001) * gamma + beta

def relu(input):
  return np.minimum(np.maximum(input, 0), 6)

def softmax(logits):
  return np.exp(logits) / np.sum(np.exp(logits), -1)

def zero_pad(input):
    return np.pad(input, ((0,0), (0,1), (0,1), (0,0)), mode='constant', constant_values = (0,0))

def display(pred):

  li = ['Apple___Apple_scab', 'Apple___Black_rot', 'Apple___Cedar_apple_rust', 'Apple___healthy', 'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot', 'Corn_(maize)___Common_rust_', 'Corn_(maize)___Northern_Leaf_Blight', 'Corn_(maize)___healthy', 'Tomato___Early_blight', 'Tomato___Tomato_Yellow_Leaf_Curl_Virus', 'Tomato___Tomato_mosaic_virus', 'Tomato___healthy']

  d = pred.flatten()
  j = d.max()
  for index,item in enumerate(d):
      if item == j:
          class_name = li[index]

  print("Following is the prediction: ")
  print(class_name,":",j,"%\n")

  return