%09/18/12
%Chih-Yuan Yang
%save the results as an MAT file to plot figures

clc
clear
close all

Setting = 'Ours2_20';


%common, before setting
% projectfolder = fileparts(pwd);
projectfolder = 'D:\Projects\FACE HR\Results_show';
% addpath(fullfile(projectfolder,'Utility'));

%setting dependent
switch Setting
    case 'Ours2_20'
        iistart = 31;
        iiend = 100;
        workingfolder = fullfile(projectfolder,'Ours2_upfrontal');
        
        imagefolder_ours = fullfile(workingfolder,'Result','Ours21','Tuning20','GeneratedImages');
        imagefolder_gt = fullfile(workingfolder,'Source','GroundTruth');
        imagefolder{1} = fullfile(workingfolder,'Result','Ours21','Tuning20','GeneratedImages');
        imagefolder{2} = fullfile(projectfolder,'Glasner','Result','Upfrontal1','Tuning1','GeneratedImages');
        imagefolder{3} = fullfile(projectfolder,'BicubicInterpolation','Result','Upfrontal');
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

        savefolder = fullfile(workingfolder,'Comparison','WholeImageEv_20');
end

%common, after setting
U22_makeifnotexist(savefolder);

filelist = dir(fullfile(imagefolder_ours,'*.png'));
filenumber = length(filelist);
comparenumber = 5;
PSNRlist = zeros(comparenumber,1);
SSIMlist = zeros(comparenumber,1);
DIIVINElist = zeros(comparenumber,1);
appendlength = length(appendix_read{1});
for i=iistart:iiend
    %open specific file
    fn_ours = filelist(i).name;
    fn_short = fn_ours(1:end-4-appendlength);
    fprintf('processing %s (%d of total %d)\n',fn_short,i,filenumber);
%    fn_landmark = sprintf('%s_mi.mat',fn_short);
    %load bs and posemap
%    clear bs posemap
%    load(fullfile(detectedlandmarkfolder,fn_landmark));
    %sometimes there are more than one bs detected
    %bs is a structure, not a cell
%    landmarks = F4_ConvertBStoMultiPieLandmarks(bs(1));
    
    left = 1;
    right = 640;
    top = 1;
    bottom = 480;
    height = bottom - top + 1;
    width = right - left + 1;
    
    img_gt = imread(fullfile(imagefolder_gt,sprintf('%s.png',fn_short)));
    img_gt_crop = img_gt(top:bottom,left:right,:);
    bComputeDIIVINE = true;
    for j=1:comparenumber
        img_full = imread(fullfile(imagefolder{j},sprintf('%s%s.png',fn_short,appendix_read{j})));
        crop = img_full(top:bottom,left:right,:);
        imwrite(crop, fullfile(savefolder,sprintf('%s%s_whole.png',fn_short,appendix_write{j})));
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