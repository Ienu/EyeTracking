% face++ to mat file 
% each path needs to be modified
% varaible amount needs to be modified
% save name needs to be modified

dir = 'C:\Users\workspace\Documents\Visual Studio 2015\Projects\FaceppApp\FaceppApp\FaceData6';
width = 4096;
height = 2160;

amount = 11976;

fsrc = importdata('C:\\Users\\workspace\\Documents\\Visual Studio 2015\\Projects\\FaceppApp\\FaceppApp\\features6.txt');
demo = load('C:\\Users\\workspace\\Documents\\Visual Studio 2015\\Projects\\FaceppApp\\FaceppApp\\demo_qn_2m.mat');

features = zeros(amount, size(fsrc, 2));
faceData = zeros(amount, 112, 112, 3);
eyeTrackData = zeros(amount, 4);

idx = 1;

for i = 0 : amount - 1
    disp(i);
    f = fsrc(i + 1, :);
    
    if f(1) == 0
        continue;
    end
    
    for j = 1 : 97
        f(j * 2 - 1) = f(j * 2 - 1) / height;
        f(j * 2) = f(j * 2) / width;
    end
    f(208) = f(208) / width;
    f(209) = f(209) / height;
    
    f(210) = f(210) / 320;
    f(211) = f(211) / 320;
    
    filename = sprintf('%s\\face%d.bmp', dir, i);
    disp(filename);
    imageSrc = imread(filename);
    image = imresize(imageSrc, [112 112]);
    imshow(image);
    
    features(idx, :) = f;
    faceData(idx, :, :, :) = image;
    eyeTrackData(idx, :) = demo.eyeTrackData(i + 1, :);
    idx = idx + 1;
    if idx > amount - 1
        break;
    end
end

save('data_facepp_qn_2m.mat', 'faceData', 'features', 'eyeTrackData', '-v7.3');
