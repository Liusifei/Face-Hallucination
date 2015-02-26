%Chih-Yuan Yang
%10/08/12
%PP4: eyecenter, it is used by methods using PCA
%PP4a: remove eyecenter, keep images and landmarks
%PP4b: include LR images in double
%PP4c: remove landmarks, only the HR images, this is modified for Jianchao's algorithm where all
%HR images have been aligned and cropped

clear
codefolder = fileparts(pwd);
addpath(genpath(fullfile(codefolder,'Lib')));

%load image
%exampleimagefolder = fullfile(codefolder,'Ours3_nonupfrontal','Examples','NonUpfrontal','ExampleImages');
%landmarkfolder = fullfile(codefolder,'Ours3_nonupfrontal','Examples','NonUpfrontal','ExampleImageLandmarks');
%savefolder = fullfile(codefolder,'Ours3_nonupfrontal','Examples','NonUpfrontal','PreparedMatForLoad');
exampleimagefolder = fullfile('Examples','Upfrontal3','Training');
%landmarkfolder = fullfile('Examples','MetaData','AllLandmarks_Upfrontal');
savefolder = fullfile('Examples','Upfrontal3','PreparedMatForLoad');
savename = 'ExampleDataForLoad.mat';
U22_makeifnotexist(savefolder);
filelist = dir(fullfile(exampleimagefolder,'*.png'));
filenumber = length(filelist);

%landmarks = zeros(68,2,filenumber);
%for i=1:filenumber
%    fprintf('load landmarks %d out of %d\n',i,filenumber);
    %load the landmark
%    fn_image = filelist(i).name;
%    fn_image_short = fn_image(1:end-4);
%    fn_landmark = [fn_image_short '_lm.mat'];
%    loaddata = load(fullfile(landmarkfolder,fn_landmark));
%    landmarks_this = loaddata.pts;
%    landmarks(:,:,i) = landmarks_this;
%end

exampleimages_hr = zeros(320,240,filenumber,'uint8');
exampleimages_lr = zeros(80,60,filenumber);
zooming = 4;
sigma = 1.6;
for i=1:filenumber
    fprintf('load images %d out of %d\n',i,filenumber);
    %load the landmark
    fn_image = filelist(i).name;
%    fn_image_short = fn_image(1:end-4);
    img_load = imread(fullfile(exampleimagefolder,fn_image));
    exampleimages_hr(:,:,i) = rgb2gray(img_load);
    exampleimages_lr(:,:,i) = F19a_GenerateLRImage_GaussianKernel(exampleimages_hr(:,:,i),zooming,sigma);
end

%save the result for load when testing
save(fullfile(savefolder,savename),'exampleimages_hr','exampleimages_lr','sigma');  
