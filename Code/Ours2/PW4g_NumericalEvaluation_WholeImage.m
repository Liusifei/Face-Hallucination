%Chih-Yuan Yang
%11/08/12
%the parameters of folder are still being set, not finished.

clc
clear
close all
codefolder = fileparts(pwd);
workingfolder = pwd;
addpath(genpath(fullfile(codefolder,'Lib')));

iistart = 1;
iiend = 1;

savefolder = fullfile('Comparison','Wild2','Ev1_1');

imagefolder_ref = fullfile('Result','Wild2ark1','Tuning1','GeneratedImages');
appendix_ref = '_Glasner.png';
imagefolder_gt = fullfile(codefolder,'Ours','Source','Benchmark','GroundTruth');
k=0;
k=k+1;imagefolder{k} = fullfile(codefolder,'BackProjection','Result','Benchmark1','Tuning1','GeneratedImages');
k=k+1;imagefolder{k} = fullfile(codefolder,'Sun08','Result','Benchmark1','Tuning2','GeneratedImages');
k=k+1;imagefolder{k} = fullfile(codefolder,'Ours','Result','Benchmark1','Tuning4','GeneratedImages');
k=k+1;imagefolder{k} = imagefolder_gt;
k=k+1;imagefolder{k} = fullfile(codefolder,'Shan08','Result','Benchmark1','Tuning1','GeneratedImages');
k=k+1;imagefolder{k} = fullfile(codefolder,'Jianchao08','Result','Benchmark1','Tuning1','GeneratedImages');
k=k+1;imagefolder{k} = fullfile(codefolder,'Wang12','Result','Benchmark1','Tuning1','GeneratedImages');
k=k+1;imagefolder{k} = fullfile(codefolder,'Freedman11','Result','Benchmark1','Tuning1','GeneratedImages');
k=k+1;imagefolder{k} = fullfile(codefolder,'Glasner','Result','Benchmark1','Tuning1','GeneratedImages');

k=0;
k=k+1;appendix_read{k} = '_backprojection_1_1.png';
k=k+1;appendix_read{k} = '_Sun08_1_2.png';
k=k+1;appendix_read{k} = '_Ours_1_4.png';
k=k+1;appendix_read{k} = '.bmp';
k=k+1;appendix_read{k} = '_Shan08.png';
k=k+1;appendix_read{k} = '_Jianchao_1_1.png';
k=k+1;appendix_read{k} = '_Wang12_1_1.png';
k=k+1;appendix_read{k} = '_Freedman11_1_1.png';
k=k+1;appendix_read{k} = '_Glasner.png';
groundtruthfileext = '.bmp';
k=0;
k=k+1;appendix_write{k} = '_backprojection_1_1';
k=k+1;appendix_write{k} = '_Sun08_1_2';
k=k+1;appendix_write{k} = '_Ours_1_4';
k=k+1;appendix_write{k} = '_GroundTruth';
k=k+1;appendix_write{k} = '_Shan08';
k=k+1;appendix_write{k} = '_Yang08_1_1';
k=k+1;appendix_write{k} = '_Wang12_1_1';
k=k+1;appendix_write{k} = '_Freedman11_1_1';
k=k+1;appendix_write{k} = '_Glasner';
k=0;
k=k+1;methodname{k} = 'Irani91';
k=k+1;methodname{k} = 'Sun08';
k=k+1;methodname{k} = 'Proposed';
k=k+1;methodname{k} = 'GroundTruth';
k=k+1;methodname{k} = 'Shan08';
k=k+1;methodname{k} = 'Yang08';
k=k+1;methodname{k} = 'Wang12';
k=k+1;methodname{k} = 'Freedman11';
k=k+1;methodname{k} = 'Glasner09';

computeddatafolder = fullfile(workingfolder,'Comparison','Benchmark','ComputedData');

%common, after setting
U22_makeifnotexist(savefolder);
U22_makeifnotexist(computeddatafolder);
filelist = dir(fullfile(imagefolder_ref,'*.png'));
%filelist = F23_SortFileListByNumber(filelist,appendix_read{1}(1:end-4));
filenumber = length(filelist);
comparenumber = length(methodname);
PSNRlist = zeros(comparenumber,1);
SSIMlist = zeros(comparenumber,1);
DIIVINElist = zeros(comparenumber,1);
appendlength = length(appendix_ref);
if isa(iiend,'char')
    if strcmp(iiend,'all')
        iiend = filenumber;
    end
end
for i=iistart:iiend
    %open specific file
    fn_ours = filelist(i).name;
    fn_short = fn_ours(1:end-appendlength);
    fprintf('processing %s (%d of total %d)\n',fn_short,i,filenumber);

    img_ours = imread(fullfile(imagefolder{1},sprintf('%s%s',fn_short,appendix_read{1})));
    [h, w, d] = size(img_ours);
    left = 1;
    right = w;
    top = 1;
    bottom = h;
    height = bottom - top + 1;
    width = right - left + 1;

    
    img_gt = imread(fullfile(imagefolder_gt,sprintf('%s%s',fn_short,groundtruthfileext)));
    img_gt_crop = img_gt(top:bottom,left:right,:);
    bComputeDIIVINE = true;    
    for j=1:comparenumber
        img_full = imread(fullfile(imagefolder{j},sprintf('%s%s',fn_short,appendix_read{j})));
        crop = img_full(top:bottom,left:right,:);
        imwrite(crop, fullfile(savefolder,sprintf('%s%s.png',fn_short,appendix_write{j})));        
        fn_computeddatafilename = sprintf('%s%s',fn_short,appendix_read{j});
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
    fid = fopen(fullfile(savefolder,sprintf('%s_Ev.txt',fn_short)),'w');
    fprintf(fid,sprintf('%d %d %d %d\n',top,left,height,width));
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
    fn_save = sprintf('%s_Ev.mat',fn_short);
    save(fullfile(savefolder,fn_save),'result');
end