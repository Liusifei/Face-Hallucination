%Chih-Yuan Yang
%08/18/13
%This file requires UCI face landmark algroithm and only can run on Linux
%PP3a: slightly change the file because I change the path of image folders
%Test7 03/20/14 I need to figure out the difference between landmark formats of the Multi-PIE and IntraFace
clc
clear
close all

folder_code = fileparts(pwd);
addpath(genpath(fullfile(folder_code,'Lib')));

sf = 4;
folder_image_test = fullfile('Source','JANUSProposal','input');
folder_landmark_save = fullfile('Result','Test7_CheckLandmarkFormat');
fn_filelist = 'JANUSProposalReady.txt';
idx_file_start = 1;


U22_makeifnotexist(folder_landmark_save);
folder_filelist = 'FileList';
arr_filename = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_files = length(arr_filename);

idx_file_end = num_files;
for idx_file = idx_file_start:idx_file_end
    %open specific file
    fn_testfile = arr_filename{idx_file};
    fprintf('idx_file %d, fn_testfile %s\n',idx_file,fn_testfile);
    sourcefile = fullfile(folder_image_test,fn_testfile);
    img_lr = im2double(imread( sourcefile) );

    img_hr_bb = imresize(img_lr,sf);
    %bicubic interpolation generates some values less than 0 or greater
    %than 1. We need to clear them.
    img_hr_tolabel = img_hr_bb;
    img_hr_tolabel(img_hr_bb > 1) = 1;
    img_hr_tolabel(img_hr_bb < 0) = 0;

    %apply the detection algorithm
    modelname = 'mi';
    bs = [];
    try
        [bs, posemap] = F2_ReturnLandmarks(img_hr_tolabel,modelname);
    catch err
        continue
    end
    
    if ~isempty(bs)           %sometimes be is empty if the threshold is high
        hfig = figure('Visible','off');
        fn_testfile_short = fn_testfile(1:end-4);
        %Do not show blue boxes, only show red landmark points
        bshownumbers = true;
        bdrawpose = true;
        U21_DrawLandmarks(img_hr_tolabel, bs,posemap,bshownumbers,bdrawpose);
        %record the bs
        fnsave = fullfile(folder_landmark_save,sprintf('%s_%s.mat',fn_testfile_short, modelname));
        save(fnsave,'bs','posemap');
        fnsave = fullfile(folder_landmark_save,sprintf('%s_%s.png',fn_testfile_short, modelname));
        saveas(hfig, fnsave);
        close(hfig);
    end
end