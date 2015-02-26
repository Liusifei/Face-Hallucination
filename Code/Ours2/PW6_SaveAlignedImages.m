%Chih-Yuan Yang, EECS, UC Merced
%09/14/12
%copied from ours2 to run non-upfrontal images
%Chih-Yuan Yang
%09/14/12
%Test non-frontal faces

clc
clear
close all

    
para.zooming = 4;
para.SaveName = 'Ours2';
para.testimagefolder = fullfile('Source','Input');
para.setting = 2;
para.settingnote = 'Generate aligned image for paper writing';
para.tuning = 1;
para.tuningnote = '';
para.Legend = 'Ours2';
para.model = 'mi';
%parameters for edge

para.fileidx_start = 1;
para.fileidx_end = 1262;            %1262

para.MainFileName = mfilename;
para.patchsize = 5;

fn_test = '145_03_01_051_05.png';
savefolder = fullfile('PaperWriting','AlignedImages_Nose_For145_03_01_051_05');
alignedcomponent = 'nose';

    if para.zooming == 4
        para.Gau_sigma = 1.6;
    elseif para.zooming == 3
        para.Gau_sigma = 1.2;
    end
    
    addpath(fullfile('Lib','YIQConverter'));
    resultfolder = 'Result';
    %U23_PrepareResultFolder(resultfolder,para);

    %run all images in the folder para.testimagefolder, and save the results in the tuningfolder
    filelist = dir(fullfile(para.testimagefolder, '*.png'));
    filecount = length(filelist);
    
    addpath(fullfile('Lib','UCIFaceDetection'));
    %load all training images
    loadfolder = fullfile('Examples','PreparedMatForLoad');
    fn_load = 'ExampleDataForLoad.mat';
    load(fullfile(loadfolder,fn_load),'exampleimage','landmarks');
    rawexamplelandmarks = landmarks;
    rawexampleimage = exampleimage;
    detectedlandmarkfolder = fullfile('Temp','DetectedLandmarks');
    matlabpoolsize = matlabpool('size');
    if matlabpoolsize == 0
        %matlabpool close
        matlabpool open local 4
    end
    
    %before entering the loop, load data first to save time
if 0
    featurefilename = 'sf_1_1264_qf';
    recordfilename = 'srec_1_1264_qf';
    [sfall srecall] = F12_ACCV12Preprocess_LoadingData(para.zooming,featurefilename,recordfilename);
    ACCV12tempfolder = fullfile(para.tuningfolder,'ACCV12Temp');
    U22_makeifnotexist(ACCV12tempfolder)
end
%    for fileidx=para.fileidx_start:para.fileidx_end
        %open specific file
        %fn_testfile = filelist(fileidx).name;
        fn_testfile = fn_test;
%        fprintf('fileidx %d, fn_testfile %s\n',fileidx,fn_testfile);
        para.SourceFile = fullfile(para.testimagefolder,fn_testfile);
        imd = im2double(imread( para.SourceFile) );
        img_yiq = RGB2YIQ(imd);
        img_y = img_yiq(:,:,1);
        IQLayer = img_yiq(:,:,2:3);
        IQLayer_upsampled = imresize(IQLayer,para.zooming);
        para.IQLayer_upsampled = IQLayer_upsampled;

        %assume the test file has been detected
        fn_testfile_short = fn_testfile(1:end-4);
        fn_load = sprintf('%s_mi.mat',fn_testfile_short);
        fn_load_full = fullfile(detectedlandmarkfolder,fn_load);
        loaddata = load(fn_load_full);
        bs = loaddata.bs(1);
        landmarks_test = F4_ConvertBStoMultiPieLandmarks(bs);
        landmarks_test_lr = landmarks_test / para.zooming;
        
    if 0
        disp('ACCV12 for background');
        fn_mat_allimages = 'AllImages_1_1264.mat';       %in the future, change this as data rather filename
        img_ACCV12 = F16_ACCV12UpamplingBackProjectionOnTextureOnly(img_y ,para.zooming, para.Gau_sigma,sfall,srecall,fn_mat_allimages);
        gradientwholeimage = F14_Img2Grad(img_ACCV12);
        save the img_ACCV12 for further research about the best iteration number
        savename = sprintf('%s_ACCV12.mat',fn_testfile_short);
        save(fullfile(ACCV12tempfolder,savename),'img_ACCV12','img_y','para');

        
        %new aligning by optimization
        %left ear
        leftear_lr.left_coor = min(landmarks_test_lr(1:4,1))-2;
        leftear_lr.right_coor = max(landmarks_test_lr(1:4,1));
        leftear_lr.top_coor = min(landmarks_test_lr(1,2)) -1;
        leftear_lr.bottom_coor = max(landmarks_test_lr(4,2)) ;
        %extend the coordinate range to pixel index
        leftear_lr = U19_AddPixelIdxFromCoor(leftear_lr);
        leftear_hr = U18_ConvertLRRegionToHRRegion(leftear_lr, para.zooming);
        
        %new aligning by optimization
        basepoints_leftear = landmarks_test(1:4,:);
        inputpoints_leftear = rawexamplelandmarks(1:4,:,:);
        disp('running leftear');
        gradientcandidate = F6_RetriveAreaGradientsByAlign_Optimization(img_y, rawexampleimage, inputpoints_leftear, basepoints_leftear, leftear_lr, para.zooming, para.Gau_sigma);
        %install the mouth
        usedindex = 1;
        gradientwholeimage(leftear_hr.top_idx:leftear_hr.bottom_idx,leftear_hr.left_idx:leftear_hr.right_idx,:) = ...
            gradientcandidate(:,:,:,usedindex);
        
        %right ear
        rightear_lr.left_coor = min(landmarks_test_lr(14:17,1));
        rightear_lr.right_coor = max(landmarks_test_lr(14:17,1))+2;
        rightear_lr.top_coor = min(landmarks_test_lr(14:17,2))-1;
        rightear_lr.bottom_coor = max(landmarks_test_lr(14:17,2));
        %extend the coordinate range to pixel index
        rightear_lr = U19_AddPixelIdxFromCoor(rightear_lr);
        rightear_hr = U18_ConvertLRRegionToHRRegion(rightear_lr, para.zooming);
        
        basepoints_rightear = landmarks_test(14:17,:);
        inputpoints_rightear = rawexamplelandmarks(14:17,:,:);
        disp('running rightear');
        gradientcandidate = F6_RetriveAreaGradientsByAlign_Optimization(img_y, rawexampleimage, inputpoints_rightear, basepoints_rightear, rightear_lr, para.zooming, para.Gau_sigma);
        %install the mouth
        usedindex = 1;
        gradientwholeimage(rightear_hr.top_idx:rightear_hr.bottom_idx,rightear_hr.left_idx:rightear_hr.right_idx,:) = ...
            gradientcandidate(:,:,:,usedindex);
        
        %left cheek
        leftcheek_lr.left_coor = min(landmarks_test_lr(4:8,1));
        leftcheek_lr.right_coor = max(landmarks_test_lr(4:8,1));
        leftcheek_lr.top_coor = min(landmarks_test_lr(4:8,2));
        leftcheek_lr.bottom_coor = max(landmarks_test_lr(4:8,2));
        %extend the coordinate range to pixel index
        leftcheek_lr = U19_AddPixelIdxFromCoor(leftcheek_lr);
        leftcheek_hr = U18_ConvertLRRegionToHRRegion(leftcheek_lr, para.zooming);
        
        %new aligning by optimization
        basepoints_leftcheek = landmarks_test(4:8,:);
        inputpoints_leftcheek = rawexamplelandmarks(4:8,:,:);
        disp('running leftcheek');
        gradientcandidate = F6_RetriveAreaGradientsByAlign_Optimization(img_y, rawexampleimage, inputpoints_leftcheek, basepoints_leftcheek, leftcheek_lr, para.zooming, para.Gau_sigma);
        %install the mouth
        usedindex = 1;
        gradientwholeimage(leftcheek_hr.top_idx:leftcheek_hr.bottom_idx,leftcheek_hr.left_idx:leftcheek_hr.right_idx,:) = ...
            gradientcandidate(:,:,:,usedindex);

        %right cheek
        rightcheek_lr.left_coor = min(landmarks_test_lr(10:14,1));
        rightcheek_lr.right_coor = max(landmarks_test_lr(10:14,1));
        rightcheek_lr.top_coor = min(landmarks_test_lr(10:14,2));
        rightcheek_lr.bottom_coor = max(landmarks_test_lr(10:14,2));
        %extend the coordinate range to pixel index
        rightcheek_lr = U19_AddPixelIdxFromCoor(rightcheek_lr);
        rightcheek_hr = U18_ConvertLRRegionToHRRegion(rightcheek_lr, para.zooming);
        
        %new aligning by optimization
        basepoints_rightcheek = landmarks_test(10:14,:);
        inputpoints_rightcheek = rawexamplelandmarks(10:14,:,:);
        disp('running rightcheek');
        gradientcandidate = F6_RetriveAreaGradientsByAlign_Optimization(img_y, rawexampleimage, inputpoints_rightcheek, basepoints_rightcheek, rightcheek_lr, para.zooming, para.Gau_sigma);
        %install the mouth
        usedindex = 1;
        gradientwholeimage(rightcheek_hr.top_idx:rightcheek_hr.bottom_idx,rightcheek_hr.left_idx:rightcheek_hr.right_idx,:) = ...
            gradientcandidate(:,:,:,usedindex);

        
        %jaw
        jaw_lr.left_coor = min(landmarks_test_lr(7:11,1));
        jaw_lr.right_coor = max(landmarks_test_lr(7:11,1));
        jaw_lr.top_coor = min(landmarks_test_lr(7:11,2));
        jaw_lr.bottom_coor = max(landmarks_test_lr(7:11,2))+3;
        %extend the coordinate range to pixel index
        jaw_lr = U19_AddPixelIdxFromCoor(jaw_lr);
        jaw_hr = U18_ConvertLRRegionToHRRegion(jaw_lr, para.zooming);
        
        %new aligning by optimization
        basepoints_jaw = landmarks_test(7:11,:);
        inputpoints_jaw = rawexamplelandmarks(7:11,:,:);
        disp('running jaw');
        gradientcandidate = F6_RetriveAreaGradientsByAlign_Optimization(img_y, rawexampleimage, inputpoints_jaw, basepoints_jaw, jaw_lr, para.zooming, para.Gau_sigma);
        %install the mouth
        usedindex = 1;
        gradientwholeimage(jaw_hr.top_idx:jaw_hr.bottom_idx,jaw_hr.left_idx:jaw_hr.right_idx,:) = ...
            gradientcandidate(:,:,:,usedindex);

        
        
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
    end
       
    if strcmp(alignedcomponent,'eyebrows')
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
        gradientcandidate = F6x_RetriveAreaGradientsByAlign_Optimization(img_y, rawexampleimage, inputpoints_eyebrow, basepoints_eyebrow, eyebrow_lr, para.zooming, para.Gau_sigma,savefolder,alignedcomponent);
        
        %install the eyebrow
        usedindex = 1;
        gradientwholeimage(eyebrow_hr.top_idx:eyebrow_hr.bottom_idx,eyebrow_hr.left_idx:eyebrow_hr.right_idx,:) = ...
            gradientcandidate(:,:,:,usedindex);
    end
    
    if strcmp(alignedcomponent,'eyes')
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
    end
        
    if strcmp(alignedcomponent,'nose')
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
        gradientcandidate = F6x_RetriveAreaGradientsByAlign_Optimization(img_y, rawexampleimage, inputpoints_nose, basepoints_nose, nose_lr, para.zooming, para.Gau_sigma,savefolder,alignedcomponent);
        
        %install the nose
        usedindex = 1;
        gradientwholeimage(nose_hr.top_idx:nose_hr.bottom_idx,nose_hr.left_idx:nose_hr.right_idx,:) = ...
            gradientcandidate(:,:,:,usedindex);
    end
        return

        

        
        
        %solve optimization problem
%        img_initial = img_bb_trim;
        img_initial = img_ACCV12;
        Grad_exp = gradientwholeimage;
        Gau_sigma = para.Gau_sigma;
        LoopNumber = 30;
        beta0 = 1;
        beta1 = 1;
        bReport = false;
        img_out = F4_GenerateIntensityFromGradient(img_y,img_initial,Grad_exp,Gau_sigma,LoopNumber,beta0,beta1,bReport);
   
        %add backprojection to improve the PSNR and SSIM
        iternum = 10;
        img_out_backproject = F11_BackProjection(img_y, img_out, para.Gau_sigma, iternum);
        
        img_out_yiq = img_out_backproject;
        img_out_yiq(:,:,2:3) = IQLayer_upsampled;
        img_out_rgb = YIQ2RGB(img_out_yiq);
        fn = sprintf('%s_%s_%d_%d.png',fn_testfile_short,para.Legend,para.setting,para.tuning);
        savefolder = fullfile(para.tuningfolder, 'GeneratedImages');
        U22_makeifnotexist(savefolder);
        imwrite(img_out_rgb, fullfile(savefolder,fn));
        
%    end

    