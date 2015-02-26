%Chih-Yuan Yang
%08/25/13
%save gradient_component for paper writing
%Test_PubFig2_1HighContrast: Test face imagew with high contrast illumination
%Test2: 3/19/2014 I need to address a critical problem: how effective is the UCI algorithm for wild faces?
%It is best for me to run the problem on a linux machine, and thus I can check the localized landmarks soon.
%Test3: 3/19/2014 I try the CMU IntraFace library because the UCI algorithm genereates wrong landmarks.

clc
clear
close all

folder_code = fileparts(pwd);
folder_project = fileparts(folder_code);
folder_lib = fullfile(folder_code,'Lib');
folder_intraface = fullfile(folder_lib,'FacialFeatureDetection&Tracking_v1.3');
folder_models = fullfile(folder_intraface,'models');
addpath(genpath(folder_intraface));     %I nee to add this path, otherwise a mexw64 file can not be loaded
addpath(genpath(fullfile(folder_lib,'YIQConverter')));

%settings for test images
sf = 4;
Gau_sigma = 1.6;
folder_save = fullfile('Result','Test3_PubFig_IntraFace');
folder_test = fullfile('Source','PubFig2_1HighContrast_LeftIllumination','Input');
folder_landmark_detected = fullfile('Landmarks','Detected','PubFig2_1HighContrast_LeftIllumination');
fn_filelist_test = 'PubFig_LeftIllumination_40.txt';
str_legend = 'Ours';

folder_filelist = 'Filelist';

%settings for example images
folder_savedexamples = fullfile('Examples','Upfrontal3_1','PreparedMatForLoad');
fn_savedexamples = 'ExampleDataForLoad.mat';
folder_glasslist = 'Filelist';
fn_glasslist = 'GlassList_Upfrontal3_1HighContrast_Example_2167.txt';
folder_exampleimage = fullfile('Examples','Upfrontal3_1HighContrast','High');
folder_landmark_example = fullfile('Landmarks','ManuallyLabeled','Upfrontal','Aligned');

idx_file_start = 1;
idx_file_end = 'all';

%load all training images from .mat if exist
%03/19/14 temporarily disable the exemplar images
if 0
if exist(fullfile(folder_savedexamples,fn_savedexamples),'file')
    loaddata = load(fullfile(folder_savedexamples,fn_savedexamples),'exampleimages_hr','exampleimages_lr','landmarks','arr_glasslabel','arr_filename_example');
    rawexamplelandmarks = loaddata.landmarks;
    rawexampleimage = loaddata.exampleimages_hr;
    allLRexampleimages = loaddata.exampleimages_lr;
    arr_glasslabel = loaddata.arr_glasslabel;
    arr_filename_example = loaddata.arr_filename_example;
    clear loaddata
else
    %load image, it takes time to generate the downsampled LR images
    [arr_filename_example, arr_glasslabel] = U5a_ReadGlassList(fullfile(folder_glasslist,fn_glasslist));
    num_files_example = length(arr_filename_example);
    exampleimages_hr = zeros(320,240,num_files_example,'uint8');
    exampleimages_lr = zeros(80,60,num_files_example);
    landmarks = zeros(68,2,num_files_example);
    
    %load images
    for idx_file=1:num_files_example
        fn_image = arr_filename_example{idx_file};
        fprintf('load images %d out of %d\n',idx_file,num_files_example);
        img_load = imread(fullfile(folder_exampleimage,fn_image));
        exampleimages_hr(:,:,idx_file) = rgb2gray(img_load);
        exampleimages_lr(:,:,idx_file) = F19a_GenerateLRImage_GaussianKernel(exampleimages_hr(:,:,idx_file),sf,Gau_sigma);
    end

    %load landmarks
    for idx_file=1:num_files_example
        fn_image = arr_filename_example{idx_file};
        fprintf('load landmarks %d out of %d\n',idx_file,num_files_example);
        fn_short = fn_image(1:end-4);
        fn_no_illumination = fn_short(1:end-3);
        fn_read = [fn_no_illumination '_05_lm.mat'];
        loaddata = load(fullfile(folder_landmark_example,fn_read));
        landmarks(:,:,idx_file) = loaddata.landmarks_aligned_offset;
    end
    
    %save exampleimage_hr, exampleimage_lr, landmarks, and arr_glasslabel into a mat file for
    %accelerating the process
    U22_makeifnotexist(folder_savedexamples)
    save(fullfile(fullfile(folder_savedexamples,fn_savedexamples)),'exampleimages_hr','exampleimages_lr','landmarks','arr_glasslabel','arr_filename_example');
end
end

%if matlabpool('size') == 0
%    matlabpool open local 4     %03/19/14 Does the command still work
%end
U22_makeifnotexist(folder_save);

arr_filename_test = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist_test));
num_files_test = length(arr_filename_test);
if isa(idx_file_end,'char')
    if strcmp(idx_file_end,'all')
        idx_file_end = num_files_test;
    end
end
for idx_file_test=idx_file_start:idx_file_end
    %open specific file
    fn_test = arr_filename_test{idx_file_test};
    fn_short = fn_test(1:end-4);
    fprintf('idx_file_test %d, fn_test %s\n',idx_file_test,fn_test);
    img_lr = imread(fullfile(folder_test,fn_test));
    img_lr_yiq = RGB2YIQ(img_lr);
    img_y = img_lr_yiq(:,:,1);
    IQLayer = img_lr_yiq(:,:,2:3);
    IQLayer_upsampled = imresize(IQLayer,sf);
    img_bb = imresize(img_lr,sf);

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

    prev = [];
    output = xx_track_detect(DM,TM,img_bb,prev,option);
    bshownumber = true;
    bdrawpose = true;
    bvisible = true;
    hfig = U21c_DrawLandmarks_IntraFace(img_bb,output.pred,bshownumber,bdrawpose,bvisible);
    %The IntraFace algorithm outperforms the UCI algorithm
    %Is the landmark format of IntraFace the same as the AAM format?
    fn_save = sprintf('%s_detected.png',fn_test);
    saveas(hfig, fullfile(folder_save,fn_save));
    close(hfig);
end 
    