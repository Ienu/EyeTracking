import numpy as np
import scipy.io as sio
import h5py
import sys
import keras
from keras.models import Sequential
from keras.layers import Dense, Dropout, Activation, Flatten
from keras.layers import Conv2D, MaxPooling2D, Merge

from sklearn.model_selection import KFold

import os

# this is for k-folder cross validation
seed = 7
np.random.seed(seed)

# init
batch_size = 32
num_classes = 4
epochs = 30

# data load and preprocess
f = h5py.File(sys.argv[1])

x_im = np.array(f['faceData'])
x_fe = np.array(f['features'])
y = np.array(f['eyeTrackData'])

x_im = np.transpose(x_im, (3, 2, 1, 0))
x_fe = np.transpose(x_fe, (1, 0))
y = np.transpose(y, (1, 0))

print('x_im shape: ', x_im.shape)
print('x_fe shape: ', x_fe.shape)
print('y shape: ', y.shape)

# model

# model image2gaze
model_im2g = Sequential()

model_im2g.add(Conv2D(32, (3, 3), input_shape=x_im.shape[1:]))
model_im2g.add(Activation('relu'))
model_im2g.add(MaxPooling2D(pool_size=(2,2)))
model_im2g.add(Dropout(0.25))

model_im2g.add(Conv2D(32, (3, 3)))
model_im2g.add(Activation('relu'))
model_im2g.add(MaxPooling2D(pool_size=(2, 2)))
model_im2g.add(Dropout(0.25))

model_im2g.add(Flatten())
model_im2g.add(Dense(128))

model_im2g.summary()

# model features2gaze
model_fe2g = Sequential()

model_fe2g.add(Dense(128, input_dim=x_fe.shape[1]))
model_fe2g.add(Activation('relu'))
model_fe2g.add(Dropout(0.25))

model_fe2g.summary()

# merge model
model_merge = Sequential()

model_merge.add(Merge([model_im2g, model_fe2g], mode='concat'))

model_merge.add(Dense(64))
model_merge.add(Activation('relu'))
model_merge.add(Dropout(0.25))

model_merge.add(Dense(16))
model_merge.add(Activation('relu'))
model_merge.add(Dropout(0.25))

model_merge.add(Dense(num_classes))

model_merge.summary()

# train
opt = keras.optimizers.rmsprop(lr=0.001, decay=1e-6)
model_merge.compile(loss='mse', optimizer=opt, metrics=['accuracy'])

x_im = x_im.astype('float32')
x_im /= 255
x_fe = x_fe.astype('float32')
y = y.astype('float32')

# k-folder cross validation
kf = KFold(n_splits=10)
cvscores = []
for train, test in kf.split(x_im, x_fe, y):
    model_merge.fit([x_im[train], x_fe[train]], y[train],
          batch_size=batch_size,
          epochs=epochs,
          verbose=1,
          shuffle=True)
    scores = model_merge.evaluate([x_im[test], x_fe[test]], y[test], verbose=0)
    print('Test loss:', scores[0], scores[1])
    cvscores.append(scores[0])

print('Mean loss:', np.mean(cvscores))
for i in range(0, 10):
    print(cvscores[i])
