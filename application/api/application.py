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
import json
from collections import Counter
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras.preprocessing import image
from PIL import Image
import flask
from flask import Flask, abort, request
import flask_cors
from flask_cors import cross_origin
import boto3

api_key = os.environ['API_KEY']

model_filename = 'model.h5'
model = None

def has_pneumonia(image_data):
    im = Image.open(io.BytesIO(image_data))
    im = im.convert('RGB')
    im = im.resize((299, 299), Image.NEAREST)
    im = image.img_to_array(im)
    im = np.expand_dims(im, axis=0)

    prediction = model.predict(im, batch_size=1)[0]
    return prediction[1] > 0.5

application = Flask(__name__)

# Refresh deep learning model
@application.route('/refresh', methods=['PUT'])
@cross_origin()
def refresh():
    if request.headers.get('X-API-KEY') != api_key:
        abort(403)

    _refresh()

    return 'Success'

def _refresh():
    global model
    model = None
    if os.path.exists(model_filename):
        os.remove(model_filename)

    s3 = boto3.client('s3')
    s3.download_file('capstone-api-assets', model_filename, model_filename)
    model = keras.models.load_model(model_filename)

# Detect pneumonia in a given chest X-ray image
# This endpoint expects the body to be binary image data
@application.route('/predict', methods=['POST'])
@cross_origin()
def predict():
    if request.headers.get('X-API-KEY') != api_key:
        abort(403)

    image_data = flask.request.get_data()
    if has_pneumonia(image_data):
        return 'Pneumonia'
    else:
        return 'Normal'

@application.route('/statistics', methods=['GET'])
@cross_origin()
def statistics():
    if request.headers.get('X-API-KEY') != api_key:
        abort(403)

    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('CapstoneMetadatabase')
    response = table.scan(
        ProjectionExpression = '#d, Cause',
        ExpressionAttributeNames = {'#d': 'Date'})

    data = response['Items']

    while 'LastEvaluatedKey' in response:
        response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
        data.extend(response['Items'])

    hashable_data = list(map(lambda x: x.get('Cause') + '_' + x.get('Date'), data))
    counted_data = list(Counter(hashable_data).items())
    output_data = list(map(lambda x: ({'Cause': x[0].split('_')[0], 'Date': x[0].split('_')[1]}, x[1]), counted_data))

    return json.dumps(output_data)

@application.route('/hello', methods=['GET'])
@cross_origin()
def hello():
    if request.headers.get('X-API-KEY') != api_key:
        abort(403)
    return 'Hello, world!'

_refresh()
application.run(host='0.0.0.0', port=80)
