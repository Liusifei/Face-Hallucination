%Chih-Yuan Yang
%10/24/12
%Super-Resolution for faces
clc
clear
close all

codefolder = fileparts(pwd);
addpath(genpath(fullfile(codefolder,'Lib')));
addpath(fullfile(codefolder,'Ours2'));
addpath(genpath('Solver'));
    
para.zooming = 4;
para.settingname = 'Upfrontal';
para.testimagefolder = fullfile(codefolder,'Ours2','Source','Upfrontal2','Input');
para.savefolder = 'GeneratedImages';
para.setting = 2;
para.settingnote = 'Rerun all image after removing the bug of double 255 input for L1SR, and use the newly trained dictionary';
para.tuning = 2;
para.tuningnote = 'Frist run using Jianchao code for face, dicionary is learned from face examples';
para.legend = 'Jianchao';
dictionaryfolder = fullfile('Data','Upfrontal3','s4');
fn_dictionary = 'Dictionary.mat';


%Jianchao's setting
patch_size = 3; % patch size for the low resolution input image
overlap = 1; % overlap between adjacent patches
lambda = 0.1; % sparsity parameter
regres = 'L1'; % 'L1' or 'L2', use the sparse representation directly, or use the supports for L2 regression

fileidx_start = 7;
fileidx_end = 'all';
para.mainfilename = mfilename;

if para.zooming == 4
    para.Gau_sigma = 1.6;
elseif para.zooming == 3
    para.Gau_sigma = 1.2;
end

resultfolder = 'Result';
para = U23a_PrepareResultFolder(resultfolder, para);

%load all training images
finalsavefolder = fullfile(para.tuningfolder, para.savefolder);
U22_makeifnotexist(finalsavefolder);
filelist = dir(fullfile(para.testimagefolder, '*.png'));
filenumber = length(filelist);
if isa(fileidx_end,'char')
    if strcmp(fileidx_end,'all')
        fileidx_end = filenumber;
    end
end

%load dictionary
load(fullfile(dictionaryfolder,fn_dictionary));

for fileidx=fileidx_start:fileidx_end
    %open specific file
    fn_test = filelist(fileidx).name;
    fn_short = fn_test(1:end-4);
    fprintf('fileidx %d, fn_test %s\n',fileidx,fn_test);
    img_lr_rgb_uint8 = imread(fullfile(para.testimagefolder,fn_test));
    img_lr_rgb_double = im2double(img_lr_rgb_uint8);
    img_lr_ycbcr_double = rgb2ycbcr(img_lr_rgb_double);
    img_cbcr_lr = img_lr_ycbcr_double(:,:,2:3);
    zooming = para.zooming;
    img_cbcr_hr = imresize(img_cbcr_lr,zooming);
    
    img_y_255_double = double(rgb2gray(img_lr_rgb_uint8));
    img_out_255_double = F3_L1SR(img_y_255_double, zooming, patch_size, overlap, Dh, Dl, lambda, regres);
    
    img_out_ycbcr = img_out_255_double/255;
    img_out_ycbcr(:,:,2:3) = img_cbcr_hr;
    img_out_rgb = ycbcr2rgb(img_out_ycbcr);
    fn_save = sprintf('%s_%s_%d_%d.png',fn_short,para.legend,para.setting,para.tuning);
    imwrite(img_out_rgb, fullfile(finalsavefolder,fn_save));
end