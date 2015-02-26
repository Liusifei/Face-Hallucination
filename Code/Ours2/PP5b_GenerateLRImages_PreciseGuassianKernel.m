%Chih-Yuan Yang
%07/19/14 Update the code for the scaling factor of 3.
%PP5: not precise Gaussian kernel when zooming is 4
%PP5a: precise Gaussian kernel
%PP5b: add some exception control because some images in PubFig can not be opened

clear
codefolder = fileparts(pwd);
addpath(genpath(fullfile(codefolder,'Lib')));

%case aligned pubfig left illumination
% folder_hr = fullfile('Source','Wild2_1HighContrast_LeftIllumination','GroundTruth');
% folder_lr = fullfile('Source','Wild2_1HighContrast_LeftIllumination','input');
% fn_filelist = 'PubFig_LeftIllumination_40.txt';
% folder_filelist = 'FileList';
%case PubFig
% folder_hr = 'D:\Documents\Research\Datasets\Face\PubFig\FullImage';
% folder_lr = fullfile('Temp','PubFig_lr');
% fn_filelist = 'PubFig_All_12850.txt';
% folder_filelist = 'FileList';
%case Upfrontal3_1 High Contrast Test
% folder_hr = fullfile('Source','Upfrontal3_1HighContrast','GroundTruth');
% folder_lr = fullfile('Source','Upfrontal3_1HighContrast','Input');
% folder_filelist = 'FileList';
% fn_filelist = 'TestImage342UpfrontalHighContrast.txt';
%case Upfrontal3_1 High Contrast examples
% folder_hr = fullfile('Examples','Upfrontal3_1HighContrast','High');
% folder_lr = fullfile('Examples','Upfrontal3_1HighContrast','Low');
% folder_filelist = 'FileList';
% fn_filelist = 'TrainingImage2167Upfrontal3_1HighContrast.txt';
%case PubFig_Labeled_Upfrontal
% folder_hr = fullfile('Source','PubFig2_2Foundable','GroundTruth');
% folder_lr = fullfile('Source','PubFig2_2Foundable','input');
% fn_filelist = 'PubFig_Labeled_Upfrontal_6398.txt';
% folder_filelist = 'FileList';
% idx_file_start = 5640;
% Setting for the scaling factor of 3
folder_hr = fullfile('Source','Upfrontal3','GroundTruth');
folder_lr = fullfile('Source','Upfrontal3','input_scalingfactor3');
fn_filelist = 'Upfrontal3_342_png.txt';
folder_filelist = 'FileList';
idx_file_start = 1;


U22_makeifnotexist(folder_lr);
arr_filename = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_files = length(arr_filename);

s = 3;
sigma = 1.2;
for idx_file = idx_file_start:num_files
    fn_list = arr_filename{idx_file};
    set_location = strfind(fn_list,'.');
    fn_short = fn_list(1:end-4);
    fn_load = [fn_short '_align_crop.png'];
    try
        %some files may not be able to open
        img_hr = im2double(imread(fullfile(folder_hr,fn_load)));
    catch error
        continue
    end
    img_lr = F19c_GenerateLRImage_GaussianKernel(img_hr,s,sigma);
    %some img_hr images are too small (less than 4x4) and the img_lr become empty
    try
        fn_write = [fn_short '.png'];
        imwrite(img_lr,fullfile(folder_lr,fn_write));
    catch error
        continue
    end
end