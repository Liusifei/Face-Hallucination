%Chih-Yuan Yang
%08/25/13
%save gradient_component for paper writing
%Test_PubFig2_1HighContrast: Test face imagew with high contrast illumination
clc
clear
close all

folder_code = fileparts(pwd);
folder_project = fileparts(folder_code);
addpath(genpath(fullfile(folder_code,'Lib')));

%settings for test images
sf = 4;
Gau_sigma = 1.6;
folder_save = fullfile('Result','PubFig2_2UpfrontalAll');
folder_test = fullfile('Source','PubFig2_2Foundable','input');
folder_landmark_detected = fullfile('Landmarks','Detected','PubFig2_2Foundable');
fn_filelist_test = 'PubFig_Labeled_Upfrontal_6398.txt';
str_legend = 'Ours';
folder_semaphore = fullfile('Temp','Semaphore');
fn_semaphore = 'PubFig_Labeled_Upfrontal_6398.txt';

folder_filelist = 'FileList';

%settings for example images
folder_savedexamples = fullfile('Examples','Upfrontal3','PreparedMatForLoad');
fn_savedexamples = 'ExampleDataForLoad.mat';
folder_glasslist = 'Filelist';
fn_glasslist = 'GlassList_Upfrontal3_Example_2184.txt';
folder_exampleimage = fullfile('Examples','Upfrontal3','High');
folder_landmark_example = fullfile('Landmarks','ManuallyLabeled','Upfrontal','Aligned');

idx_file_start = 1;
idx_file_end = 'all';

%load all training images from .mat if exist
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

if matlabpool('size') == 0
    matlabpool open local 4
end
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
    idx_file_test = U25_ReturnTheLargestToDoNumber(fullfile(folder_semaphore,fn_semaphore),idx_file_test);
    if idx_file_test == -1
        break
    end
    fn_test = arr_filename_test{idx_file_test};
    fprintf('idx_file_test %d, fn_test %s\n',idx_file_test,fn_test);
    imd = im2double(imread(fullfile(folder_test,fn_test)));
    img_yiq = RGB2YIQ(imd);
    img_y = img_yiq(:,:,1);
    IQLayer = img_yiq(:,:,2:3);
    IQLayer_upsampled = imresize(IQLayer,sf);
    img_bb = imresize(img_y,sf);
    
    %Can I run UCI code on Windows? 
    %some landmark files do not exist because UCI code can not find the face
    fn_short = fn_test(1:end-4);
    fn_landmark = sprintf('%s_mi.mat',fn_short);
    if ~exist(fullfile(folder_landmark_detected,fn_landmark),'file')
        continue
    end
    %some detected faces are wrong, due to the illumination
    loaddata = load(fullfile(folder_landmark_detected,fn_landmark));
    posemap = loaddata.posemap;
    c = loaddata.bs(1).c;
    idx_pose = posemap(c);
    if idx_pose ~= 0
        continue;
    end
    bs = loaddata.bs(1);
    landmarks_test = F4_ConvertBStoMultiPieLandmarks(bs);
    [gradients_texture, img_texture, img_texture_backprojection] = ...
        F37f_GetTexturePatchMatch_Aligned(img_y, rawexampleimage, allLRexampleimages, landmarks_test, rawexamplelandmarks);
    
    
    [gradient_edge, weightmap_edge] = F21e_EdgePreserving_GaussianKernel(img_y,sf,Gau_sigma);
    gradientwholeimage = gradient_edge .*repmat(weightmap_edge, [1 1 8]) + gradients_texture .* repmat(1-weightmap_edge,[1 1 8]);
    
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
                [mask_lr, mask_hr] = F32_ComputeMask_Mouth(landmarks_test);
                bglassavoid = false;
            case 'eyebrows'
                [mask_lr, mask_hr] = F33_ComputeMask_Eyebrows(landmarks_test);
                bglassavoid = true;
            case 'eyes'
                [mask_lr, mask_hr] = F34_ComputeMask_Eyes(landmarks_test);
                bglassavoid = true;
            case 'nose'
                [mask_lr, mask_hr] = F35_ComputeMask_Nose(landmarks_test);
                bglassavoid = true;
        end

        basepoints = landmarks_test(set,:);
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
    if exist('img_edge','var');
        img_initial = img_edge;
    else
        img_initial = img_bb;       %change here to img_edge when img_edge is ready
    end
    Grad_exp = gradientwholeimage;
    
    %this step is very critical, if the optimization is not strong enough, the textural details do not show
    %so, F4d is too weak to be used here
    bReport = true;
    img_out = F4b_GenerateIntensityFromGradient(img_y,img_initial,Grad_exp,Gau_sigma,bReport);

    img_out_yiq = img_out;
    img_out_yiq(:,:,2:3) = IQLayer_upsampled;
    img_out_rgb = YIQ2RGB(img_out_yiq);
    fn_save = sprintf('%s_%s.png',fn_short,str_legend);
    imwrite(img_out_rgb, fullfile(folder_save,fn_save));
    
    %save data
    gradient_final = gradientwholeimage;
    fn_save = sprintf('%s_%s_data.mat',fn_short,str_legend);
    save(fullfile(folder_save,fn_save),'mask_hr_record','mask_lr_record','retrievedidxrecord',...
        'retrievedhrimagerecord','retrievedlrimagerecord','img_texture','img_texture_backprojection','weightmap_edge',...
        'gradient_edge','gradient_component','gradient_final');
end 
    