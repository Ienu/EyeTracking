% from CLM openface images, features, eye track data to mat file
% folder name needs to be modified
% idx range needs to be modified
% save data temp needs to be modified
% save idx needs to be modified
% load demo file name needs to be modified
% save data file name needs to be modified

faceData = [];
features = [];

%% loop data
for idx = 1 : 11
    folder = sprintf('C:\\Users\\workspace\\Lwy\\Data11\\r%d000', idx);
    disp(folder);
    
    %% read image data
    fileFolder = fullfile(folder);
    dirOutput = dir(fullfile(fileFolder,'*.png'));
    amount = size(dirOutput, 1);
    fileNames = {dirOutput.name};
    pfaceData = zeros(amount, 112, 112, 3, 'uint8');
    for i = 1 : amount
        file = strcat(fileFolder, '\', fileNames{i});
        disp(file);
        image = imread(file);
        pfaceData(i, :, :, :) = image;
    end
    faceData = [faceData; pfaceData];
    
    %% read feature data
    auSrc = importdata(strcat(fileFolder, '\au.txt'));
    au = auSrc.data;
    gazeSrc = importdata(strcat(fileFolder, '\gaze.txt'));
    gaze = gazeSrc.data;
    landmarkSrc = importdata(strcat(fileFolder, '\landmark.txt'));
    landmark = landmarkSrc.data;
    paramsSrc = importdata(strcat(fileFolder, '\params.txt'));
    params = paramsSrc.data;
    poseSrc = importdata(strcat(fileFolder, '\pose.txt'));
    pose = poseSrc.data;
    
    feats = [au gaze landmark params pose];
    features = [features; feats];
end

% save data temporary
save temp_jugal_1m.mat faceData features;

% extract valid data
idxAc = [];
for i = 1 : size(faceData, 1)
    image = squeeze(faceData(i, :, :, :));
    
    [h, w, ch] = size(image);
    bImage = 0;
    for ii = 1 : h
        for jj = 1 : w
            if image(ii, jj, 1) ~= 0 || image(ii, jj, 2) ~= 0 || image(ii, jj, 3) ~= 0
                bImage = 1;
                break;
            end
        end
        if bImage == 1
            break;
        end
    end
    
    if bImage == 1
        s = imresize(image, 5);
        imshow(s);
        disp(i);
%         c = input('accept ENTER, refuse r: ');
%         if c == 1
%             continue;
%         else
            idxAc = [idxAc; i];
%         end
    end
end

save idx_jugal_1m.mat idxAc;

demo = load('demo_Jugal_1m.mat');

zfeatures = [];
zfaceData = [];
zeyeTrackData = [];

for i = 1 : size(idxAc, 1)
    disp(i);
    zfeatures = [zfeatures; features(idxAc(i), :)];
    zfaceData = [zfaceData; faceData(idxAc(i), :, :, :)];
    zeyeTrackData = [zeyeTrackData; demo.eyeTrackData(idxAc(i) + 1, :)];
end


% save data
features = zfeatures;
faceData = zfaceData;
eyeTrackData = zeyeTrackData;
save data_jugal_1m_clm.mat faceData features eyeTrackData;
