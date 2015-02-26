%Chih-Yuan Yang
%2/6/15
%From PW4i, for a folder, I need to evaluate 100 face images for PAMI
%PW4k: For the PAMI website, I need to evaluate a lot images.

clc
clear
close all
folder_code = fileparts(pwd);
addpath(genpath(fullfile(folder_code,'Lib')));
compared_case = 'MultiPIE_non_upright_frontal';
switch compared_case
    case 'MultiPIE_upright_frontal'
        folder_groundtruth = fullfile('Source','Upfrontal3','GroundTruth');
        folder_filenamelist = fullfile('FileList');
        fn_filelist = 'Upfrontal3_342_png.txt';
        array_folder_result = cell(5,1);
        array_legend = cell(5,1);
        array_folder_result{1} = fullfile(folder_code,'Liu07IJCV','Result','Test5_PAMI_Website');
        array_legend{1} = 'Liu07_test5';
        array_folder_result{2} = fullfile(folder_code,'Jianchao08','Result','Test5_PAMI_Website');
        array_legend{2} = 'Yang08_test5';
        array_folder_result{3} = fullfile(folder_code,'Ma10','Result','Test2_PAMI_website');
        array_legend{3} = 'Ma10_test2';
        array_folder_result{4} = fullfile(folder_code,'Ours2','Result','Test20_CVPR13_PAMI_website');
        array_legend{4} = 'Yang13_test20';
        array_folder_result{5} = fullfile(folder_code,'Ours2','Result','Test18_CompressedFaceHallucinationOnLinux');
        array_legend{5} = 'UCI_test18';
        folder_save = fullfile('Result','Test21_Evaluation_Compressed_Face');
        fn_save = 'NumericalEvaluation.txt';
    case 'MultiPIE_non_upright_frontal'
        folder_groundtruth = fullfile('Source','NonUpfrontal3','GroundTruth');
        folder_filenamelist = fullfile('FileList');
        fn_filelist = 'NonUpfrontal3.txt';
        array_folder_result = cell(5,1);
        array_legend = cell(5,1);
        array_folder_result{1} = fullfile(folder_code,'Liu07IJCV','Result','Test6_PAMI_website_non_upright_frontal');
        array_legend{1} = 'Liu07_test6';
        array_folder_result{2} = fullfile(folder_code,'Jianchao08','Result','Test6_PAMI_website_non_upright_frontal');
        array_legend{2} = 'Yang08_test6';
        array_folder_result{3} = fullfile(folder_code,'Ma10','Result','Test3_PAMI_website_non_upright_frontal');
        array_legend{3} = 'Ma10_test3';
        array_folder_result{4} = fullfile(folder_code,'Ours2','Result','Test24_CVPR13_PAMI_website_non_upright_frontal');
        array_legend{4} = 'Yang13_test24';
        array_folder_result{5} = fullfile(folder_code,'Ours2','Result','Test23_SifeiCompressedFaceHallucination_NonUprightFrontal');
        array_legend{5} = 'UCI_test23';
        folder_save = fullfile('Result','Test21_Evaluation_Compressed_Face');
        fn_save = 'NumericalEvaluation_MultiPIE_non_upright_frontal.txt';
        
end
U22_makeifnotexist(folder_save);

%load the filelist
arr_filename = U5_ReadFileNameList(fullfile(folder_filenamelist,fn_filelist));

num_file = length(arr_filename);
arr_PSNR = zeros(5,1);
arr_SSIM = zeros(5,1);

fid = fopen(fullfile(folder_save,fn_save), 'w+');
for idx_file = 1:num_file
    fprintf('idx_file %d\n', idx_file);
    fn_groundtruth = arr_filename{idx_file};
    fn_short = fn_groundtruth(1:end-4);
    img_groundtruth = im2double(imread(fullfile(folder_groundtruth,fn_groundtruth)));
    fprintf(fid,'\nfilename: %s\n', fn_groundtruth);
    for Quality = 25:25:100
        fprintf(fid,'Q=%d\n', Quality);
        for index_method = 1:5
            fn_evaluate = sprintf('%s_Q%d_%s.png',fn_short, Quality, array_legend{index_method});
            filname_read = fullfile(array_folder_result{index_method},fn_evaluate);
            %initial 
            PSNR = 0;
            SSIM = 0;
            if exist(filname_read,'file')
                fileinfo = dir(filname_read);
                if fileinfo(1).bytes ~= 0
                    img_evaluate = im2double(imread(fullfile(array_folder_result{index_method},fn_evaluate)));
                    bComputeDIIVINE = false;
                    [PSNR, SSIM, DIIVINE] = F7_ComputePSNR_SSIM_DIIVINE(img_groundtruth, img_evaluate, bComputeDIIVINE);
                end
            end
            arr_PSNR(index_method) = PSNR;
            arr_SSIM(index_method) = SSIM;
        end
        fprintf(fid,'PSNR\n');
        [~,index_max] = max(arr_PSNR);
        for index_method = 1:5
            if index_method == index_max
                fprintf(fid,'\t<!--%s--><td><b>%.2f</b></td>\n', array_legend{index_method}, arr_PSNR(index_method));
            else
                fprintf(fid,'\t<!--%s--><td>%.2f</td>\n', array_legend{index_method}, arr_PSNR(index_method));
            end
        end        
        
        [~,index_max] = max(arr_SSIM);        
        fprintf(fid,'SSIM\n');
        for index_method = 1:5
            if index_method == index_max
                fprintf(fid,'\t<!--%s--><td><b>%.04f</b></td>\n', array_legend{index_method}, arr_SSIM(index_method));
            else
                fprintf(fid,'\t<!--%s--><td>%.04f</td>\n', array_legend{index_method}, arr_SSIM(index_method));
            end
        end        
    end
end
fclose(fid);


