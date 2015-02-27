%Chih-Yuan Yan
%2/21/15
%Generate CVPR13 results on JPEG inputs for PAMI website for non upright
%frontal faces
clc
clear
close all

if ispc
    error('This file has to run on a Linux OS.');
end

folder_Ours = pwd;
folder_Code = fileparts(folder_Ours);
folder_Lib = fullfile(folder_Code,'Lib');
folder_YIQConverter = fullfile(folder_Lib, 'YIQConverter');
addpath(folder_YIQConverter);
folder_UCIFaceDetection = fullfile(folder_Lib,'UCIFaceDetection');

folder_save = fullfile('Result',mfilename);
folder_filelist = 'Filelist';

folder_savedexamples = fullfile('Examples','NonUpfrontal3','PreparedMatForLoad');
fn_savedexamples = 'ExampleDataForLoad.mat';

folder_glasslist = fullfile('Examples','NonUpfrontal3');
filename_glasslist = 'GlassList_NonUpfrontal3.txt';

addpath(genpath(fullfile(folder_Lib,'patchmatch-2.1')));
addpath(folder_UCIFaceDetection);

scalingfactor = 4;
Gau_sigma = 1.6;

idx_file_start = 1;
idx_file_end = 'all';

%option_landmark_algorithm = 'IntraFace';
option_landmark_algorithm = 'UCI';

%load all training images
loaddata = load(fullfile(folder_savedexamples,fn_savedexamples),'exampleimages_hr','exampleimages_lr','landmarks');
rawexamplelandmarks = loaddata.landmarks;
rawexampleimage = loaddata.exampleimages_hr;
allLRexampleimages = loaddata.exampleimages_lr;
%arr_glasslabel = loaddata.arr_glasslabel;
%arr_filename_example = loaddata.arr_filename_example;
[arr_glasslabel, arr_filename_example] = U5a_ReadGlassList(fullfile(folder_glasslist, filename_glasslist));
clear loaddata

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

fn_filelist = 'MultiPIE_NonUpfrontal3_JPEGCompressed.txt';
folder_test = fullfile('Source','NonUpfrontal3','Input','JPEGCompressed');

arr_filename = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_file = length(arr_filename);
if isa(idx_file_end,'char')
    if strcmp(idx_file_end,'all')
        idx_file_end = num_file;
    end
end

if ispc 
    error('This script only runs on Linux because of the UCI face detection method.');
end
for fileidx=idx_file_start:idx_file_end
    %open specific file
    fn_test = arr_filename{fileidx};
    fn_short = fn_test(1:end-4);
    fprintf('fileidx %d, fn_test %s\n',fileidx,fn_test);
    if strcmp(option_landmark_algorithm,'UCI')
        str_legend = 'Yang13_test24';
    elseif strcmp(option_landmark_algorithm,'IntraFace')
        str_legend = 'IntraFace_test13';
    end
    %Check, if the output exist, go to the next fil
    fn_save = sprintf('%s_%s.png',fn_short,str_legend);
    U22_makeifnotexist(folder_save);
    if exist(fullfile(folder_save,fn_save),'file')
        fprintf('output file exist\n');
        %If this an empty file, its previous program may crash already. Check the size and created time
        fileinfo = dir(fullfile(folder_save,fn_save));
        if fileinfo(1).bytes == 0
            date_difference_day = now - datenum(fileinfo(1).date);
            date_difference_hour = date_difference_day * 24;
            if date_difference_hour > 3
                %overwrite the existing empty file
                fprintf('Overwrite the exiting empty file %s\n', fn_save);
                fid = fopen(fullfile(folder_save,fn_save),'w+');
                fclose(fid);   
            else
                continue
            end
        else
            continue
        end
    else
        fid = fopen(fullfile(folder_save,fn_save),'w+');
        fclose(fid);
    end

    img_lr_load_ui8 = imread(fullfile(folder_test,fn_test));
    img_lr = im2double(img_lr_load_ui8);
    img_yiq = RGB2YIQ(img_lr);
    img_y = img_yiq(:,:,1);
    img_iq = img_yiq(:,:,2:3);
    img_iq_hr = imresize(img_iq,scalingfactor);
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
        %the bs may be empty as the UCI face detection algorithm may fail to
        %find a face in a highly compressed PubFig JPEG image
        if isempty(bs)
            fid = fopen(fullfile(folder_save,fn_save),'w+');
            fprintf(fid,'%s','Can not find a face');
            fclose(fid);           
            continue
        end
        
        try
            landmark_test = F4_ConvertBStoMultiPieLandmarks(bs(1));
        catch err
            hfig = U21b_DrawLandmarks_Points_ReturnHandle(img_hr_tolabel, bs.xy, '', true, true, false);
            saveas(hfig,fullfile(folder_save, sprintf('%s_detected.png',fn_short)));
            continue
        end
        
        bshownumber = true;
        bdrawpose = true;
        bvisible = false;
        c = bs(1).c;    %we assume there is only one face in the image.
        val_pose = posemap(c);
        str_pose = sprintf('%d',val_pose);        
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


    [gradients_texture, img_texture, img_texture_backprojection] = ...
        F37i_GetTexturePatchMatch_SingleFor(img_y, rawexampleimage, allLRexampleimages, landmark_test, rawexamplelandmarks);

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
        inputpoints = rawexamplelandmarks(set,:,:);
        fprintf('running %s\n',setname{k});
        %this function records example images for paper writing, but Sifei does not use it any more
        %The rawexampleimage is empty
        [retrievedhrimage, retrievedlrimage, retrivedidx, alignedexampleimage_hr, alignedexampleimage_lr] = ...
            F6f_RetriveImage_DrawFlowChart(img_y, ...
            rawexampleimage, inputpoints, basepoints, mask_lr, scalingfactor, Gau_sigma, arr_glasslabel, bglassavoid);

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
    if exist('img_edge','var');
        img_initial = img_edge;
    else
        img_initial = imresize(img_y,scalingfactor);       %change here to img_edge when img_edge is ready
    end
    Grad_exp = gradientwholeimage;

    %this step is very critical, if the optimization is not strong enough, the textural details do not show
    %so, F4d is too weak to be used here
    bReport = false;
    loopnumber = 30;
    totalupdatenumber = 4;
    linesearchstepnumber = 4;
    beta0 = 1;
    beta1 = 1;
    tolf = 0.0001;
    img_out = F4e_GenerateIntensityFromGradient(img_y,img_initial,Grad_exp,Gau_sigma,bReport, ...
        loopnumber,totalupdatenumber,linesearchstepnumber,beta0,beta1,tolf);

    img_out_yiq = cat(3, img_out, img_iq_hr);
    img_out_rgb = YIQ2RGB(img_out_yiq);
    imwrite(img_out_rgb, fullfile(folder_save,fn_save));
end