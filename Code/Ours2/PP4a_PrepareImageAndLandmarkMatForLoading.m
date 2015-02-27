%Chih-Yuan Yang
%10/03/12
%PP4: eyecenter, it is used by methods using PCA
%PP4a: only have images and landmarks

clear
codefolder = fileparts(pwd);
addpath(genpath(fullfile(codefolder,'Lib')));
addpath(fullfile(codefolder,'Utility'));
addpath(fullfile(codefolder,'Common'));

%load image
exampleimagefolder = fullfile(codefolder,'Ours3_nonupfrontal','Examples','NonUpfrontal','ExampleImages');
landmarkfolder = fullfile(codefolder,'Ours3_nonupfrontal','Examples','NonUpfrontal','ExampleImageLandmarks');
savefolder = fullfile(codefolder,'Ours3_nonupfrontal','Examples','NonUpfrontal','PreparedMatForLoad');
savename = 'ExampleDataForLoad.mat';
U22_makeifnotexist(savefolder);
filelist = dir(fullfile(exampleimagefolder,'*.png'));
filenumber = length(filelist);

landmarks = zeros(68,2,filenumber);
for i=1:filenumber
    %load the landmark
    fn_image = filelist(i).name;
    fn_image_short = fn_image(1:end-4);
    fn_landmark = [fn_image_short '_lm.mat'];
    loaddata = load(fullfile(landmarkfolder,fn_landmark));
    landmarks_this = loaddata.pts;
    landmarks(:,:,i) = landmarks_this;
end

exampleimages = zeros(480,640,filenumber,'uint8');
for i=1:filenumber
    %load the landmark
    fn_image = filelist(i).name;
    fn_image_short = fn_image(1:end-4);
    img_load = imread(fullfile(exampleimagefolder,fn_image));
    exampleimages(:,:,i) = rgb2gray(img_load);
end

%save the result for load when testing
save(fullfile(savefolder,savename),'exampleimages','landmarks');  
