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

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

# Inception-v4: https://arxiv.org/abs/1602.07261

# Thanks to https://github.com/joelouismarino
# for providing examples of how network architectures map to Keras layers
# https://gist.github.com/joelouismarino/a2ede9ab3928f999575423b9887abd14

preprocessing = keras.Sequential(
    [
        layers.experimental.preprocessing.RandomFlip("horizontal"),
        layers.experimental.preprocessing.RandomRotation(0.1),
        layers.experimental.preprocessing.RandomContrast(0.1),
        layers.experimental.preprocessing.RandomZoom(0.1),
        layers.experimental.preprocessing.Rescaling(scale=1./127.5, offset=-1)
    ]
)

# See Table 1 on page 8 for k, l, m, n
# Configured for Inception-v4
k = 192
l = 224
m = 256
n = 384

def append_stem(input):
    x = layers.Conv2D(32, 3, strides=2, activation="relu")(input)
    x = layers.BatchNormalization()(x)
    x = layers.Conv2D(32, 3, activation="relu")(x)
    x = layers.BatchNormalization()(x)
    x = layers.Conv2D(64, 3, padding="same", activation="relu")(x)
    x = layers.BatchNormalization()(x)
    x1 = layers.MaxPool2D(3, strides=2)(x)
    x2 = layers.Conv2D(96, 3, strides=2, activation="relu")(x)
    x2 = layers.BatchNormalization()(x2)
    x = layers.Concatenate()([x1, x2])
    x1 = layers.Conv2D(64, 1, padding="same", activation="relu")(x)
    x1 = layers.BatchNormalization()(x1)
    x1 = layers.Conv2D(96, 3, activation="relu")(x1)
    x1 = layers.BatchNormalization()(x1)
    x2 = layers.Conv2D(64, 1, padding="same", activation="relu")(x)
    x2 = layers.BatchNormalization()(x2)
    x2 = layers.Conv2D(64, [7, 1], padding="same", activation="relu")(x2)
    x2 = layers.BatchNormalization()(x2)
    x2 = layers.Conv2D(64, [1, 7], padding="same", activation="relu")(x2)
    x2 = layers.BatchNormalization()(x2)
    x2 = layers.Conv2D(96, 3, activation="relu")(x2)
    x2 = layers.BatchNormalization()(x2)
    x = layers.Concatenate()([x1, x2])
                                                                 # NOTE: The Inception v4 paper has typos at the (top) end of the stem in Figure 3
    x1 = layers.Conv2D(192, 3, strides=2, activation="relu")(x)  # The "3x3 Conv (192 V)" layer should be "3x3 Conv (192 stride 2 V)"
    x1 = layers.BatchNormalization()(x1)
    x2 = layers.MaxPool2D(3, strides=2)(x)                       # and the "MaxPool (stride=2 V)" should be "3x3 MaxPool (stride 2 V)"
    return layers.Concatenate()([x1, x2])                        # because otherwise, the dimensions will be wrong for this filter concatenation


def append_inception_a_block(input):
    # Ambiguity... no dimensions given in the paper for average pools, but 3x3 seems reasonable.
    # Dimensions don't work with stride > 1, so set stride to 1 explicitly
    x1 = layers.AvgPool2D(3, strides=1, padding="same")(input)
    x1 = layers.Conv2D(96, 1, padding="same", activation="relu")(x1)
    x1 = layers.BatchNormalization()(x1)
    x2 = layers.Conv2D(96, 1, padding="same", activation="relu")(input)
    x2 = layers.BatchNormalization()(x2)
    x3 = layers.Conv2D(64, 1, padding="same", activation="relu")(input)
    x3 = layers.BatchNormalization()(x3)
    x3 = layers.Conv2D(96, 3, padding="same", activation="relu")(x3)
    x3 = layers.BatchNormalization()(x3)
    x4 = layers.Conv2D(64, 1, padding="same", activation="relu")(input)
    x4 = layers.BatchNormalization()(x4)
    x4 = layers.Conv2D(96, 3, padding="same", activation="relu")(x4)
    x4 = layers.BatchNormalization()(x4)
    x4 = layers.Conv2D(96, 3, padding="same", activation="relu")(x4)
    x4 = layers.BatchNormalization()(x4)
    return layers.Concatenate()([x1, x2, x3, x4])

def append_reduction_a_block(input):
    x1 = layers.MaxPool2D(3, strides=2)(input)
    x2 = layers.Conv2D(n, 3, strides=2, activation="relu")(input)
    x2 = layers.BatchNormalization()(x2)
    x3 = layers.Conv2D(k, 1, padding="same", activation="relu")(input)
    x3 = layers.BatchNormalization()(x3)
    x3 = layers.Conv2D(l, 3, padding="same", activation="relu")(x3)
    x3 = layers.BatchNormalization()(x3)
    x3 = layers.Conv2D(m, 3, strides=2, activation="relu")(x3)
    x3 = layers.BatchNormalization()(x3)
    return layers.Concatenate()([x1, x2, x3])

def append_inception_b_block(input):
    x1 = layers.AvgPool2D(3, strides=1, padding="same")(input)
    x1 = layers.Conv2D(128, 1, padding="same", activation="relu")(x1)
    x1 = layers.BatchNormalization()(x1)
    x2 = layers.Conv2D(384, 1, padding="same", activation="relu")(input)
    x2 = layers.BatchNormalization()(x2)
    x3 = layers.Conv2D(192, 1, padding="same", activation="relu")(input)
    x3 = layers.BatchNormalization()(x3)
    x3 = layers.Conv2D(224, [1, 7], padding="same", activation="relu")(x3)
    x3 = layers.BatchNormalization()(x3)
    x3 = layers.Conv2D(256, [1, 7], padding="same", activation="relu")(x3)
    x3 = layers.BatchNormalization()(x3)
    x4 = layers.Conv2D(192, 1, padding="same", activation="relu")(input)
    x4 = layers.BatchNormalization()(x4)
    x4 = layers.Conv2D(192, [1, 7], padding="same", activation="relu")(x4)
    x4 = layers.BatchNormalization()(x4)
    x4 = layers.Conv2D(224, [7, 1], padding="same", activation="relu")(x4)
    x4 = layers.BatchNormalization()(x4)
    x4 = layers.Conv2D(224, [1, 7], padding="same", activation="relu")(x4)
    x4 = layers.BatchNormalization()(x4)
    x4 = layers.Conv2D(256, [7, 1], padding="same", activation="relu")(x4)
    x4 = layers.BatchNormalization()(x4)
    return layers.Concatenate()([x1, x2, x3, x4])

def append_reduction_b_block(input):
    x1 = layers.MaxPool2D(3, strides=2)(input)
    x2 = layers.Conv2D(192, 1, padding="same", activation="relu")(input)
    x2 = layers.BatchNormalization()(x2)
    x2 = layers.Conv2D(192, 3, strides=2, activation="relu")(x2)
    x2 = layers.BatchNormalization()(x2)
    x3 = layers.Conv2D(256, 1, padding="same", activation="relu")(input)
    x3 = layers.BatchNormalization()(x3)
    x3 = layers.Conv2D(256, [1, 7], padding="same", activation="relu")(x3)
    x3 = layers.BatchNormalization()(x3)
    x3 = layers.Conv2D(320, [7, 1], padding="same", activation="relu")(x3)
    x3 = layers.BatchNormalization()(x3)
    x3 = layers.Conv2D(320, 3, strides=2, activation="relu")(x3)
    x3 = layers.BatchNormalization()(x3)
    return layers.Concatenate()([x1, x2, x3])

def append_inception_c_block(input):
    x1 = layers.AvgPool2D(3, strides=1, padding="same")(input)
    x1 = layers.Conv2D(256, 1, padding="same", activation="relu")(x1)
    x1 = layers.BatchNormalization()(x1)
    x2 = layers.Conv2D(256, 1, padding="same", activation="relu")(input)
    x2 = layers.BatchNormalization()(x2)
    x3 = layers.Conv2D(384, 1, padding="same", activation="relu")(input)
    x3 = layers.BatchNormalization()(x3)
    x31 = layers.Conv2D(256, [1, 3], padding="same", activation="relu")(x3)
    x31 = layers.BatchNormalization()(x31)
    x32 = layers.Conv2D(256, [3, 1], padding="same", activation="relu")(x3)
    x32 = layers.BatchNormalization()(x32)
    x4 = layers.Conv2D(384, 1, padding="same", activation="relu")(input)
    x4 = layers.BatchNormalization()(x4)
    x4 = layers.Conv2D(448, [1, 3], padding="same", activation="relu")(x4)
    x4 = layers.BatchNormalization()(x4)
    x4 = layers.Conv2D(512, [3, 1], padding="same", activation="relu")(x4)
    x4 = layers.BatchNormalization()(x4)
    x41 = layers.Conv2D(256, [3, 1], padding="same", activation="relu")(x4)
    x41 = layers.BatchNormalization()(x41)
    x42 = layers.Conv2D(256, [1, 3], padding="same", activation="relu")(x4)
    x42 = layers.BatchNormalization()(x42)
    return layers.Concatenate()([x1, x2, x31, x32, x41, x42])
 
def make_model(input_shape, num_classes):
    inputs = keras.Input(shape=input_shape)

    x = preprocessing(inputs)

    x = append_stem(x)

    x = append_inception_a_block(x)
    x = append_inception_a_block(x)
    x = append_inception_a_block(x)
    x = append_inception_a_block(x)

    x = append_reduction_a_block(x)

    x = append_inception_b_block(x)
    x = append_inception_b_block(x)
    x = append_inception_b_block(x)
    x = append_inception_b_block(x)
    x = append_inception_b_block(x)
    x = append_inception_b_block(x)
    x = append_inception_b_block(x)

    x = append_reduction_b_block(x)

    x = append_inception_c_block(x)
    x = append_inception_c_block(x)
    x = append_inception_c_block(x)

    x = layers.GlobalAveragePooling2D()(x)    
    x = layers.Dropout(0.2)(x)
    outputs = layers.Dense(num_classes, activation="softmax")(x)
    return keras.Model(inputs, outputs)
