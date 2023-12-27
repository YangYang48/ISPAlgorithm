import numpy as np
import matplotlib.pyplot as plt

path = '../images/SSC_ispout_long_3840x2160_16_GB_0815103416_[US=16666,AG=1193,DG=1024,R=2231,G=1024,B=2465].yuv'

height = 2160
width = 3840  

YUV = np.fromfile(path, dtype='uint8')
Y = YUV[::2]
Y = Y.reshape(height, width)

plt.figure()
plt.imshow(Y, cmap='gray')
plt.title('Y of YUV')
plt.show()
