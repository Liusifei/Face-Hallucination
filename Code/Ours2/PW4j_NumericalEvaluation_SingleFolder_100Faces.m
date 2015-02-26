%Chih-Yuan Yang
%8/13/13
%From PW4i, for a folder, I need to evaluate 100 face images for PAMI

clc
clear
close all
folder_code = fileparts(pwd);
addpath(genpath(fullfile(folder_code,'Lib')));
folder_source = fullfile('Result','Upfrontal3','Tuning1','GeneratedImages');
folder_save = fullfile('Result','PaperWriting1_PAMI');
folder_groundtruth = fullfile('Source','Upfrontal3','GroundTruth');
folder_filenamelist = fullfile('Source','FileList');
fn_filenamelist = 'PAMI100.txt';

%load the filelist
list_filename = U5_ReadFileNameList(fullfile(folder_filenamelist,fn_filenamelist));

str_ext_filelist = '_align_crop.png';
str_ext_groundtruth = '_align_crop.png';
num_ext_filelist = length(str_ext_filelist);
str_appendix_evaluated = '_Ours_3_1.png';
num_file = length(list_filename);
arr_PSNR = zeros(num_file,1);
arr_SSIM = zeros(num_file,1);
arr_DIIVINE = zeros(num_file,1);

for idx_file = 1:num_file
    fn_list = list_filename{idx_file};
    fn_short = fn_list(1:end-num_ext_filelist);
    fn_groundtruth = [fn_short str_ext_groundtruth];
    img_groundtruth = im2double(imread(fullfile(folder_groundtruth,fn_groundtruth)));
    
    fn_evaluate = [fn_short str_appendix_evaluated];
    img_evaluate = im2double(imread(fullfile(folder_source,fn_evaluate)));
    bComputeDIIVINE = true;
    [PSNR, SSIM, DIIVINE] = F7_ComputePSNR_SSIM_DIIVINE(img_groundtruth, img_evaluate, bComputeDIIVINE);
    arr_PSNR(idx_file) = PSNR;
    arr_SSIM(idx_file) = SSIM;
    arr_DIIVINE(idx_file) = DIIVINE;
end
%the saved
fn_save = 'Upfrontal3_100face.mat';
fn_full = fullfile(folder_save,fn_save);
save(fn_full,'arr_PSNR','arr_SSIM','arr_DIIVINE','list_filename');
%write the mean
mean_PSNR = mean(arr_PSNR);
mean_SSIM = mean(arr_SSIM);
mean_DIIVINE = mean(arr_DIIVINE);
fn_save = 'Upfrontal3_100face_mean.txt';
fid = fopen(fullfile(folder_save,fn_save),'w+');
fprintf(fid,'mean_PSNR %0.2f\n', mean_PSNR');
fprintf(fid,'mean_SSIM %.4f\n', mean_SSIM');
fprintf(fid,'mean_DIIVINE %2.2f\n', mean_DIIVINE');
fclose(fid);
