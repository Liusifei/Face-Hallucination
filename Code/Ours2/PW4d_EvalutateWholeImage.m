% PW4c_EvalutateWholeImage.m
clear all; close all; clc;
addpath(genpath('\\vision-u1\Research\120801SRForFace\code\Lib'));
workingfolder = 'D:\Projects\FACE HR\Results_show\Wild';
gt_folder = fullfile(workingfolder,'Org');
gt_filelist = dir(fullfile(gt_folder,'*.png'));
method = {'Ours','Ma','Liu','JianChao','BackProjection'};

for m = 1:length(gt_filelist)
    name = gt_filelist(m).name;
    img_gt{m} = imread(fullfile(gt_folder,name));
    gt_namelist{m} = name(1:end-15);
end

for m = 1:length(method)
    input_folder = fullfile(workingfolder,method{m});
    savefile = fullfile(input_folder,'eval2.txt');
    fin = fopen(savefile,'a+');
    for n = 1:length(gt_namelist)
        tname = fullfile(input_folder,gt_namelist{n});
        fdir = dir([tname,'*.png']);
        imname = fullfile(input_folder,fdir(1).name);
        img_input = imread(imname);
        img_gtf = img_gt{n};
        [PSNR SSIM DIIVINE] = F7_ComputePSNR_SSIM_DIIVINE(img_gtf, img_input, true);
        fprintf(fin,gt_namelist{n});
        fprintf(fin,'\n');
        fprintf(fin,'PSNR: %.4d \n SSIM: %.4d \n DIIVINE: %.4d \n',PSNR, SSIM, DIIVINE);
    end
    fclose(fin);
        fprintf('Method %s Done...\n',method{m});
end