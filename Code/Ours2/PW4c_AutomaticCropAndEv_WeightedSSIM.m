%09/18/12
%Chih-Yuan Yang
%save the results as an MAT file to plot figures

clc
clear
close all

Setting = 'Ours2_25';


%common, before setting
codefolder = fileparts(pwd);
addpath(fullfile(codefolder,'Utility'));

%setting dependent
switch Setting
    case 'Ours2_16'
        iistart = 1;
        iiend = 30;     %there are only 30
        workingfolder = fullfile(codefolder,'Ours2_upfrontal');
        
        imagefolder_ours = fullfile(workingfolder,'Result','Ours21','Tuning16','GeneratedImages');
        imagefolder_gt = fullfile(workingfolder,'Source','GroundTruth');
        imagefolder{1} = fullfile(workingfolder,'Result','Ours21','Tuning16','GeneratedImages');
        imagefolder{2} = fullfile(codefolder,'Glasner','Result','Upfrontal1','Tuning1','GeneratedImages');
        imagefolder{3} = fullfile(codefolder,'BicubicInterpolation','Result','Upfrontal');
        imagefolder{4} = fullfile(workingfolder,'Source','GroundTruth');
        appendix_read{1} = '_Ours2_1_16';
        appendix_read{2} = '_Glasner';
        appendix_read{3} = '_Bicubic';
        appendix_read{4} = '';
        appendix_write{1} = '_Ours2_1_16';
        appendix_write{2} = '_Glasner';
        appendix_write{3} = '_Bicubic';
        appendix_write{4} = '_GroundTruth';
        methodname{1} = 'Ours2_1_16';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'GroundTruth';

        savefolder = fullfile(workingfolder,'Comparison','AutoCropAndEv_16');
    case 'Ours2_17'
        iistart = 2;
        iiend = 3;     %there are only 30
        workingfolder = fullfile(codefolder,'Ours2_upfrontal');
        
        imagefolder_ours = fullfile(workingfolder,'Result','Ours21','Tuning17','GeneratedImages');
        imagefolder_gt = fullfile(workingfolder,'Source','GroundTruth');
        imagefolder{1} = fullfile(workingfolder,'Result','Ours21','Tuning17','GeneratedImages');
        imagefolder{2} = fullfile(codefolder,'Glasner','Result','Upfrontal1','Tuning1','GeneratedImages');
        imagefolder{3} = fullfile(codefolder,'BicubicInterpolation','Result','Upfrontal');
        imagefolder{4} = fullfile(workingfolder,'Source','GroundTruth');
        appendix_read{1} = '_Ours2_1_17';
        appendix_read{2} = '_Glasner';
        appendix_read{3} = '_Bicubic';
        appendix_read{4} = '';
        appendix_write{1} = '_Ours2_1_17';
        appendix_write{2} = '_Glasner';
        appendix_write{3} = '_Bicubic';
        appendix_write{4} = '_GroundTruth';
        methodname{1} = 'Ours2_1_17';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'GroundTruth';

        savefolder = fullfile(workingfolder,'Comparison','AutoCropAndEv_17');
    case 'Ours2_18'
        iistart = 1;
        iiend = 1;
        workingfolder = fullfile(codefolder,'Ours2_upfrontal');
        
        imagefolder_ours = fullfile(workingfolder,'Result','Ours21','Tuning18','GeneratedImages');
        imagefolder_gt = fullfile(workingfolder,'Source','GroundTruth');
        imagefolder{1} = fullfile(workingfolder,'Result','Ours21','Tuning18','GeneratedImages');
        imagefolder{2} = fullfile(codefolder,'Glasner','Result','Upfrontal1','Tuning1','GeneratedImages');
        imagefolder{3} = fullfile(codefolder,'BicubicInterpolation','Result','Upfrontal');
        imagefolder{4} = fullfile(workingfolder,'Source','GroundTruth');
        appendix_read{1} = '_Ours2_1_18';
        appendix_read{2} = '_Glasner';
        appendix_read{3} = '_Bicubic';
        appendix_read{4} = '';
        appendix_write{1} = '_Ours2_1_18';
        appendix_write{2} = '_Glasner';
        appendix_write{3} = '_Bicubic';
        appendix_write{4} = '_GroundTruth';
        methodname{1} = 'Ours2_1_18';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'GroundTruth';

        savefolder = fullfile(workingfolder,'Comparison','AutoCropAndEv_18');
    case 'Ours2_19'
        iistart = 2;
        iiend = 2;
        workingfolder = fullfile(codefolder,'Ours2_upfrontal');
        
        imagefolder_ours = fullfile(workingfolder,'Result','Ours21','Tuning19','GeneratedImages');
        imagefolder_gt = fullfile(workingfolder,'Source','GroundTruth');
        imagefolder{1} = fullfile(workingfolder,'Result','Ours21','Tuning19','GeneratedImages');
        imagefolder{2} = fullfile(codefolder,'Glasner','Result','Upfrontal1','Tuning1','GeneratedImages');
        imagefolder{3} = fullfile(codefolder,'BicubicInterpolation','Result','Upfrontal');
        imagefolder{4} = fullfile(workingfolder,'Source','GroundTruth');
        appendix_read{1} = '_Ours2_1_19';
        appendix_read{2} = '_Glasner';
        appendix_read{3} = '_Bicubic';
        appendix_read{4} = '';
        appendix_write{1} = '_Ours2_1_19';
        appendix_write{2} = '_Glasner';
        appendix_write{3} = '_Bicubic';
        appendix_write{4} = '_GroundTruth';
        methodname{1} = 'Ours2_1_19';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'GroundTruth';

        savefolder = fullfile(workingfolder,'Comparison','AutoCropAndEv_19');
    case 'Ours2_20'
        iistart = 30;
        iiend = 30;
        workingfolder = fullfile(codefolder,'Ours2_upfrontal');
        
        imagefolder_ours = fullfile(workingfolder,'Result','Ours21','Tuning20','GeneratedImages');
        imagefolder_gt = fullfile(workingfolder,'Source','GroundTruth');
        imagefolder{1} = fullfile(workingfolder,'Result','Ours21','Tuning20','GeneratedImages');
        imagefolder{2} = fullfile(codefolder,'Glasner','Result','Upfrontal1','Tuning1','GeneratedImages');
        imagefolder{3} = fullfile(codefolder,'BicubicInterpolation','Result','Upfrontal');
        imagefolder{4} = fullfile(workingfolder,'Source','GroundTruth');
        appendix_read{1} = '_Ours2_1_20';
        appendix_read{2} = '_Glasner';
        appendix_read{3} = '_Bicubic';
        appendix_read{4} = '';
        appendix_write{1} = '_Ours2_1_20';
        appendix_write{2} = '_Glasner';
        appendix_write{3} = '_Bicubic';
        appendix_write{4} = '_GroundTruth';
        methodname{1} = 'Ours2_1_20';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'GroundTruth';

        savefolder = fullfile(workingfolder,'Comparison','AutoCropAndEv_20');
    case 'Ours2_21'
        iistart = 5;
        iiend = 5;
        workingfolder = fullfile(codefolder,'Ours2_upfrontal');
        
        imagefolder_ours = fullfile(workingfolder,'Result','Ours21','Tuning21','GeneratedImages');
        imagefolder_gt = fullfile(workingfolder,'Source','GroundTruth');
        imagefolder{1} = fullfile(workingfolder,'Result','Ours21','Tuning21','GeneratedImages');
        imagefolder{2} = fullfile(codefolder,'Glasner','Result','Upfrontal1','Tuning1','GeneratedImages');
        imagefolder{3} = fullfile(codefolder,'BicubicInterpolation','Result','Upfrontal');
        imagefolder{4} = fullfile(workingfolder,'Result','Ours21','Tuning23','GeneratedImages');
        imagefolder{5} = fullfile(codefolder,'Sun08','Result','Setting1','Tuning1','GeneratedImages');
        imagefolder{6} = fullfile(workingfolder,'Source','GroundTruth');
        
        appendix_read{1} = '_Ours2_1_21';
        appendix_read{2} = '_Glasner';
        appendix_read{3} = '_Bicubic';
        appendix_read{4} = '_Ours2_1_23';
        appendix_read{5} = '_Sun08';
        appendix_read{6} = '';
        appendix_write{1} = '_Ours2_1_21';
        appendix_write{2} = '_Glasner';
        appendix_write{3} = '_Bicubic';
        appendix_write{4} = '_BicubicPlusBackProjection';
        appendix_write{5} = '_Sun08';
        appendix_write{6} = '_GroundTruth';
        methodname{1} = 'Ours2_1_21';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'BicubicPlusBackProjection';
        methodname{5} = 'Sun08';
        methodname{6} = 'GroundTruth';

        savefolder = fullfile(workingfolder,'Comparison','AutoCropAndEv_21');
    case 'Ours2_22'
        iistart = 2;
        iiend = 3;
        workingfolder = fullfile(codefolder,'Ours2_upfrontal');
        
        imagefolder_ours = fullfile(workingfolder,'Result','Ours21','Tuning22','GeneratedImages');
        imagefolder_gt = fullfile(workingfolder,'Source','GroundTruth');
        imagefolder{1} = fullfile(workingfolder,'Result','Ours21','Tuning22','GeneratedImages');
        imagefolder{2} = fullfile(codefolder,'Glasner','Result','Upfrontal1','Tuning1','GeneratedImages');
        imagefolder{3} = fullfile(codefolder,'BicubicInterpolation','Result','Upfrontal');
        imagefolder{4} = fullfile(workingfolder,'Source','GroundTruth');
        appendix_read{1} = '_Ours2_1_22';
        appendix_read{2} = '_Glasner';
        appendix_read{3} = '_Bicubic';
        appendix_read{4} = '';
        appendix_write{1} = '_Ours2_1_22';
        appendix_write{2} = '_Glasner';
        appendix_write{3} = '_Bicubic';
        appendix_write{4} = '_GroundTruth';
        methodname{1} = 'Ours2_1_22';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'GroundTruth';

        savefolder = fullfile(workingfolder,'Comparison','AutoCropAndEv_22');
    case 'Ours2_23'
        iistart = 1;
        iiend = 6;
        workingfolder = fullfile(codefolder,'Ours2_upfrontal');
        
        imagefolder_ours = fullfile(workingfolder,'Result','Ours21','Tuning23','GeneratedImages');
        imagefolder_gt = fullfile(workingfolder,'Source','GroundTruth');
        imagefolder{1} = fullfile(workingfolder,'Result','Ours21','Tuning23','GeneratedImages');
        imagefolder{2} = fullfile(codefolder,'Glasner','Result','Upfrontal1','Tuning1','GeneratedImages');
        imagefolder{3} = fullfile(codefolder,'BicubicInterpolation','Result','Upfrontal');
        imagefolder{4} = fullfile(workingfolder,'Source','GroundTruth');
        appendix_read{1} = '_Ours2_1_23';
        appendix_read{2} = '_Glasner';
        appendix_read{3} = '_Bicubic';
        appendix_read{4} = '';
        appendix_write{1} = '_Ours2_1_23';
        appendix_write{2} = '_Glasner';
        appendix_write{3} = '_Bicubic';
        appendix_write{4} = '_GroundTruth';
        methodname{1} = 'Ours2_1_23';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'GroundTruth';

        savefolder = fullfile(workingfolder,'Comparison','AutoCropAndEv_23');
    case 'Ours2_24'
        iistart = 1;
        iiend = 30;
        workingfolder = fullfile(codefolder,'Ours2_upfrontal');
        
        imagefolder_ours = fullfile(workingfolder,'Result','Ours21','Tuning24','GeneratedImages');
        imagefolder_gt = fullfile(workingfolder,'Source','GroundTruth');
        imagefolder{1} = fullfile(workingfolder,'Result','Ours21','Tuning21','GeneratedImages');
        imagefolder{2} = fullfile(codefolder,'Glasner','Result','Upfrontal1','Tuning1','GeneratedImages');
        imagefolder{3} = fullfile(codefolder,'BicubicInterpolation','Result','Upfrontal');
        imagefolder{4} = fullfile(workingfolder,'Result','Ours21','Tuning23','GeneratedImages');
        imagefolder{5} = fullfile(codefolder,'Sun08','Result','Setting1','Tuning1','GeneratedImages');
        imagefolder{6} = fullfile(workingfolder,'Source','GroundTruth');
        imagefolder{7} = fullfile(workingfolder,'Result','Ours21','Tuning24','GeneratedImages');
        
        appendix_read{1} = '_Ours2_1_21';
        appendix_read{2} = '_Glasner';
        appendix_read{3} = '_Bicubic';
        appendix_read{4} = '_Ours2_1_23';
        appendix_read{5} = '_Sun08';
        appendix_read{6} = '';
        appendix_read{7} = '_Ours2_1_24';
        appendix_write{1} = '_Ours2_1_21_inneronly';
        appendix_write{2} = '_Glasner';
        appendix_write{3} = '_Bicubic';
        appendix_write{4} = '_BicubicPlusBackProjection';
        appendix_write{5} = '_Sun08';
        appendix_write{6} = '_GroundTruth';
        appendix_write{7} = '_Ours2_1_24_piece';
        methodname{1} = 'Ours2_1_21';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'BicubicPlusBackProjection';
        methodname{5} = 'Sun08';
        methodname{6} = 'GroundTruth';
        methodname{7} = 'Ours2_1_24';

        savefolder = fullfile(workingfolder,'Comparison','AutoCropAndEv_24');
    case 'Ours2_25'
        iistart = 1;
        iiend = 16;
        workingfolder = fullfile(codefolder,'Ours2_upfrontal');
        
        imagefolder_ours = fullfile(workingfolder,'Result','Ours21','Tuning25','GeneratedImages');
        imagefolder_gt = fullfile(workingfolder,'Source','GroundTruth');
        imagefolder{1} = fullfile(workingfolder,'Result','Ours21','Tuning21','GeneratedImages');
        imagefolder{2} = fullfile(codefolder,'Glasner','Result','Upfrontal1','Tuning1','GeneratedImages');
        imagefolder{3} = fullfile(codefolder,'BicubicInterpolation','Result','Upfrontal');
        imagefolder{4} = fullfile(workingfolder,'Result','Ours21','Tuning23','GeneratedImages');
        imagefolder{5} = fullfile(codefolder,'Sun08','Result','Setting1','Tuning2','GeneratedImages');
        imagefolder{6} = fullfile(workingfolder,'Source','GroundTruth');
        imagefolder{7} = fullfile(workingfolder,'Result','Ours21','Tuning24','GeneratedImages');
        imagefolder{8} = fullfile(workingfolder,'Result','Ours21','Tuning25','GeneratedImages');
        
        appendix_read{1} = '_Ours2_1_21';
        appendix_read{2} = '_Glasner';
        appendix_read{3} = '_Bicubic';
        appendix_read{4} = '_Ours2_1_23';
        appendix_read{5} = '_Sun08';
        appendix_read{6} = '';
        appendix_read{7} = '_Ours2_1_24';
        appendix_read{8} = '_Ours2_1_25';
        appendix_write{1} = '_Ours2_1_21_inneronly';
        appendix_write{2} = '_Glasner';
        appendix_write{3} = '_Bicubic';
        appendix_write{4} = '_BicubicPlusBackProjection';
        appendix_write{5} = '_Sun08';
        appendix_write{6} = '_GroundTruth';
        appendix_write{7} = '_Ours2_1_24_Piece';
        appendix_write{8} = '_Ours2_1_25_PieceEdgePrior';
        methodname{1} = 'Ours2_1_21';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'BicubicPlusBackProjection';
        methodname{5} = 'Sun08';
        methodname{6} = 'GroundTruth';
        methodname{7} = 'Ours2_1_24';
        methodname{8} = 'Ours2_1_25';

        savefolder = fullfile(workingfolder,'Comparison','AutoCropAndEv_25');
    case 'Ours3_1'
        iistart = 45;
        iiend = 80;     
        workingfolder = fullfile(codefolder,'Ours3_nonupfrontal');

        imagefolder_ours = fullfile(workingfolder,'Result','Ours31','Tuning1','GeneratedImages');
        imagefolder_gt = fullfile(workingfolder,'Source','GroundTruth');
        imagefolder{1} = fullfile(workingfolder,'Result','Ours31','Tuning1','GeneratedImages');
        imagefolder{2} = fullfile(codefolder,'Glasner','Result','Face041_051','Tuning1','GeneratedImages');
        imagefolder{3} = fullfile(codefolder,'BicubicInterpolation','Result','041_05_Manual');
        imagefolder{4} = fullfile(workingfolder,'Source','GroundTruth');
        appendix_read{1} = '_Ours3_1_1';
        appendix_read{2} = '_Glasner';
        appendix_read{3} = '_Bicubic';
        appendix_read{4} = '';
        appendix_write{1} = '_Ours3_1_1';
        appendix_write{2} = '_Glasner';
        appendix_write{3} = '_Bicubic';
        appendix_write{4} = '_GroundTruth';
        methodname{1} = 'Ours3_1_1';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'GroundTruth';
        savefolder = fullfile(workingfolder,'Comparison','AutoCropAndEv_1');
end

%common, after setting
detectedlandmarkfolder = fullfile(workingfolder,'Temp','DetectedLandmarks');
U22_makeifnotexist(savefolder);
computeddatafolder = fullfile(workingfolder,'Comparison','ComputedData');
U22_makeifnotexist(computeddatafolder);
filelist = dir(fullfile(imagefolder_ours,'*.png'));
filenumber = length(filelist);
comparenumber = length(methodname);
PSNRlist = zeros(comparenumber,1);
SSIMlist = zeros(comparenumber,1);
DIIVINElist = zeros(comparenumber,1);
appendlength = length(appendix_read{1});
for i=iistart:iiend
    %open specific file
    fn_ours = filelist(i).name;
    fn_short = fn_ours(1:end-4-appendlength);
    fprintf('processing %s (%d of total %d)\n',fn_short,i,filenumber);
    fn_landmark = sprintf('%s_mi.mat',fn_short);
    %load bs and posemap
    clear bs posemap
    load(fullfile(detectedlandmarkfolder,fn_landmark));
    %sometimes there are more than one bs detected
    %bs is a structure, not a cell
    landmarks = F4_ConvertBStoMultiPieLandmarks(bs(1));
    
    left = floor(min(landmarks(:,1))) - 20;
    right = ceil(max(landmarks(:,1))) + 20;
    top = floor(min(landmarks(:,2))) - 100;
    bottom = ceil(max(landmarks(:,2))) + 20;
    height = bottom - top + 1;
    width = right - left + 1;
    
    img_gt = imread(fullfile(imagefolder_gt,sprintf('%s.png',fn_short)));
    img_gt_crop = img_gt(top:bottom,left:right,:);
    bComputeDIIVINE = true;    
    for j=1:comparenumber
        img_full = imread(fullfile(imagefolder{j},sprintf('%s%s.png',fn_short,appendix_read{j})));
        crop = img_full(top:bottom,left:right,:);
        imwrite(crop, fullfile(savefolder,sprintf('%s%s_autocrop.png',fn_short,appendix_write{j})));
        fn_computeddatafilename = sprintf('%s%s.png',fn_short,appendix_read{j});
        str_region = sprintf('%d_%d_%d_%d',top,bottom,left,right);
        fn_computeddata = fullfile(computeddatafolder,sprintf('%s_%s_computeddata.mat',fn_computeddatafilename,str_region));
%        WeightedSSIM = F25_WeightedSSIM(rgb2gray(img_gt_crop),rgb2gray(crop));
        norm = F25a_GradientDiffNorm(rgb2gray(img_gt_crop),rgb2gray(crop));
        %add code here to reduce repeated computation
        if ~exist(fn_computeddata,'file');
            [PSNR, SSIM, DIIVINE] = F7_ComputePSNR_SSIM_DIIVINE(img_gt_crop,crop,bComputeDIIVINE);
            %save computed data
            save(fn_computeddata,'PSNR','SSIM','DIIVINE');
        else
            loaddata = load(fn_computeddata);
            PSNR = loaddata.PSNR;
            SSIM = loaddata.SSIM;
            DIIVINE = loaddata.DIIVINE;
        end

        PSNRlist(j) = PSNR;
        SSIMlist(j) = SSIM;
        DIIVINElist(j) = DIIVINE;
        result.(methodname{j}).PSNR = PSNR;
        result.(methodname{j}).SSIM = SSIM;
        result.(methodname{j}).DIIVINE = DIIVINE;
    end
    result.fn_short = fn_short;
    
    %save to text file
    fid = fopen(fullfile(savefolder,sprintf('%s_RegionAndEv.txt',fn_short)),'w');
    fprintf(fid,sprintf('%d %d %d %d\n',left,right,height,width));
    for j=1:comparenumber
        fprintf(fid,'PSNR_%s%s %.2f\n',fn_short,appendix_write{j},PSNRlist(j));
    end
    fprintf(fid,'\n');
    for j=1:comparenumber
        fprintf(fid,'SSIM_%s%s %.4f\n',fn_short,appendix_write{j},SSIMlist(j));
    end
    fprintf(fid,'\n');
    for j=1:comparenumber
        fprintf(fid,'DIIVINE_%s%s %.2f\n',fn_short,appendix_write{j},DIIVINElist(j));
    end
    fclose(fid);
    fn_save = sprintf('%s_RegionAndEv.mat',fn_short);
    save(fullfile(savefolder,fn_save),'result');
end