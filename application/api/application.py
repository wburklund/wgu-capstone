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
import io
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras.preprocessing import image
from PIL import Image
import flask
from flask import Flask
import boto3

model = None

def has_pneumonia(image_data):
    im = Image.open(io.BytesIO(image_data))
    im = im.convert('RGB')
    im = im.resize((299, 299), Image.NEAREST)
    im = image.img_to_array(im)
    im = np.expand_dims(im, axis=0)

    prediction = model.predict(im, batch_size=1)[0]
    return prediction[1] > 0.5

app = Flask(__name__)

# Refresh deep learning model
@app.route('/refresh', methods=["PUT"])
def refresh():
    s3 = boto3.client('s3')
    s3.download_file('capstone-api-assets', 'model.h5', 'model.h5')
    model = keras.models.load_model('model.h5')
    return "Success"

# Detect pneumonia in a given chest X-ray image
# This endpoint expects the body to be binary image data
@app.route('/predict', methods=["GET"])
def predict():
    image_data = flask.request.get_data()
    if has_pneumonia(image_data):
        return "Pneumonia"
    else:
        return "Normal"

refresh()
app.run()