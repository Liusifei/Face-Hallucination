%Chih-Yuan Yang
%10/02/12
%Super-Resolution for faces
clc
clear
close all
codefolder = fileparts(pwd);
addpath(genpath(fullfile(codefolder,'Lib')));
addpath(fullfile(codefolder,'Utility'));
addpath(fullfile(codefolder,'Common'));

    
para.zooming = 4;
para.settingname = 'Wild';
para.testimagefolder = fullfile(codefolder,'Ours2_upfrontal','Source','Wild','Input');
para.setting = 1;
para.settingnote = '';
para.tuning = 4;
para.tuningnote = 'Use img_edge as initial in the final optimization problem';
para.legend = 'Ours';
para.model = 'mi';
para.detectedlandmarkfolder = fullfile('Temp','DetectedLandmarks','Wild1_BBImage');
para.glasslistfolder = 'Examples';
para.loadfolder = fullfile('Examples','PreparedMatForLoad');
para.loadname = 'ExampleDataForLoad.mat';

para.fileidx_start = 6;
para.fileidx_end = 100;

para.mainfilename = mfilename;
para.patchsize = 5;

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
loaddata = load(fullfile(para.loadfolder,para.loadname),'exampleimage','landmarks');
rawexamplelandmarks = loaddata.landmarks;
rawexampleimage = loaddata.exampleimage;
clear loaddata
if matlabpool('size') == 0
    matlabpool open local 4
end
finalsavefolder = fullfile(para.tuningfolder, 'GeneratedImages');
U22_makeifnotexist(finalsavefolder);

%load glass list
fid = fopen(fullfile(para.glasslistfolder,'GlassList.txt'),'r+');
C = textscan(fid,'%05d %s %d\n');
fclose(fid);
glasslist = C{3};
clear C fid

for fileidx=para.fileidx_start:para.fileidx_end
    %open specific file
    fn_test = filelist(fileidx).name;
    fprintf('fileidx %d, fn_test %s\n',fileidx,fn_test);
    imd = im2double(imread(fullfile(para.testimagefolder,fn_test)));
    img_yiq = RGB2YIQ(imd);
    img_y = img_yiq(:,:,1);
    IQLayer = img_yiq(:,:,2:3);
    zooming = para.zooming;
    IQLayer_upsampled = imresize(IQLayer,zooming);
    img_bb = imresize(img_y,zooming);
    
    %assume the test file has been detected
    %load computed data
    fn_testshort = fn_test(1:end-4);
    fn_load = sprintf('%s_mi.mat',fn_testshort);
    fn_load_full = fullfile(para.detectedlandmarkfolder,fn_load);
    if ~exist(fn_load_full,'file')
        continue     %no UCI detected results, go to next or reduce the threshold
    end
    loaddata = load(fn_load_full);
    bs = loaddata.bs(1);

    landmarks_test = F4_ConvertBStoMultiPieLandmarks(bs);
    %note here, is the face is too large, ignore it
    left_coor = min(landmarks_test(1:68,1));
    right_coor = max(landmarks_test(1:68,1));
    top_coor = min(landmarks_test(1:68,2));
    bottom_coor = max(landmarks_test(1:68,2));
    center_x_coor = landmarks_test(34,1);
    center_y_coor = landmarks_test(34,2);
    facewide = right_coor - left_coor;
    if facewide > 160*1.5    %160 is the facewide of HR example images, 
        disp('the test face is too large.');
        continue
    end
    %move the test face and landmarks_test to the center of the image to ensure in the boundary
    %nosecenter is the image center
    [h w] = size(img_y);
    crop_left_lr = max(1,round(center_x_coor/4) - 80);
    crop_right_lr = min(w,round(center_x_coor/4) + 79);
    crop_top_lr = max(1,round(center_y_coor/4) - 60);
    crop_bottom_lr = min(h,round(center_y_coor/4) + 59);
    img_crop = img_y(crop_top_lr:crop_bottom_lr,crop_left_lr:crop_right_lr);
    coorshiftx_lr = crop_left_lr -1;
    coorshifty_lr = crop_top_lr -1;
    coorshiftx_hr = coorshiftx_lr * 4;
    coorshifty_hr = coorshifty_lr * 4;
    landmarks_test_shift = F36_ShiftLandmark(landmarks_test,coorshiftx_hr,coorshifty_hr);
    [gradient_expected gradient_actual weightmap img_edge] = F21d_EdgePreserving_GaussianKernel(img_y,para.zooming,para.Gau_sigma);
    gradientwholeimage = gradient_expected;
        
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
                %note here, the landmarks_test may be larger than 640 480 because this is a wild image
                [mask_lr mask_hr] = F32_ComputeMask_Mouth(landmarks_test_shift);
                bglassavoid = false;
            case 'eyebrows'
                [mask_lr mask_hr] = F33_ComputeMask_Eyebrows(landmarks_test_shift);
                bglassavoid = true;
            case 'eyes'
                [mask_lr mask_hr] = F34_ComputeMask_Eyes(landmarks_test_shift);
                bglassavoid = true;
            case 'nose'
                [mask_lr mask_hr] = F35_ComputeMask_Nose(landmarks_test_shift);
                bglassavoid = true;
        end

        basepoints = landmarks_test_shift(set,:);
        inputpoints = rawexamplelandmarks(set,:,:);
        fprintf('running %s\n',setname{k});
        [retrievedhrimage retrievedlrimage retrivedidx] = F6c_RetriveImage_Mask_GlassAware(img_crop, ...
            rawexampleimage, inputpoints, basepoints, mask_lr, para.zooming, para.Gau_sigma, glasslist, bglassavoid);
        retrievedidxrecord(k) = retrivedidx;
        retrievedhrimagerecord{k} = retrievedhrimage;
        retrievedlrimagerecord{k} = retrievedlrimage;
        
        [r_set c_set] = find(mask_hr);      %the mask_hr is shifted
        top = min(r_set);
        bottom = max(r_set);
        left = min(c_set);
        right = max(c_set);

        top_ori = top + coorshifty_hr;
        bottom_ori = bottom + coorshifty_hr;
        left_ori = left + coorshiftx_hr;
        right_ori = right + coorshiftx_hr;
        originalgradients = gradientwholeimage(top_ori:bottom_ori,left_ori:right_ori,:);
        retrievedgradients_wholeimage = F14_Img2Grad(im2double(retrievedhrimage));
        retrievedgradients = retrievedgradients_wholeimage(top:bottom,left:right,:);
        mask_region = mask_hr(top:bottom,left:right);
        
        gradientwholeimage(top_ori:bottom_ori,left_ori:right_ori,:) = ...
            retrievedgradients.* repmat(mask_region,[1 1 8]) + ...
            originalgradients .* repmat(1-mask_region,[1 1 8]);
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
    Gau_sigma = para.Gau_sigma;
    
    %this step is very critical, if the optimization is not strong enough, the textural details do not show
    %so, F4d is too weak to be used here
    bReport = true;
    img_out = F4b_GenerateIntensityFromGradient(img_y,img_initial,Grad_exp,Gau_sigma,bReport);

    img_out_yiq = img_out;
    img_out_yiq(:,:,2:3) = IQLayer_upsampled;
    img_out_rgb = YIQ2RGB(img_out_yiq);
    fn = sprintf('%s_%s_%d_%d.png',fn_testshort,para.legend,para.setting,para.tuning);
    imwrite(img_out_rgb, fullfile(finalsavefolder,fn));
    
    %save data
    fn_save = sprintf('%s_%s_%d_%d_data.mat',fn_testshort,para.legend,para.setting,para.tuning);
    save(fullfile(finalsavefolder,fn_save),'mask_hr_record','mask_lr_record','retrievedidxrecord',...
        'retrievedhrimagerecord','retrievedlrimagerecord');
end 
    