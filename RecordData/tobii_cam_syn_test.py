import tobii_research as tr
import numpy as np
import scipy.io as sio
import time
import cv2

found_eyetrackers = tr.find_all_eyetrackers()

my_eyetracker = found_eyetrackers[0]

print("Address: " + my_eyetracker.address)
print("Model: " + my_eyetracker.model)
print("Name (It's OK if this is empty): " + my_eyetracker.device_name)
print("Serial number: " + my_eyetracker.serial_number)

cap = cv2.VideoCapture(0)

cap.set(5, 30)
cap.set(15, -5)
cap.set(3, 4096)
cap.set(4, 3072)#2160

gd = {}

index = 0
vEyeTracker = np.zeros([1, 4], float)

def gaze_data_call_back(gaze_data):
    global gd
    gd = gaze_data

my_eyetracker.subscribe_to(tr.EYETRACKER_GAZE_DATA, gaze_data_call_back, as_dictionary=True)

while(True):
    ret, frame = cap.read()
    cv2.imshow('frame', frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        sio.savemat('demo.mat', {'eyeTrackData':vEyeTracker})
        break

    dl = gd['left_gaze_point_on_display_area']
    dr = gd['right_gaze_point_on_display_area']
    
    if np.isnan(dl[0]) or np.isnan(dl[1]) or np.isnan(dr[0]) or np.isnan(dr[1]):
        continue

    data = [dl[0], dl[1], dr[0], dr[1]]
    print(index, data)
    vEyeTracker = np.vstack((vEyeTracker, data))
    cv2.imwrite('ImageData/frame%d.bmp'%index, frame)
    #print(index)
    index = index + 1

my_eyetracker.unsubscribe_from(tr.EYETRACKER_GAZE_DATA, gaze_data_call_back)

cap.release()
cv2.destroyAllWindows()
