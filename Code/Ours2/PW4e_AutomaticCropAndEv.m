%Chih-Yuan Yang
%10/04/12
%PW4e: from PW4a, the crop size changes to 320 x 240 to be the same as Liu07

clc
clear
close all
codefolder = fileparts(pwd);
addpath(genpath(fullfile(codefolder,'Lib')));

Setting = 'Ours2_39';

%setting dependent
switch Setting
    case 'Ours2_32'
        iistart = 1;
        iiend = 94;
        workingfolder = fullfile(codefolder,'Ours2_upfrontal');
        
        imagefolder_ours = fullfile(workingfolder,'Result','Ours21','Tuning32','GeneratedImages');
        imagefolder_gt = fullfile(workingfolder,'Source','GroundTruth','MultiPIE');
        imagefolder{1} = fullfile(workingfolder,'Result','Ours21','Tuning32','GeneratedImages');
        imagefolder{2} = fullfile(codefolder,'Glasner','Result','Upfrontal1','Tuning1','GeneratedImages');
        imagefolder{3} = fullfile(codefolder,'BicubicInterpolation','Result','Upfrontal');
        imagefolder{4} = fullfile(workingfolder,'Result','Ours21','Tuning23','GeneratedImages');
        imagefolder{5} = fullfile(codefolder,'Sun08','Result','Setting1','Tuning2','GeneratedImages');
        imagefolder{6} = imagefolder_gt;
        
        appendix_read{1} = '_Ours_1_32';
        appendix_read{2} = '_Glasner';
        appendix_read{3} = '_Bicubic';
        appendix_read{4} = '_Ours2_1_23';
        appendix_read{5} = '_Sun08';
        appendix_read{6} = '';
        appendix_write{1} = '_Ours_1_32';
        appendix_write{2} = '_Glasner';
        appendix_write{3} = '_Bicubic';
        appendix_write{4} = '_BicubicPlusBackProjection';
        appendix_write{5} = '_Sun08';
        appendix_write{6} = '_GroundTruth';
        methodname{1} = 'Ours_1_32';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'BicubicPlusBackProjection';
        methodname{5} = 'Sun08';
        methodname{6} = 'GroundTruth';

        savefolder = fullfile(workingfolder,'Comparison','AutoCropAndEv_32');
    case 'Ours2_33'
        iistart = 1;
        iiend = 25;
        workingfolder = fullfile(codefolder,'Ours2_upfrontal');
        
        imagefolder_ours = fullfile(workingfolder,'Result','Ours21','Tuning33','GeneratedImages');
        imagefolder_gt = fullfile(workingfolder,'Source','GroundTruth','MultiPIE');
        imagefolder{1} = fullfile(workingfolder,'Result','Ours21','Tuning33','GeneratedImages');
        imagefolder{2} = fullfile(codefolder,'Glasner','Result','Upfrontal1','Tuning1','GeneratedImages');
        imagefolder{3} = fullfile(codefolder,'BicubicInterpolation','Result','Upfrontal');
        imagefolder{4} = fullfile(codefolder,'BackProjection','Result','Upfrontal1','Tuning2','GeneratedImages');
        imagefolder{5} = fullfile(codefolder,'Sun08','Result','Setting1','Tuning2','GeneratedImages');
        imagefolder{6} = imagefolder_gt;
        
        appendix_read{1} = '_Ours_1_33';
        appendix_read{2} = '_Glasner';
        appendix_read{3} = '_Bicubic';
        appendix_read{4} = '_BackProjection_1_2';
        appendix_read{5} = '_Sun08';
        appendix_read{6} = '';
        appendix_write{1} = '_Ours_1_33';
        appendix_write{2} = '_Glasner';
        appendix_write{3} = '_Bicubic';
        appendix_write{4} = '_BackProjection';
        appendix_write{5} = '_Sun08';
        appendix_write{6} = '_GroundTruth';
        methodname{1} = 'Ours_1_33';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'BackProjection';
        methodname{5} = 'Sun08';
        methodname{6} = 'GroundTruth';

        savefolder = fullfile(workingfolder,'Comparison','AutoCropAndEv_33_2_SmallerTolF');
    case 'Ours2_35'
        iistart = 1;
        iiend = 86;
        workingfolder = fullfile(codefolder,'Ours2_upfrontal');
        
        imagefolder_ours = fullfile(workingfolder,'Result','Ours21','Tuning35','GeneratedImages');
        imagefolder_gt = fullfile(workingfolder,'Source','GroundTruth','MultiPIE');
        imagefolder{1} = fullfile(workingfolder,'Result','Ours21','Tuning35','GeneratedImages');
        imagefolder{2} = fullfile(codefolder,'Glasner','Result','Upfrontal1','Tuning1','GeneratedImages');
        imagefolder{3} = fullfile(codefolder,'BicubicInterpolation','Result','Upfrontal');
        imagefolder{4} = fullfile(codefolder,'BackProjection','Result','Upfrontal1','Tuning2','GeneratedImages');
        imagefolder{5} = fullfile(codefolder,'Sun08','Result','Setting1','Tuning2','GeneratedImages');
        imagefolder{6} = imagefolder_gt;
        
        appendix_read{1} = '_Ours_1_35';
        appendix_read{2} = '_Glasner';
        appendix_read{3} = '_Bicubic';
        appendix_read{4} = '_BackProjection_1_2';
        appendix_read{5} = '_Sun08';
        appendix_read{6} = '';
        appendix_write{1} = '_Ours_1_35';
        appendix_write{2} = '_Glasner';
        appendix_write{3} = '_Bicubic';
        appendix_write{4} = '_BackProjection';
        appendix_write{5} = '_Sun08';
        appendix_write{6} = '_GroundTruth';
        methodname{1} = 'Ours_1_35';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'BackProjection';
        methodname{5} = 'Sun08';
        methodname{6} = 'GroundTruth';

        savefolder = fullfile(workingfolder,'Comparison','AutoCropAndEv_35');
    case 'Ours2_36'
        iistart = 1;
        iiend = 31;
        workingfolder = fullfile(codefolder,'Ours2_upfrontal');
        
        imagefolder_ours = fullfile(workingfolder,'Result','Ours21','Tuning36','GeneratedImages');
        imagefolder_gt = fullfile(workingfolder,'Source','GroundTruth','MultiPIE');
        imagefolder{1} = fullfile(workingfolder,'Result','Ours21','Tuning36','GeneratedImages');
        imagefolder{2} = fullfile(codefolder,'Glasner','Result','Upfrontal1','Tuning1','GeneratedImages');
        imagefolder{3} = fullfile(codefolder,'BicubicInterpolation','Result','Upfrontal');
        imagefolder{4} = fullfile(codefolder,'BackProjection','Result','Upfrontal1','Tuning2','GeneratedImages');
        imagefolder{5} = fullfile(codefolder,'Sun08','Result','Setting1','Tuning2','GeneratedImages');
        imagefolder{6} = imagefolder_gt;
        
        appendix_read{1} = '_Ours_1_36';
        appendix_read{2} = '_Glasner';
        appendix_read{3} = '_Bicubic';
        appendix_read{4} = '_BackProjection_1_2';
        appendix_read{5} = '_Sun08';
        appendix_read{6} = '';
        appendix_write{1} = '_Ours_1_36';
        appendix_write{2} = '_Glasner';
        appendix_write{3} = '_Bicubic';
        appendix_write{4} = '_BackProjection';
        appendix_write{5} = '_Sun08';
        appendix_write{6} = '_GroundTruth';
        methodname{1} = 'Ours_1_36';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'BackProjection';
        methodname{5} = 'Sun08';
        methodname{6} = 'GroundTruth';

        savefolder = fullfile(workingfolder,'Comparison','AutoCropAndEv_36');
    case 'Ours2_39'
        iistart = 1;
        iiend = 51;
        workingfolder = fullfile(codefolder,'Ours2_upfrontal');
        
        imagefolder_ours = fullfile(workingfolder,'Result','Ours21','Tuning39','GeneratedImages');
        imagefolder_gt = fullfile(workingfolder,'Source','GroundTruth','MultiPIE');
        imagefolder{1} = fullfile(workingfolder,'Result','Ours21','Tuning39','GeneratedImages');
        imagefolder{2} = fullfile(codefolder,'Glasner','Result','Upfrontal1','Tuning1','GeneratedImages');
        imagefolder{3} = fullfile(codefolder,'BicubicInterpolation','Result','Upfrontal');
        imagefolder{4} = fullfile(codefolder,'BackProjection','Result','Upfrontal1','Tuning2','GeneratedImages');
        imagefolder{5} = fullfile(codefolder,'Sun08','Result','Setting1','Tuning2','GeneratedImages');
        imagefolder{6} = imagefolder_gt;
        imagefolder{7} = fullfile(codefolder,'NearestNeighbor','Result','Ours21','Tuning1','GeneratedImages');
        
        appendix_read{1} = '_Ours_1_39';
        appendix_read{2} = '_Glasner';
        appendix_read{3} = '_Bicubic';
        appendix_read{4} = '_BackProjection_1_2';
        appendix_read{5} = '_Sun08';
        appendix_read{6} = '';
        appendix_read{7} = '_nn';
        appendix_write{1} = '_Ours_1_39';
        appendix_write{2} = '_Glasner';
        appendix_write{3} = '_Bicubic';
        appendix_write{4} = '_BackProjection';
        appendix_write{5} = '_Sun08';
        appendix_write{6} = '_GroundTruth';
        appendix_write{7} = '_nn';
        methodname{1} = 'Ours_1_39';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'BackProjection';
        methodname{5} = 'Sun08';
        methodname{6} = 'GroundTruth';
        methodname{7} = 'NearestNeighbor';

        savefolder = fullfile(workingfolder,'Comparison','AutoCropAndEv_39');
    case 'Wild_1_4'
        iistart = 1;
        iiend = 'all';
        workingfolder = fullfile(codefolder,'Ours2_upfrontal');
        
        imagefolder_ours = fullfile(workingfolder,'Result','Wild1','Tuning4','GeneratedImages');
        imagefolder_gt = fullfile(workingfolder,'Source','Wild','GroundTruth');
        k=0;
        k=k+1;imagefolder{k} = fullfile(workingfolder,'Result','Wild1','Tuning4','GeneratedImages');
        %imagefolder{2} = fullfile(codefolder,'Glasner','Result','Upfrontal1','Tuning1','GeneratedImages');
        %imagefolder{3} = fullfile(codefolder,'BicubicInterpolation','Result','Upfrontal');
        k=k+1;imagefolder{k} = fullfile(codefolder,'BackProjection','Result','Upfrontal1','Tuning2','GeneratedImages');
        %imagefolder{5} = fullfile(codefolder,'Sun08','Result','Setting1','Tuning2','GeneratedImages');
        k=k+1;imagefolder{k} = imagefolder_gt;
        k=k+1;imagefolder{k} = fullfile(codefolder,'NearestNeighbor','Result','Wild1','Tuning1','GeneratedImages');
        
        k=0;
        k=k+1;appendix_read{k} = '_Ours_1_4';
        %appendix_read{2} = '_Glasner';
        %appendix_read{3} = '_Bicubic';
        k=k+1;appendix_read{k} = '_BackProjection_1_1';
        %appendix_read{5} = '_Sun08';
        k=k+1;appendix_read{k} = '';
        k=k+1;appendix_read{k} = '_nn';
        k=0;
        k=k+1;appendix_write{k} = '_Ours_1_4';
        %appendix_write{2} = '_Glasner';
        %appendix_write{3} = '_Bicubic';
        k=k+1;appendix_write{k} = '_BackProjection';
        %appendix_write{5} = '_Sun08';
        k=k+1;appendix_write{k} = '_GroundTruth';
        k=k+1;appendix_write{k} = '_nn';
        k=0;
        k=k+1;methodname{k} = 'Ours_1_4';
        %methodname{2} = 'Glasner';
        %methodname{3} = 'Bicubic';
        k=k+1;methodname{k} = 'BackProjection';
        %methodname{5} = 'Sun08';
        k=k+1;methodname{k} = 'GroundTruth';
        k=k+1;methodname{k} = 'NearestNeighbor';

        savefolder = fullfile(workingfolder,'Comparison','Wild','AutoCropAndEv_4');
end

%common, after setting
detectedlandmarkfolder = fullfile(workingfolder,'Temp','DetectedLandmarks','MultiPIE');
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
if isa(iiend,'char')
    if strcmp(iiend,'all')
        iiend = filenumber;
    end
end
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
    %compute the nose center
    lefteyecenter = mean(landmarks(37:42,:));
    righteyecenter = mean(landmarks(43:48,:));
    twoeyecenter = (lefteyecenter + righteyecenter)/2;
    left = round(twoeyecenter(1)) - 120;
    right = round(twoeyecenter(1)) + 119;
    top = round(twoeyecenter(2)) - 160;
    bottom = round(twoeyecenter(2)) + 159;
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