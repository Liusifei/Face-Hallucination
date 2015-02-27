%Chih-Yuan Yang
%4/30/13
%From PW4h, for a folder, the file looks like for Sifei's BMVC paper

clc
clear
close all
folder_dropbox = 'C:\Users\Chih-Yuan\Dropbox\vision\paper\2013\BMVC\super\manuscript\fig\results';
folder_src = fullfile(folder_dropbox,'denoise_wl_soft','Upfrontal','100');
folder_save = folder_src;
folder_groundtruth = fullfile(folder_dropbox,'GroundTruth','Upfrontal');

filelist_groundtruth = dir(fullfile(folder_groundtruth,'*.png'));
str_ext_groundtruth = '_align_crop';
num_str_ext = length(str_ext_groundtruth);
filelist_evaluate = dir(fullfile(folder_src,'*.png'));
num_files_groundtruth = length(filelist_groundtruth);
num_files_evalute = length(filelist_evaluate);

fid = fopen(fullfile(folder_save,'EvaluationResult.txt'),'w+');
fprintf(fid,'PSNR\tSSIM\tFilename\n');
for i=1:num_files_groundtruth
    fn_withext = filelist_groundtruth(i).name;
    if ~isempty(strfind(fn_withext,str_ext_groundtruth))
        fn_short = fn_withext(1:end-4-num_str_ext);
    else
        fn_short = fn_withext(1:end-4);        
    end
    img_groundtruth = imread(fullfile(folder_groundtruth,fn_withext));
    for j=1:num_files_evalute
        fn_withext_eva = filelist_evaluate(j).name;
        if ~isempty(strfind(fn_withext_eva,fn_short)) && ~isempty(strfind(fn_withext_eva,'gray'))
            img_evaluate = imread(fullfile(folder_src,fn_withext_eva));
            %compute the PSNR and SSIM, and write them into a file
            [PSNR, SSIM, ~] = F7_ComputePSNR_SSIM_DIIVINE(img_groundtruth, img_evaluate, false);
            str_output = sprintf('%0.2f\t%0.4f\t%s\n',PSNR,SSIM,fn_withext_eva);
            fprintf(fid,str_output);
            break
        end
    end
end
fclose(fid);
