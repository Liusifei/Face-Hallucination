%Chih-Yuan Yang
%07/18/14
%PP4: eyecenter, it is used by methods using PCA
%PP4a: remove eyecenter, keep images and landmarks
%PP4b: include LR images in double
%PP4c: remove landmarks, only the HR images, this is modified for Jianchao's algorithm where all
%HR images have been aligned and cropped
%PP4d: I update the code for the scaling factor 3.
%PP4e: Sifei's ICIP14 method needs YCbCr example face, but I can not find the file 
%for non-upright frontal faces in her folder. Thus I have to generate it by myself.

clear
folder_ours = pwd;
folder_filelist = fullfile(folder_ours, 'FileList');
%folder_landmark = fullfile('Examples','Upfrontal3','Landmarks');
%folder_exampleimage = fullfile('Examples','Upfrontal3','High');
%folder_save = fullfile('Examples','Upfrontal3','PreparedMatForLoad');
%fn_save = 'ExampleDataForLoad_ScalingFactor3.mat';
%fn_filelist = 'TrainingImage2184Upfrontal.txt';
folder_landmark = fullfile('Examples','NonUpfrontal3','Landmarks');
folder_exampleimage = fullfile('Examples','NonUpfrontal3','Training');
folder_save = fullfile('Examples','NonUpfrontal3','PreparedMatForLoad');
fn_save = 'ExampleDataForLoad_YCbCr_ScalingFactor4.mat';
fn_filelist = 'NonUprightFrontal_Training274.txt';
U22_makeifnotexist(folder_save);
arr_filename = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_file = length(arr_filename);

%scalingfactor = 3;
%sigma = 1.2;
scalingfactor = 4;
sigma = 1.6;
height_hr = 320;
width_hr = 240;
height_lr = floor(height_hr / scalingfactor);
width_lr = floor(width_hr / scalingfactor);
exampleimages_hr = zeros(height_hr,width_hr,3, num_file ,'uint8');
exampleimages_lr = zeros(height_lr,width_lr,3, num_file);
landmarks = zeros(68,2,num_file);
for i=1:num_file
    fprintf('load images %d out of %d\n',i,num_file);
    % Load an image.
    fn_image = arr_filename{i};
    img_hr_rgb = imread(fullfile(folder_exampleimage,fn_image));
    img_lr_rgb = F19c_GenerateLRImage_GaussianKernel(img_hr_rgb,scalingfactor,sigma);
    exampleimages_hr(:,:,:,i) = rgb2ycbcr(img_hr_rgb);
    exampleimages_lr(:,:,:,i) = rgb2ycbcr(img_lr_rgb);
    %load a landmark.
    fn_short = fn_image(1:end-4);
    fn_landmark = [fn_short '_lm.mat'];
    loaddata = load(fullfile(folder_landmark,fn_landmark));
    landmarks(:,:,i) = loaddata.pts;
end

%save the result for load when testing
save(fullfile(folder_save,fn_save),'exampleimages_hr','exampleimages_lr','landmarks');  
