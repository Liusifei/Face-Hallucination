%08/31/12
%Chih-Yuan Yang
%Change the strategy, prepare all example images and landmarks.
%when a test image is given, align all example images and landmarks to the test image

clear
%load image
para.trainingimagefolder = fullfile('Examples','Training');
para.landmarkfolder = fullfile('Examples','RawLandmarks');
para.savefolder = fullfile('Examples','PreparedMatForLoad');
para.savename = 'ExampleDataForLoad.mat';
if ~exist(para.savefolder,'dir')
    mkdir(para.savefolder);
end
filelist = dir(fullfile(para.trainingimagefolder,'*.png'));
filenumber = length(filelist);

para.balignimage = true;
para.bshownewlandmarks = false;     %visually check whether they are correct
para.bcropimage = false;

    eyecenter = zeros(2,2,filenumber);  %right eye x, right eye y, left eye x, left eye y    
    %record all landmarks for alignment
    landmarks = zeros(68,2,filenumber);
    %only right eye and left eye are used
    for i=1:filenumber
        %load the landmark
        fn_image = filelist(i).name;
        fn_image_short = fn_image(1:end-4);
        fn_landmark = [fn_image_short '_lm.mat'];
        loaddata = load(fullfile(para.landmarkfolder,fn_landmark));
        landmarks_this = loaddata.pts;
        landmarks(:,:,i) = landmarks_this;
        %find the location of center of eyes
        %the landmark numbers are 37 to 42 (the subject's right eye)
        %43 to 48 (the subject's left eye)
        eyecenter(1,:,i) = mean(landmarks_this(37:42,:));
        eyecenter(2,:,i) = mean(landmarks_this(43:48,:));
    end

    exampleimage = zeros(480,640,filenumber,'uint8');
    for i=1:filenumber
        %load the landmark
        fn_image = filelist(i).name;
        fn_image_short = fn_image(1:end-4);
        img_load = imread(fullfile(para.trainingimagefolder,fn_image));
        exampleimage(:,:,i) = rgb2gray(img_load);
    end

    %save the result for load when testing
    save(fullfile(para.savefolder,para.savename),'eyecenter','exampleimage','landmarks');
    
