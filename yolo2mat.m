% form data from YOLO face.po and gazeData.txt to data_yolo.mats

face = importdata('face.po');
gaze = importdata('gazeData.txt');
dir = 'jpg\';
width = 1920;
height = 1080;
faceData = zeros(100, 200, 200, 3);
eyeTrackData = zeros(100, 4);
for i = 0 : 99
    fileName = sprintf('%s%d.jpg', dir, i);
    disp(fileName);
    imageSrc = imread(fileName);
    
    xc = face(i + 1, 2) * width;
    yc = face(i + 1, 3) * height;
    hfh = floor(face(i + 1, 4) * width / 2);
    hfw = floor(face(i + 1, 5) * height / 2);
    
    faceSrc = imageSrc(yc + hfh - 2 * hfw : yc + hfh, xc - hfw : xc + hfw, :);
    image = imresize(faceSrc, [200 200]);
    faceData(i + 1, :, :, :) = image;
    eyeTrackData(i + 1, :) = gaze(i + 1, 2 : 5);
    
    imshow(image);
    pause(0.1);
end
file = 'data_yolo.mat';
save(file, 'eyeTrackData', 'faceData', '-v7.3');
