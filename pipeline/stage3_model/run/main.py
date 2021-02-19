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

import csv
import os
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras.preprocessing import image
from make_model import make_model

input_dir = os.environ['INPUT_DIR']
output_dir = os.environ['OUTPUT_DIR']

image_size = (299, 299)
batch_size = 16
epochs = 20

train_ds = tf.keras.preprocessing.image_dataset_from_directory(
    f'{input_dir}/Train',
    validation_split=0.2,
    subset="training",
    seed=1337,
    image_size=image_size,
    batch_size=batch_size,
    label_mode="categorical"
)
val_ds = tf.keras.preprocessing.image_dataset_from_directory(
    f'{input_dir}/Train',
    validation_split=0.2,
    subset="validation",
    seed=1337,
    image_size=image_size,
    batch_size=batch_size,
    label_mode="categorical"
)

class_names = train_ds.class_names
num_classes = len(class_names)

train_ds = train_ds.prefetch(buffer_size=batch_size)
val_ds = val_ds.prefetch(buffer_size=batch_size)

model = make_model(input_shape=image_size + (3,), num_classes=num_classes)

callbacks = [
   # keras.callbacks.EarlyStopping(monitor='val_loss', mode='min', verbose=1, patience=5),
]
model.compile(
    optimizer=keras.optimizers.SGD(learning_rate=0.1, momentum=0.9),
    loss="categorical_crossentropy",
    metrics=["accuracy"],
)
history = model.fit(train_ds, epochs=epochs, callbacks=callbacks, validation_data=val_ds, verbose=2)

history_keys = list(history.history.keys())
history_len = len(history.epoch)
with open(f'{output_dir}/history.csv', mode='w', newline='') as history_file:
    history_writer = csv.writer(history_file)
    history_writer.writerow(history_keys)
    for i in range(history_len):
        hist_values = list(map(lambda key: history.history[key][i], history_keys))
        history_writer.writerow(hist_values)

test_dir = os.listdir(f'{input_dir}/Test/Unlabeled/')
(image_names, images) = ([], [])
for image_name in sorted(test_dir):
    path = f'{input_dir}/Test/Unlabeled/{image_name}'
    img = image.load_img(path, target_size=image_size)
    img = image.img_to_array(img)
    img = np.expand_dims(img, axis=0)
    image_names.append(image_name)
    images.append(img)

images = np.vstack(images)
predictions = model.predict(images, batch_size=batch_size)
with open(f'{output_dir}/predictions.csv', mode='w', newline='') as prediction_file:
    prediction_writer = csv.writer(prediction_file)
    prediction_writer.writerow(['ImageName'] + class_names)
    for i in range(len(predictions)):
        prediction_writer.writerow([image_names[i]] + predictions[i].tolist())

model.save(f'{output_dir}/model.h5')
