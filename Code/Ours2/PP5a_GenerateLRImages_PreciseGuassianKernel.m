%Chih-Yuan Yang
%10/22/12
%PP5: not precise Gaussian kernel when zooming is 4
%PP5a: precise Gaussian kernel

clear
codefolder = fileparts(pwd);
addpath(genpath(fullfile(codefolder,'Lib')));

%case PubFig
folder_hr = 'D:\Documents\Research\Datasets\Face\PubFig\FullImage';
folder_lr = fullfile('Temp','PubFig_lr');
fn_filelist = 'PubFig_All_12850.txt';
folder_filelist = 'FileList';
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

U22_makeifnotexist(folder_lr);
arr_filename = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_files = length(arr_filename);

s = 4;
sigma = 1.6;
for idx_file = 1:num_files
    fn_read = arr_filename{idx_file};
    img_gt = im2double(imread(fullfile(folder_hr,fn_read)));
    img_lr = F19a_GenerateLRImage_GaussianKernel(img_gt,s,sigma);
    fn_write = fn_read;
    imwrite(img_lr,fullfile(folder_lr,fn_write));
end