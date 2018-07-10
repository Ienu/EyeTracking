% split data 2000, 4000, 6000, 8000, 10000, 12000
% import file name needs to be modified
% j range needs to be modified
% save file name needs to be modified

data = load('data_hh_1m_clm.mat');
amount = size(data.eyeTrackData, 1);
for j = 2000 : 2000 : 12000
    idx = zeros(j, 1);
    list = 1 : 1 : amount;
    rAmount = amount;
    for i = 1 : j
        rIdx = floor(rand() * rAmount) + 1;
        idx(i) = list(rIdx);
        list(rIdx) = list(amount - i);
        rAmount = rAmount - 1;
    end
    eyeTrackData = zeros(j, 4);
    faceData = zeros(j, 112, 112, 3);
    features = zeros(j, size(data.features, 2));
    for i = 1 : j
        eyeTrackData(i, :) = data.eyeTrackData(idx(i), :);
        faceData(i, :) = data.faceData(idx(i), :);
        features(i, :) = data.features(idx(i), :);
    end
    file = sprintf('data_clm_2m_hh_%d.mat', j);
    save(file, 'eyeTrackData', 'faceData', 'features', '-v7.3');   
end
