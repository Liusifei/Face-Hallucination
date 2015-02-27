%Chih-Yuan Yang
%10/26/12
%This file looks wierd, maybe retired.
function U8_DrawMultiPieLandmark()
    %load image
    imagefolder = fullfile('Examples','Aligned_Gray');
    fnlist = dir(fullfile(imagefolder,'*.png'));
    fileidx = 2;
    fn = fnlist(fileidx).name;
    img = imread(fullfile(imagefolder,fn));
    
    %load landmark
    fn_landmark = fullfile('Examples','SavedData','BasePoints.mat');
    loaddata = load(fn_landmark);
    landmark = loaddata.alignedlandmarks_image(:,:,fileidx);
    
    %show image
    imshow(img);
    axis on
    hold on
    
    %show landmark
    plot(landmark(:,1),landmark(:,2),'r.');
    
    %show text
    for i=1:68
        text(landmark(i,1),landmark(i,2), sprintf('%d',i));
    end
end