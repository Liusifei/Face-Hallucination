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
%Test6: 3/20/2014 Let me see the generated super-resolution images using IntraFace instead of the UCI algorithm
%Test10: 3/22/2014 Replace the background and edge process by ICCV13
%Test11: 3/23/2014 I want to figure out the reason of the artifacts in a specific image, Barack_Obama_161

clc
clear
close all

folder_code = fileparts(pwd);
folder_project = fileparts(folder_code);
folder_dataset = fullfile(folder_project,'Dataset');
folder_lib = fullfile(folder_code,'Lib');
folder_intraface = fullfile(folder_lib,'FacialFeatureDetection&Tracking_v1.3');
folder_models = fullfile(folder_intraface,'models');
folder_coef_root = 'Coef';
folder_cluster_root = 'Cluster';
addpath(genpath(folder_intraface));     %I nee to add this path, otherwise a mexw64 file can not be loaded
addpath(genpath(fullfile(folder_lib,'YIQConverter')));
addpath(genpath(fullfile(folder_lib,'patchmatch-2.1')));

%settings for test images
sf = 4;
Gau_sigma = 1.6;   %I have to use this value because the it is used to generate the LR test images.
folder_save = fullfile('Result','Test11_DeepStudyBarackObama161');
folder_test = fullfile('Source','PubFig2_1HighContrast_LeftIllumination','Input');
folder_filelist = 'Filelist';
fn_filelist_test = 'PubFig_LeftIllumination_40.txt';
str_legend = '_test11';

%setup exemplar images and landmarks
folder_savedexamples = fullfile('Examples','Upfrontal3_1','PreparedMatForLoad');
fn_savedexamples = 'ExampleDataForLoad.mat';
folder_glasslist = 'Filelist';
fn_glasslist = 'GlassList_Upfrontal3_1HighContrast_Example_2167.txt';
folder_exampleimage = fullfile('Examples','Upfrontal3_1HighContrast','High');
folder_landmark_example = fullfile('Landmarks','ManuallyLabeled','Upfrontal','Aligned');


idx_file_start = 7;
idx_file_end = 7;
bSkipIfOutputExist = false;

U22_makeifnotexist(folder_save);

arr_filename_test = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist_test));
num_files_test = length(arr_filename_test);
if isa(idx_file_end,'char')
    if strcmp(idx_file_end,'all')
        idx_file_end = num_files_test;
    end
end

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

%load exemplar images and landmarks
if ~exist('exampleimages_hr','var')
    %the loaded images are left illumunated. Are they corect?
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

if ~exist('coef_matrix','var')
    %load coef of ICCV 13
    folder_coef = fullfile(folder_coef_root,sprintf('sf%d',sf),sprintf('sigma%.1f',Gau_sigma));
    fn_coef_matrix = sprintf('coef_matrix_sf%d_sigma%0.1f.mat',sf,Gau_sigma);
    loaddata = load(fullfile(folder_coef,fn_coef_matrix));
    coef_matrix = loaddata.coef_matrix;

    %load cluster center
    folder_cluster = fullfile(folder_cluster_root,sprintf('sf%d',sf),sprintf('sigma%.1f',Gau_sigma));
    fn_clustercenter = sprintf('ClusterCenter_sf%d_sigma%.1f.mat',sf,Gau_sigma);
    loaddata = load(fullfile(folder_cluster, fn_clustercenter),'clustercenter');
    clustercenter = loaddata.clustercenter';        %transpose, to make each feature as a column
end

for idx_file_test=idx_file_start:idx_file_end
    %open specific file
    fn_test = arr_filename_test{idx_file_test};
    fn_short = fn_test(1:end-4);
    fn_save = sprintf('%s_detected.png',fn_test);
    fn_save_img = sprintf('%s%s.png',fn_short,str_legend);
    fn_save_full = fullfile(folder_save,fn_save_img);
    %skip if the file exists
    %change the detected files to the finally genereated output files
    if exist(fn_save_full,'file') && bSkipIfOutputExist
        fprintf('test %d, %s exists.\n',idx_file_test, fn_save_img);
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
    img_lr = im2double(img_load);
    img_lr_yiq = RGB2YIQ(img_lr);
    img_y = img_lr_yiq(:,:,1);
    img_hr_iq = imresize(img_lr_yiq(:,:,2:3),sf);
    img_bb_color = imresize(img_lr,sf);
    img_test = im2uint8(img_bb_color);    %the IntraFace does not accept images in double format
    
    %detect
    prev = [];
    output = xx_track_detect(DM,TM,img_test,prev,option);  %The IntraFace only reports one face.
    bshownumber = true;
    bdrawpose = true;
    bvisible = false;
    landmark_intraface = output.pred;
    if isempty(landmark_intraface)
        fprintf('IntraFace does not return a face.\n');
        continue
    end
    hfig = U21c_DrawLandmarks_IntraFace(img_test,landmark_intraface,bshownumber,bdrawpose,bvisible);
    fn_save = sprintf('%s_detected.png',fn_test);
    saveas(hfig, fullfile(folder_save,fn_save));
    close(hfig);
    landmark_multipie = F1a_ConvertLandmark_Intraface_to_MultiPie(landmark_intraface);
    landmark_multipie = F1b_ArtificiallyAddPoint6165(landmark_multipie);
    landmark_test = landmark_multipie;
    
    %construct the background and edges by ICCV13
    img_hr_background = F47_Upsample_ICCV13(img_y,sf,clustercenter,coef_matrix);
    gradientwholeimage = F14c_Img2Grad_fast_suppressboundary(img_hr_background);
    
    [h_lr, w_lr] = size(img_y);
    h_hr = h_lr * sf;
    w_hr = w_lr * sf;
    gradient_zdim = 8;
    gradient_component = zeros(h_hr,w_hr,gradient_zdim);
        
    %Component setting
    componentlandmarkset = cell(4,1);
    setname = cell(4,1);
    componentlandmarkset{1} = 49:68;        %mouth
    componentlandmarkset{2} = 18:27;        %eyebrows
    componentlandmarkset{3} = 37:48;        %eyes
    componentlandmarkset{4} = 28:36;        %nose
    setname{1} = 'mouth';
    setname{2} = 'eyebrows';
    setname{3} = 'eyes';
    setname{4} = 'nose';
    
    
    landmarksetnumber = length(componentlandmarkset);
    for k=1:landmarksetnumber
        set = componentlandmarkset{k};
        switch setname{k}
            case 'mouth'
                [mask_lr, mask_hr] = F32_ComputeMask_Mouth(landmark_test);
                bglassavoid = false;
            case 'eyebrows'
                [mask_lr, mask_hr] = F33_ComputeMask_Eyebrows(landmark_test);
                bglassavoid = true;
            case 'eyes'
                [mask_lr, mask_hr] = F34_ComputeMask_Eyes(landmark_test);
                bglassavoid = true;
            case 'nose'
                [mask_lr, mask_hr] = F35_ComputeMask_Nose(landmark_test);
                bglassavoid = true;
        end

        basepoints = landmark_test(set,:);
        inputpoints = rawexamplelandmarks(set,:,:);
        fprintf('running %s\n',setname{k});
        [retrievedhrimage, retrievedlrimage, retrivedidx, alignedexampleimage_hr, alignedexampleimage_lr] = ...
            F6d_RetriveImage_DrawFlowChart(img_y, ...
            rawexampleimage, inputpoints, basepoints, mask_lr, sf, Gau_sigma, arr_glasslabel, bglassavoid);
        retrievedidxrecord(k) = retrivedidx;
        retrievedhrimagerecord{k} = retrievedhrimage;
        retrievedlrimagerecord{k} = retrievedlrimage;
        
        [r_set, c_set] = find(mask_hr);
        top = min(r_set);
        bottom = max(r_set);
        left = min(c_set);
        right = max(c_set);

        originalgradients = gradientwholeimage(top:bottom,left:right,:);
        retrievedgradients_wholeimage = F14_Img2Grad(im2double(retrievedhrimage));
        retrievedgradients = retrievedgradients_wholeimage(top:bottom,left:right,:);
        mask_region = mask_hr(top:bottom,left:right);
        
        gradientwholeimage(top:bottom,left:right,:) = ...
            retrievedgradients.* repmat(mask_region,[1 1 8]) + ...
            originalgradients .* repmat(1-mask_region,[1 1 8]);
        gradient_component(top:bottom,left:right,:) = retrievedgradients .* repmat(mask_region,[1 1 8]);
        mask_lr_record{k} = mask_lr;
        mask_hr_record{k} = mask_hr;
    end

    
    %solve optimization problem
    img_initial = imresize(img_y,sf);
    Grad_exp = gradientwholeimage;
    
    %this step is very critical, if the optimization is not strong enough, the textural details do not show
    %so, F4d is too weak to be used here
    bReport = true;
    img_out = F4b_GenerateIntensityFromGradient(img_y,img_initial,Grad_exp,Gau_sigma,bReport);

    img_out_yiq = img_out;
    img_out_yiq(:,:,2:3) = img_hr_iq;
    img_out_rgb = YIQ2RGB(img_out_yiq);
    imwrite(img_out_rgb, fullfile(folder_save,fn_save_img));
    
    %save data
    gradient_final = gradientwholeimage;
    fn_save = sprintf('%s%s_data.mat',fn_short,str_legend);
    save(fullfile(folder_save,fn_save),'mask_hr_record','mask_lr_record','retrievedidxrecord',...
        'retrievedhrimagerecord','retrievedlrimagerecord','gradient_final');
    
end 
    