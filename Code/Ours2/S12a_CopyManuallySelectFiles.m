%Chih-Yuan Yang
%09/06/13
%Copy selected files from a list to a specific folder.
%In addition to S12, copy the raw image, ground truth, and input to a specific folder
clc
clear
close all
folder_pwd = pwd;
folder_filelist = 'FileList';
fn_manualselected = 'Result_Good_PubFig2_2All.txt';
arr_manual = U5c_ReadFileNameList_NoIdx_MoreComment(fullfile(folder_filelist,fn_manualselected));
num_manual = length(arr_manual);
folder_save = fullfile(folder_pwd,'Source','PubFig2_2Upfrontal_Good_ManualSelect');
folder_save_groundtruth = fullfile(folder_save,'GroundTruth');
folder_save_input = fullfile(folder_save,'input');
folder_save_raw = fullfile(folder_save,'Raw');

folder_image_source = fullfile(folder_pwd,'Source','PubFig2_2Foundable');
folder_source_groundtruth = fullfile(folder_image_source,'GroundTruth');
folder_source_input = fullfile(folder_image_source,'input');
folder_source_raw = fullfile(folder_image_source,'raw');
U22_makeifnotexist(folder_save_groundtruth);
U22_makeifnotexist(folder_save_input);
U22_makeifnotexist(folder_save_raw);
for idx_manual = 1:num_manual
    fn_manual = arr_manual{idx_manual};
    %check whether there are three underline
    set_k = strfind(fn_manual,'_');
    if length(set_k) == 3
        fn_raw = [fn_manual(1:end-2) '.png'];
    else
        fn_raw = [fn_manual '.png'];        
    end
    fn_gt = [fn_manual '.png'];
    fn_input = [fn_manual '.png'];
    
    fn_long_source = fullfile(folder_source_groundtruth,fn_gt);
    fn_long_save =  fullfile(folder_save_groundtruth,fn_gt);
    str_command = sprintf('copy %s %s',fn_long_source,fn_long_save);
    disp(str_command);
    dos(str_command);
    
    fn_long_source = fullfile(folder_source_input,fn_input);
    fn_long_save =  fullfile(folder_save_input,fn_input);
    str_command = sprintf('copy %s %s',fn_long_source,fn_long_save);
    disp(str_command);
    dos(str_command);
    
    fn_long_source = fullfile(folder_source_raw,fn_raw);
    fn_long_save =  fullfile(folder_save_raw,fn_raw);
    str_command = sprintf('copy %s %s',fn_long_source,fn_long_save);
    disp(str_command);
    dos(str_command);
end
