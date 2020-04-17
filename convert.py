from PIL import Image
import numpy as np


ON_COLOR = "1"
OFF_COLOR = "0"


IMG_SIZE = 16


command = ""
for frame in range(0, 5259):
    img = Image.open("output/{0}.png".format(str(frame).zfill(5)))

    img = img.resize((IMG_SIZE, IMG_SIZE))
    img = img.convert("L")
    
    # img.show()
    img_arr = np.array(img.getdata())
    img_arr = img_arr.reshape((IMG_SIZE, IMG_SIZE))
    img_arr = img_arr // 128
    for row in range(0, IMG_SIZE):
        byte = 0

        for col in range(0, IMG_SIZE):
            byte += (img_arr[row, -col-1]) << (col)
            
        command += hex(byte)[2:].zfill(4)
        if row % 2 == 1:
            command += "\n"
        
        
    
with open("DMEM", "w") as f:
    f.write("v2.0 raw\n")
    f.write(command)


