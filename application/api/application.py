#
#  WGU Capstone Project
#  Copyright (C) 2021 Will Burklund
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Affero General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Affero General Public License for more details.
#
#  You should have received a copy of the GNU Affero General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

import os
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras.preprocessing import image
from PIL import Image

image_size = (299, 299)

input_dir = os.environ['INPUT_DIR']

model = keras.models.load_model('model.h5')

test_dir = os.listdir(f'{input_dir}/Coronahack-Chest-XRay-Dataset/Coronahack-Chest-XRay-Dataset/test/')
image_name = sorted(test_dir)[0]

path = f'{input_dir}/Coronahack-Chest-XRay-Dataset/Coronahack-Chest-XRay-Dataset/test/{image_name}'
im = Image.open(path)
im = im.convert('RGB')
im = im.resize(image_size, Image.NEAREST)
im = image.img_to_array(im)
im = np.expand_dims(im, axis=0)

prediction = model.predict(im, batch_size=1)[0]
has_pneumonia = prediction[1] > 0.5
