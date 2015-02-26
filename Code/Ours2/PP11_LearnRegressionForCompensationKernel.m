%Chih-Yuan Yang
%09/28/12
%Try to learn the back projection kernel from 16 patch square values
%I am worry I can't finish this before CVPR deadline
clc
clear
close all

    
para.zooming = 4;
para.settingname = 'Wild';
para.trainingfolder = fullfile('Source','GroundTruth','MultiPIE');
para.testimagefolder = fullfile('Source','Input','Wild');
para.savefolder = fullfile('GeneratedImages');
para.setting = 1;
para.settingnote = '';
para.tuning = 1;
para.tuningnote = 'Use bicubic interpolation, edge prior, no cheek boudary, on wild faces';
para.legend = 'Ours';
para.model = 'mi';
%parameters for edge

para.fileidx_start = 3;      %wild test images 
para.fileidx_end = 18;

para.mainfilename = mfilename;
para.patchsize = 5;

codefolder = fileparts(pwd);
addpath(fullfile(codefolder,'Common'));
addpath(fullfile(codefolder,'Utility'));
addpath(genpath(fullfile(codefolder,'Lib')));
if para.zooming == 4
    para.Gau_sigma = 1.6;
elseif para.zooming == 3
    para.Gau_sigma = 1.2;
end

resultfolder = 'Result';
para = U23a_PrepareResultFolder(resultfolder, para);

%run all images in the folder para.testimagefolder, and save the results in the tuningfolder
filelist = dir(fullfile(para.testimagefolder, '*.png'));
%how do dir sort this list?
filecount = length(filelist);

%load all training images
para.loadfolder = fullfile('Examples','PreparedMatForLoad');
para.loadname = 'ExampleDataForLoad.mat';
loaddata = load(fullfile(para.loadfolder,para.loadname),'eyecenter','exampleimage','landmarks');
rawexamplelandmarks = loaddata.landmarks;
rawexampleimage = loaddata.exampleimage;
clear loaddata
detectedlandmarkfolder = fullfile('Temp','DetectedLandmarks','Wild');
%if matlabpool('size') == 0
%    matlabpool open local 4
%end
    
for fileidx=para.fileidx_start:para.fileidx_end
    %open specific file
    fn_test = filelist(fileidx).name;
    fprintf('fileidx %d, fn_test %s\n',fileidx,fn_test);
    imd = im2double(imread(fullfile(para.testimagefolder,fn_test)));
    img_yiq = RGB2YIQ(imd);
    img_y = img_yiq(:,:,1);
    IQLayer = img_yiq(:,:,2:3);
    IQLayer_upsampled = imresize(IQLayer,para.zooming);

    img_bb = imresize(img_y,para.zooming);
    iternum = 10;
    breport = true;
    disp('backprojection for img_bb');
    img_bb_backproject = F11a_AdaptiveBackProjection(img_y, img_bb, para.Gau_sigma, iternum,breport);
    
    %assume the test file has been detected
    %load computed data
    fn_testshort = fn_test(1:end-4);
    fn_load = sprintf('%s_mi.mat',fn_testshort);
    fn_load_full = fullfile(detectedlandmarkfolder,fn_load);
    if ~exist(fn_load_full,'file')
        continue     %no UCI detected results, go to next or reduce the threshold
    end
    loaddata = load(fn_load_full);
    bs = loaddata.bs(1);
    
    landmarks_test = F4_ConvertBStoMultiPieLandmarks(bs);
    landmarks_test_lr = landmarks_test / para.zooming;
    [gradient_expected gradient_actual weightmap_edge img_edge] = F21a_EdgePreserving_ForceConstraint(img_y,para,para.zooming,para.Gau_sigma);
%    img_merge = img_bb_backproject .* (1-weightmap_edge) + img_edge .* weightmap_edge;
    
%    gradients_bb_backproject = F14_Img2Grad(img_bb_backproject);
%    gradientwholeimage = gradients_edge .* repmat(weightmap_edge,[1,1,8]) + gradients_bb_backproject .* repmat(1-weightmap_edge,[1,1,8]);
    gradientwholeimage = gradient_actual;
        
    %mouth part
    mouth_lr.left_coor = min(landmarks_test_lr(49:68,1));
    mouth_lr.right_coor = max(landmarks_test_lr(49:68,1));
    mouth_lr.top_coor = min(landmarks_test_lr(49:68,2));
    mouth_lr.bottom_coor = max(landmarks_test_lr(49:68,2));
    %extend the coordinate range to pixel index
    mouth_lr = U19_AddPixelIdxFromCoor(mouth_lr);
    mouth_hr = U18_ConvertLRRegionToHRRegion(mouth_lr, para.zooming);

    %new aligning by optimization
    basepoints_mouth = landmarks_test(49:68,:);
    inputpoints_mouth = rawexamplelandmarks(49:68,:,:);
    disp('running mouth');
    gradientcandidate = F6_RetriveAreaGradientsByAlign_Optimization(img_y, rawexampleimage, inputpoints_mouth, basepoints_mouth, mouth_lr, para.zooming, para.Gau_sigma);
    %install the mouth
    usedindex = 1;
    gradientwholeimage(mouth_hr.top_idx:mouth_hr.bottom_idx,mouth_hr.left_idx:mouth_hr.right_idx,:) = ...
        gradientcandidate(:,:,:,usedindex);


    %Eyebrow part
    eyebrow_lr.left_coor = min(landmarks_test_lr(18,1));
    eyebrow_lr.right_coor = max(landmarks_test_lr(27,1));
    eyebrow_lr.top_coor = min(landmarks_test_lr(18:27,2));
    eyebrow_lr.bottom_coor = min(landmarks_test_lr(37:46,2));
    eyebrow_lr = U19_AddPixelIdxFromCoor(eyebrow_lr);
    eyebrow_hr = U18_ConvertLRRegionToHRRegion(eyebrow_lr, para.zooming);
    disp('running eyebrow');        
    %realign for eyebrow points mean(18:22) and mean(23:27)
    basepoints_eyebrow = landmarks_test(18:27,:);
    inputpoints_eyebrow = rawexamplelandmarks(18:27,:,:);
    gradientcandidate = F6_RetriveAreaGradientsByAlign_Optimization(img_y, rawexampleimage, inputpoints_eyebrow, basepoints_eyebrow, eyebrow_lr, para.zooming, para.Gau_sigma);

    %install the eyebrow
    usedindex = 1;
    gradientwholeimage(eyebrow_hr.top_idx:eyebrow_hr.bottom_idx,eyebrow_hr.left_idx:eyebrow_hr.right_idx,:) = ...
        gradientcandidate(:,:,:,usedindex);

    %Eye part
    eye_lr.left_coor = landmarks_test_lr(37,1);
    eye_lr.top_coor = min( [landmarks_test_lr(38,2), landmarks_test_lr(39,2), landmarks_test_lr(44,2), landmarks_test_lr(45,2)] );
    eye_lr.right_coor = landmarks_test_lr(46,1);
    eye_lr.bottom_coor = max( [landmarks_test_lr(41,2), landmarks_test_lr(42,2), landmarks_test_lr(44,2), landmarks_test_lr(45,2)] );
    eye_lr = U19_AddPixelIdxFromCoor(eye_lr);
    eye_hr = U18_ConvertLRRegionToHRRegion(eye_lr, para.zooming);

    disp('running eye');        
    basepoints_eye = landmarks_test(37:48,:);
    inputpoints_eye = rawexamplelandmarks(37:48,:,:);
    gradientcandidate = F6_RetriveAreaGradientsByAlign_Optimization(img_y, rawexampleimage, inputpoints_eye, basepoints_eye, eye_lr, para.zooming, para.Gau_sigma);

    %install the eyes
    usedindex = 1;
    gradientwholeimage(eye_hr.top_idx:eye_hr.bottom_idx,eye_hr.left_idx:eye_hr.right_idx,:) = ...
        gradientcandidate(:,:,:,usedindex);


    %copy nose region
    nose_lr.left_coor = min(landmarks_test_lr(28:36,1));
    nose_lr.right_coor = max(landmarks_test_lr(28:36,1));
    nose_lr.top_coor = min(landmarks_test_lr(28:36,2));
    nose_lr.bottom_coor = max(landmarks_test_lr(28:36,2));
    %extend the coordinate range to pixel index
    nose_lr.left_idx = floor(nose_lr.left_coor);
    nose_lr.top_idx = floor(nose_lr.top_coor);
    nose_lr.right_idx = floor(nose_lr.right_coor) +1;
    nose_lr.bottom_idx = floor(nose_lr.bottom_coor) +1;

    nose_hr = U18_ConvertLRRegionToHRRegion(nose_lr, para.zooming);

    disp('running nose');        
    basepoints_nose = landmarks_test(28:36,:);
    inputpoints_nose = rawexamplelandmarks(28:36,:,:);
    gradientcandidate = F6_RetriveAreaGradientsByAlign_Optimization(img_y, rawexampleimage, inputpoints_nose, basepoints_nose, nose_lr, para.zooming, para.Gau_sigma);

    %install the nose
    usedindex = 1;
    gradientwholeimage(nose_hr.top_idx:nose_hr.bottom_idx,nose_hr.left_idx:nose_hr.right_idx,:) = ...
        gradientcandidate(:,:,:,usedindex);

    %solve optimization problem
    img_initial = imresize(img_y,para.zooming);
    Grad_exp = gradientwholeimage;
    Gau_sigma = para.Gau_sigma;
    bReport = true;
    img_out = F4a_GenerateIntensityFromGradient(img_y,img_initial,Grad_exp,Gau_sigma,bReport);

    img_out_yiq = img_out;
    img_out_yiq(:,:,2:3) = IQLayer_upsampled;
    img_out_rgb = YIQ2RGB(img_out_yiq);
    fn = sprintf('%s_%s_%d_%d.png',fn_testshort,para.legend,para.setting,para.tuning);
    finalsavefolder = fullfile(para.tuningfolder, para.savefolder);
    U22_makeifnotexist(finalsavefolder);
    imwrite(img_out_rgb, fullfile(finalsavefolder,fn));
end 
    