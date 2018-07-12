import numpy as np
import cv2

cap = cv2.VideoCapture(0)

cap.set(5, 30)
cap.set(15, -5)
cap.set(3, 4096)
cap.set(4, 3072)


while(True):
    ret, frame = cap.read()
    f = cv2.resize(frame, (4096 / 4, 2160 / 4))
    cv2.imshow('frame', f)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        cv2.imwrite('demo.jpg', frame)
        break

cap.release()
cv2.destroyAllWindows()
