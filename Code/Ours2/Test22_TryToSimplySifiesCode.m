%Chih-Yuan Yan
%2/20/15
%This is modified from Test18. I try to simplify the code when I gradually
%figure out more details of Sifei's code.
clc
clear
close all

folder_Ours = pwd;
folder_Code = fileparts(folder_Ours);
%folder_Sifei = fullfile(folder_Code,'Sifei');
%folder_JPEG_SR = fullfile(folder_Sifei,'JPEG_SR');
%folder_code4denoise = fullfile(folder_JPEG_SR,'code4denoise');
%folder_FAST_NLM_II = fullfile(folder_code4denoise,'FAST_NLM_II');
%folder_TVD_software = fullfile(folder_code4denoise,'TVD_software');
folder_Lib = fullfile(folder_Code,'Lib');
%folder_FAST_NLM_II = fullfile(folder_Lib,'FAST_NLM_II');
%folder_TVD_software = fullfile(folder_Lib,'TVD_software');

%folder_UCIFaceDetection = fullfile(folder_Lib,'UCIFaceDetection');
folder_intraface = fullfile(folder_Lib,'FacialFeatureDetection&Tracking_v1.3');
folder_models = fullfile(folder_intraface,'models');
folder_glasslist = 'FileList';
filename_glasslist = 'GlassList_Upfrontal3_Example_2184.txt';

folder_save = fullfile('Result',mfilename);
folder_filelist = 'Filelist';

%codefolder = fileparts(pwd);
%projectfolder = fileparts(codefolder);
%folder_Lib = fullfile(codefolder,'Lib');
addpath(genpath(fullfile(folder_Lib,'patchmatch-2.1')));
addpath(fullfile(folder_Lib,'FAST_NLM_II'));
addpath(genpath(fullfile(folder_Lib,'TVD_software')));
addpath(fullfile(folder_Lib,'UCIFaceDetection'));
addpath(fullfile(folder_Lib,'jpegtbx_1.4'));

scalingfactor = 4;
Gau_sigma = 1.6;
folder_exemplarimages = fullfile('Examples','Upfrontal3','PreparedMatForLoad');
fn_example_LR_ycbcr = sprintf('ExampleDataForLoad_YCbCr_ScalingFactor4.mat');        %size of the ExampleDataForLoad_L.mat: 80*60*3*2184.

idx_file_start = 1;
idx_file_end = 'all';

%option_landmark_algorithm = 'IntraFace';
option_landmark_algorithm = 'UCI';
%fn_filelist = 'PubFig2_2Foundable_JPEGCompressed25_50_75_100.txt';
%folder_test = fullfile('Source','PubFig2_2Foundable','JPEGCompressed');
fn_filelist = 'MultiPIE_Upfrontal_Compressed_25_50_75_100.txt';
folder_test = fullfile('Source','Upfrontal3','Input','25_50_75_100');

%load all training images
loaddata = load(fullfile(folder_exemplarimages,fn_example_LR_ycbcr));
landmarks_example = loaddata.landmarks;
exampleimages_lr = loaddata.exampleimages_lr;
exampleimages_hr = loaddata.exampleimages_hr;
clear loaddata

[a,b,c,d] = size(exampleimages_hr);
exampleimage_hr_y = reshape(exampleimages_hr(:,:,1,:),[a,b,d]);

U22_makeifnotexist(folder_save);

%load glass list
glasslist = U5a_ReadGlassList(fullfile(folder_glasslist,filename_glasslist));

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
    if ~isempty(strfind(fn_short, 'Q25'));
        Quality = 25;
    elseif ~isempty(strfind(fn_short, 'Q50'));
        Quality = 50;
    elseif ~isempty(strfind(fn_short, 'Q75'));
        Quality = 75;
    elseif ~isempty(strfind(fn_short, 'Q100'));
        Quality = 100;
    end
        
    fprintf('fileidx %d, fn_test %s\n',fileidx,fn_test);
    if strcmp(option_landmark_algorithm,'UCI')
        str_legend = 'UCI_test22';
    elseif strcmp(option_landmark_algorithm,'IntraFace')
        str_legend = 'IntraFace_test13';
    end
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
    img_ycbcr = rgb2ycbcr(img_lr);
    img_y = img_ycbcr(:,:,1);
    cbcrLayer = img_ycbcr(:,:,2:3);
    cbcrLayer_upsampled = imresize(cbcrLayer,scalingfactor);
    %Does Sifei use Non-Local Mean to denoise?
    %The NML generates blurred images
    img_bb = imresize(FAST_NLM_II(img_y,3,2,0.08),scalingfactor);
    
    img_hr_bb = imresize(img_lr,scalingfactor);
    %bicubic interpolation generates some values less than 0 or greater
    %than 1. We need to clear them.
    img_hr_tolabel = img_hr_bb;
    img_hr_tolabel(img_hr_bb > 1) = 1;
    img_hr_tolabel(img_hr_bb < 0) = 0;
    
    if strcmp(option_landmark_algorithm,'UCI')
        modelname = 'mi';
    %    modelname = 'p146';
    %    modelname = 'p99';    %all the three models fail
        bs = [];
        try
            [bs, posemap] = F2_ReturnLandmarks(img_hr_tolabel,modelname);
        catch err
            disp('Error: The UCI algorithm does not detect a face.');
            continue
        end
        
        if isempty(bs)
            fid = fopen(fullfile(folder_save,fn_save),'w+');
            fprintf(fid,'%s','Can not find a face');
            fclose(fid);           
            continue
        end
        
        landmark_test = F4_ConvertBStoMultiPieLandmarks(bs(1));
        bshownumber = true;
        bdrawpose = true;
        bvisible = false;
        c = bs(1).c;    %we assume there is only one face in the image.
        val_pose = posemap(c);
        str_pose = sprintf('%d',val_pose);        
        %2/1/15 I comment them because imshow() is not allowed on a command
        %-line linux session.
        %hfig = U21b_DrawLandmarks_Points_ReturnHandle(img_hr_tolabel,landmark_test,str_pose,bshownumber,bdrawpose,bvisible);
        %fn_save = sprintf('%s_UCI.png',fn_short);
        %saveas(hfig, fullfile(folder_save,fn_save));
        %close(hfig);
    elseif strcmp(option_landmark_algorithm,'IntraFace')
        img_bb_ui8_rgb = imresize(img_lr_load_ui8, scalingfactor);
        prev = [];
        img_test = img_bb_ui8_rgb;
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
        fn_save = sprintf('%s_IntraFace.png',fn_short);
        saveas(hfig, fullfile(folder_save,fn_save));
        close(hfig);
        landmark_multipie = F1a_ConvertLandmark_Intraface_to_MultiPie(landmark_intraface);
        landmark_multipie = F1b_ArtificiallyAddPoint6165(landmark_multipie);
        landmark_test = landmark_multipie;        
    end
    
    
    %Sifei regularizes the texture image in this F40fs function.
    %The MM algorithm and TV regularization are used here.
    [gradients_texture, img_color] = ...
        F40g_GetTexturePatchMatch_Aligned(img_ycbcr, exampleimages_hr, exampleimages_lr, landmark_test, landmarks_example);
    %     gradients_texture = ...
    %         Fsb_GetTexturePatchMatch_Aligned(img_y, exampleimage_hr_y, allLRexampleimages, landmark_test, landmarks_example,Quality);
    
    
    [gradient_edge, weightmap_edge] = F21g_EdgePreserving_GaussianKernel(img_y,scalingfactor,Gau_sigma);
    gradientwholeimage = gradient_edge .*repmat(weightmap_edge, [1 1 8]) + gradients_texture .* repmat(1-weightmap_edge,[1 1 8]);
    
    [h_lr, w_lr] = size(img_y);
    h_hr = h_lr * scalingfactor;
    w_hr = w_lr * scalingfactor;
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
                [mask_lr, mask_hr] = F32a_ComputeMask_Mouth(landmark_test, scalingfactor, Gau_sigma);
                bglassavoid = false;
            case 'eyebrows'
                [mask_lr, mask_hr] = F33a_ComputeMask_Eyebrows(landmark_test, scalingfactor, Gau_sigma);
                bglassavoid = true;
            case 'eyes'
                [mask_lr, mask_hr] = F34a_ComputeMask_Eyes(landmark_test, scalingfactor, Gau_sigma);
                bglassavoid = true;
            case 'nose'
                [mask_lr, mask_hr] = F35a_ComputeMask_Nose(landmark_test, scalingfactor, Gau_sigma);
                bglassavoid = true;
        end
        
        basepoints = landmark_test(set,:);
        inputpoints = landmarks_example(set,:,:);
        fprintf('running %s\n',setname{k});
        %this function records example images for paper writing, but Sifei does not use it any more
        %The exampleimage_hr_y is empty
        [retrievedhrimage, retrievedlrimage, retrivedidx, alignedexampleimage_hr, alignedexampleimage_lr] = ...
            F6f_RetriveImage_DrawFlowChart(img_y, ...
            exampleimage_hr_y, inputpoints, basepoints, mask_lr, scalingfactor, Gau_sigma, glasslist, bglassavoid);
%        retrievedidxrecord(k) = retrivedidx;
%        retrievedhrimagerecord{k} = retrievedhrimage;
%        retrievedlrimagerecord{k} = retrievedlrimage;
        
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
    end
    
    
    %solve optimization problem
    img_initial = img_bb;       %change here to img_edge when img_edge is ready
    Grad_exp = gradientwholeimage;
    
    %this step is very critical, if the optimization is not strong enough, the textural details do not show
    %so, F4d is too weak to be used here
    bReport = true;
    %Sifei compute the high-resolution image by consider the Quality value.
    img_out = F4b_GenerateIntensityFromGradJpeg(img_y,img_initial,1.5 * Grad_exp,Gau_sigma,bReport,Quality);
    
    img_out_ycbcr = img_out;
    img_out_ycbcr(:,:,2:3) = TV(img_color,0.05, 20);
    img_out_rgb = ycbcr2rgb(img_out_ycbcr);
    if Quality~=100
        img_out_rgb = T1_Facesmoother(uint8(img_out_rgb*256));
    else
        img_out_rgb = uint8(img_out_rgb*256);
    end
    
    imwrite(img_out_rgb, fullfile(folder_save,fn_save));
end
