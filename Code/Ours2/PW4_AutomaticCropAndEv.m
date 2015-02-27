%09/15/12
%Chih-Yuan Yang
%save the results as an MAT file to plot figures
clc
clear
close all

iistart = 1;
iiend = 30;     %there are only 30
detectedlandmarkfolder = fullfile('Temp','DetectedLandmarks');
imagefolder_ours = fullfile('Comparison','Ours');
imagefolder_gt = fullfile('Source','GroundTruth');
imagefolder{1} = fullfile('Comparison','Ours');
imagefolder{2} = fullfile('Comparison','Glasner');
imagefolder{3} = fullfile('Comparison','Bicubic');
imagefolder{4} = fullfile('Comparison','GroundTruth');
appendix_read{1} = '_Ours2_1_15';
appendix_read{2} = '_Glasner';
appendix_read{3} = '_Bicubic';
appendix_read{4} = '';
appendix_write{1} = '_Ours2_1_15';
appendix_write{2} = '_Glasner';
appendix_write{3} = '_Bicubic';
appendix_write{4} = '_GroundTruth';
methodname{1} = 'Ours2_1_15';
methodname{2} = 'Glasner';
methodname{3} = 'Bicubic';
methodname{4} = 'GroundTruth';

savefolder = fullfile('Comparison','AutoCropAndEv_15');
U22_makeifnotexist(savefolder);

filelist = dir(fullfile(imagefolder_ours,'*.png'));
filenumber = length(filelist);
comparenumber = 4;
PSNRlist = zeros(comparenumber,1);
SSIMlist = zeros(comparenumber,1);
DIIVINElist = zeros(comparenumber,1);
for i=iistart:iiend
    %open specific file
    fn_ours = filelist(i).name;
    fn_short = fn_ours(1:end-4-11);
    fprintf('processing %s (%d of total %d)\n',fn_short,i,filenumber);
    fn_landmark = sprintf('%s_mi.mat',fn_short);
    %load bs and posemap
    clear bs posemap
    load(fullfile(detectedlandmarkfolder,fn_landmark));
    landmarks = F4_ConvertBStoMultiPieLandmarks(bs);
    
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
        [PSNR, SSIM, DIIVINE] = F7_ComputePSNR_SSIM_DIIVINE(img_gt_crop,crop,bComputeDIIVINE);
        PSNRlist(j) = PSNR;
        SSIMlist(j) = SSIM;
        DIIVINElist(j) = DIIVINE;
        result.(methodname{j}).PSNR = PSNR;
        result.(methodname{j}).SSIM = SSIM;
        result.(methodname{j}).DIIVINE = DIIVINE;
    end
    result.fn_short = fn_short;
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