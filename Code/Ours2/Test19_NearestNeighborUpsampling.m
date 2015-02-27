%Chih-Yuan Yan
%2/3/15
%I need generate the nearest neighbor upsampling for a webpage
clc
clear
close all

folder_Ours = pwd;
folder_Code = fileparts(folder_Ours);
folder_Sifei = fullfile(folder_Code,'Sifei');
folder_JPEG_SR = fullfile(folder_Sifei,'JPEG_SR');
rootf = fullfile(folder_Sifei,'Ours2');
rootp = fullfile(folder_Sifei,'PIE');
rootr = fullfile(folder_JPEG_SR,'Results');
toolbox = fullfile(folder_JPEG_SR,'jpegtbx_1.4');
folder_code4denoise = fullfile(folder_JPEG_SR,'code4denoise');
folder_FAST_NLM_II = fullfile(folder_code4denoise,'FAST_NLM_II');
folder_TVD_software = fullfile(folder_code4denoise,'TVD_software');
folder_Lib = fullfile(folder_Code,'Lib');
folder_UCIFaceDetection = fullfile(folder_Lib,'UCIFaceDetection');
folder_Lab2RGB = fullfile(folder_Lib,'Lab2RGB');
folder_RGB2Lab = fullfile(folder_Lib,'RGB2Lab');
folder_intraface = fullfile(folder_Lib,'FacialFeatureDetection&Tracking_v1.3');
folder_models = fullfile(folder_intraface,'models');
folder_glasslist = fullfile(rootf,'Examples','Upfrontal3');

folder_save = fullfile('Result',mfilename);
folder_filelist = 'Filelist';

codefolder = fileparts(pwd);
projectfolder = fileparts(codefolder);
folder_Lib = fullfile(codefolder,'Lib');
addpath(genpath(fullfile(folder_Lib,'patchmatch-2.1')));
addpath(genpath(rootf));
addpath(toolbox);
addpath(folder_FAST_NLM_II);
addpath(genpath(folder_TVD_software));
addpath(folder_RGB2Lab);
addpath(folder_Lab2RGB);
addpath(folder_UCIFaceDetection);

sf = 4;
Gau_sigma = 1.6;
folder_exemplarimages = fullfile(rootp,'Upfrontal3_training','Training_LR_JPEG','PreparedMatForLoad_color');
fn_example_LR_Lab = sprintf('ExampleDataForLoad_L.mat');        %size of the ExampleDataForLoad_L.mat: 80*60*3*2184.
%The content looks like Lab rather than RGB

%32: the woman; 11: big eye man; 54: 150_04_01_051_05
idx_file_start = 1;
idx_file_end = 'all';

%option_landmark_algorithm = 'IntraFace';
option_landmark_algorithm = 'UCI';
Quality = 100;

switch Quality
    case 25
        fn_filelist = 'Upfrontal3_342_Q25.txt';
        folder_test = fullfile('Source','Upfrontal3','Input','25');
    case 50
        fn_filelist = 'Upfrontal3_342_Q50.txt';
        folder_test = fullfile('Source','Upfrontal3','Input','50');
    case 75
        fn_filelist = 'Upfrontal3_342_Q75.txt';
        folder_test = fullfile('Source','Upfrontal3','Input','75');
    case 100
        fn_filelist = 'Upfrontal3_342_Q100.txt';
        folder_test = fullfile('Source','Upfrontal3','Input','100');
end



%load all training images
load(fullfile(folder_exemplarimages,fn_example_LR_Lab));
% allLRexampleimages = exampleimages_lr;

% ,'exampleimages_hr','exampleimages_lr','landmarks');
load(fullfile(folder_exemplarimages,'landmarks.mat'));
rawexamplelandmarks = landmarks;

%What is this? 'ExampleDataForLoad_H'?
load(fullfile(folder_exemplarimages,'ExampleDataForLoad_H'));
% rawexampleimage = exampleimages_hr;
[a,b,c,d] = size(exampleimages_hr);
rawexampleimage = reshape(exampleimages_hr(:,:,1,:),[a,b,d]);
U22_makeifnotexist(folder_save);

%load glass list
fid = fopen(fullfile(folder_glasslist,'GlassList.txt'),'r+');
C = textscan(fid,'%05d %s %d\n');
fclose(fid);
glasslist = C{3};
examplefilenamelist = C{2};
clear C fid
clc

arr_filename = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_file = length(arr_filename);
if isa(idx_file_end,'char')
    if strcmp(idx_file_end,'all')
        idx_file_end = num_file;
    end
end

if strcmp(option_landmark_algorithm,'IntraFace')
    str_legend = 'IntraFace_test13';
    %setup the IntraFace detector
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
end

for fileidx=idx_file_start:idx_file_end
    %open specific file
    fn_test = arr_filename{fileidx};
    fn_short = fn_test(1:end-4);
    fprintf('fileidx %d, fn_test %s\n',fileidx,fn_test);
    str_legend = 'nn_test19';
    %Check, if the output exist, go to the next fil
    fn_save = sprintf('%s_%s.png',fn_short,str_legend);
    if exist(fullfile(folder_save,fn_save),'file')
        fprintf('output file exist\n');
        continue
    else
        fid = fopen(fullfile(folder_save,fn_save),'w+');
        fclose(fid);
    end
    
    img_lr_load_ui8 = imread(fullfile(folder_test,fn_test));
    img_lr = im2double(img_lr_load_ui8);
    img_hr_nn = imresize(img_lr,sf,'nearest');
    
    imwrite(img_hr_nn, fullfile(folder_save,fn_save));
end
