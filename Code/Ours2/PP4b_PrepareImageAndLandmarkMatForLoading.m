%Chih-Yuan Yang
%10/08/12
%PP4: eyecenter, it is used by methods using PCA
%PP4a: only have images and landmarks
%PP4b: include LR images in double 

clear
codefolder = fileparts(pwd);
addpath(genpath(fullfile(codefolder,'Lib')));

%load image
%folder_exampleimages = fullfile(codefolder,'Ours3_nonupfrontal','Examples','NonUpfrontal','ExampleImages');
%folder_landmarks = fullfile(codefolder,'Ours3_nonupfrontal','Examples','NonUpfrontal','ExampleImageLandmarks');
%folder_save = fullfile(codefolder,'Ours3_nonupfrontal','Examples','NonUpfrontal','PreparedMatForLoad');
folder_exampleimages = fullfile('Examples','NonUpfrontal3','Training');
%folder_landmarks = fullfile('Examples','MetaData','AllLandmarks_Upfrontal');
folder_landmarks = fullfile('Examples','NonUpfrontal3','Landmarks');
folder_save = fullfile('Examples','NonUpfrontal3','PreparedMatForLoad');
fn_save = 'ExampleDataForLoad.mat';
U22_makeifnotexist(folder_save);
filelist = dir(fullfile(folder_exampleimages,'*.png'));
filenumber = length(filelist);

landmarks = zeros(68,2,filenumber);
for i=1:filenumber
    fprintf('load landmarks %d out of %d\n',i,filenumber);
    %load the landmark
    fn_image = filelist(i).name;
    fn_image_short = fn_image(1:end-4);
    fn_landmark = [fn_image_short '_lm.mat'];
    loaddata = load(fullfile(folder_landmarks,fn_landmark));
    landmarks_this = loaddata.pts;
    landmarks(:,:,i) = landmarks_this;
end

img_load = imread(fullfile(folder_exampleimages,filelist(1).name));
[h_hr,w_hr,d] = size(img_load);
zooming = 4;
h_lr = h_hr / zooming;
w_lr = w_hr / zooming;
exampleimages_hr = zeros(h_hr,w_hr,filenumber,'uint8');
exampleimages_lr = zeros(h_lr,w_lr,filenumber);
sigma = 1.6;
for i=1:filenumber
    fprintf('load images %d out of %d\n',i,filenumber);
    %load the landmark
    fn_image = filelist(i).name;
    fn_image_short = fn_image(1:end-4);
    img_load = imread(fullfile(folder_exampleimages,fn_image));
    exampleimages_hr(:,:,i) = rgb2gray(img_load);
    exampleimages_lr(:,:,i) = F19a_GenerateLRImage_GaussianKernel(exampleimages_hr(:,:,i),zooming,sigma);
end

%save the result for load when testing
save(fullfile(folder_save,fn_save),'exampleimages_hr','exampleimages_lr','landmarks');  
