%Chih-Yuan Yang
%08/25/13
%save gradient_component for paper writing
%Test_PubFig2_1HighContrast: Test face imagew with high contrast illumination
%Test2: 3/19/2014 I need to address a critical problem: how effective is the UCI algorithm for wild faces?
%It is best for me to run the problem on a linux machine, and thus I can check the localized landmarks soon.
%Test3: 3/19/2014 I try the CMU IntraFace library because the UCI algorithm genereates wrong landmarks.
%Test4: 3/20/2014 Since IntraFace works well for the samll set created by me, let me test its performance on the entire
%Pubfig dataset.
%Test5: 3/20/2014 Let me try the performance of IntraFace on images upsampled by bicubic interpolation
clc
clear
close all

folder_code = fileparts(pwd);
folder_project = fileparts(folder_code);
folder_dataset = fullfile(folder_project,'Dataset');
folder_test = fullfile(folder_dataset,'PubFig','FullImage');
folder_lib = fullfile(folder_code,'Lib');
folder_intraface = fullfile(folder_lib,'FacialFeatureDetection&Tracking_v1.3');
folder_models = fullfile(folder_intraface,'models');
addpath(genpath(folder_intraface));     %I nee to add this path, otherwise a mexw64 file can not be loaded
%Invalid MEX-file '\\CHIH-YUAN-PC\120801SRForFace\Code\Lib\FacialFeatureDetection&Tracking_v1.3\+cv\private\CascadeClassifier_.mexw64': The
%specified module could not be found.
addpath(genpath(fullfile(folder_lib,'YIQConverter')));

%settings for test images
sf = 4;
Gau_sigma = 1.4;
folder_save = fullfile('Result','Test5_IntraFace_bicubic');
folder_filelist = 'Filelist';
fn_filelist_test = 'PubFig_All_12850.txt';

idx_file_start = 1;
idx_file_end = 'all';

U22_makeifnotexist(folder_save);

arr_filename_test = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist_test));
num_files_test = length(arr_filename_test);
if isa(idx_file_end,'char')
    if strcmp(idx_file_end,'all')
        idx_file_end = num_files_test;
    end
end

%statements copied from xx_initialize.m
option.face_score = 0.3;
option.min_neighbors = 2;
option.min_face_size = [50 50];
option.compute_pose = true;
% OpenCV face detector model file
xml_file = fullfile(folder_models,'haarcascade_frontalface_alt2.xml');
% load tracking model
load(fullfile(folder_models,'TrackingModel-xxsift-v1.10.mat'));
% load detection model
load(fullfile(folder_models,'DetectionModel-xxsift-v1.5.mat'));
% create face detector handle
fd_h = cv.CascadeClassifier(xml_file);
DM{1}.fd_h = fd_h;

for idx_file_test=idx_file_start:idx_file_end
    %open specific file
    fn_test = arr_filename_test{idx_file_test};
    fn_short = fn_test(1:end-4);
    fn_save = sprintf('%s_detected.png',fn_test);
    fn_save_full = fullfile(folder_save,fn_save);
    %skip if the file exists
    if exist(fn_save_full,'file')
        continue
    end
    
    fprintf('idx_file_test %d, fn_test %s\n',idx_file_test,fn_test);
    %since the PubFig dataset is messy, I need to handle exception here
    try
        img_load = imread(fullfile(folder_test,fn_test));
    catch err
        fprintf('imread does not work for %s\n',fn_test);
        continue
    end

    %generate LR and interpolated images
    img_lr = F19f_GenerateLRImage_IntegerSF(img_load,sf,Gau_sigma);
    img_bb = imresize(img_lr,sf);
    img_test = im2uint8(img_bb);
    
    
    prev = [];
    output = xx_track_detect(DM,TM,img_test,prev,option);  %The IntraFace only reports one face.
    bshownumber = true;
    bdrawpose = true;
    bvisible = false;
    hfig = U21c_DrawLandmarks_IntraFace(img_test,output.pred,bshownumber,bdrawpose,bvisible);
    %The IntraFace algorithm outperforms the UCI algorithm
    %Is the landmark format of IntraFace the same as the AAM format?
    fn_save = sprintf('%s_detected.png',fn_test);
    saveas(hfig, fullfile(folder_save,fn_save));
    close(hfig);
end 
    