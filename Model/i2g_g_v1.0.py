import numpy as np
import scipy.io as sio
import h5py
import sys
import keras
from keras.models import Sequential
from keras.layers import Dense, Dropout, Activation, Flatten
from keras.layers import Conv2D, MaxPooling2D

from sklearn.model_selection import StratifiedKFold
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
print(sys.argv[1])
f = h5py.File(sys.argv[1])

x = np.array(f['faceData'])
y = np.array(f['eyeTrackData'])

x = np.transpose(x, (3, 2, 1, 0))
y = np.transpose(y, (1, 0))

print('x shape: ', x.shape)
print('y shape: ', y.shape)

# model
model = Sequential()

model.add(Conv2D(32, (3, 3), input_shape=x.shape[1:]))
model.add(Activation('relu'))
model.add(MaxPooling2D(pool_size=(2,2)))
model.add(Dropout(0.25))

model.add(Conv2D(32, (3, 3)))
model.add(Activation('relu'))
model.add(MaxPooling2D(pool_size=(2, 2)))
model.add(Dropout(0.25))

model.add(Flatten())

model.add(Dense(128))
model.add(Activation('relu'))
model.add(Dropout(0.25))

model.add(Dense(32))
model.add(Activation('relu'))
model.add(Dropout(0.25))

model.add(Dense(num_classes))

model.summary()

# train
opt = keras.optimizers.rmsprop(lr=0.001, decay=1e-6)
model.compile(loss='mse', optimizer=opt, metrics=['accuracy'])

x = x.astype('float32')
x /= 255
y = y.astype('float32')

# k-folder cross validation
kf = KFold(n_splits=10)
cvscores = []
for train, test in kf.split(x, y):
    model.fit(x[train], y[train],
          batch_size=batch_size,
          epochs=epochs,
          verbose=1,
          shuffle=True)
    scores = model.evaluate(x[test], y[test], verbose=0)
    print('Test loss:', scores[0], scores[1])
    cvscores.append(scores[0])

print('Mean loss:', np.mean(cvscores))
for i in range(0, 10):
    print(cvscores[i])
