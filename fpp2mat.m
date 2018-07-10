dir = 'C:\Users\workspace\Documents\Visual Studio 2015\Projects\FaceppApp\FaceppApp\FaceData';
disp(dir)
width = 4096;
height = 2160;

feats = zeros(250, 211);
faceData = zeros(250, 320, 320, 3);
eyeTrack = zeros(250, 4);

idx = 1;
for i = 14002 : 14251
    disp(i);
    f = features(i + 1, :);
    
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
    image = imresize(imageSrc, [320 320]);
    imshow(image);
    
    feats(idx, :) = f;
    faceData(idx, :, :, :) = image;
    eyeTrack(idx, :) = eyeTrackData(i + 1, :);
    idx = idx + 1;
    if idx > 1000
        break;
    end
end
