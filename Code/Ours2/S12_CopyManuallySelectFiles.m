%Chih-Yuan Yang
%09/01/13
%Copy selected files from a list to a specific folder.
clc
clear
close all
folder_pwd = pwd;
folder_filelist = 'FileList';
fn_manualselected = 'Result_Good_PubFig2_2All.txt';
arr_manual = U5c_ReadFileNameList_NoIdx_MoreComment(fullfile(folder_filelist,fn_manualselected));
num_manual = length(arr_manual);
folder_save = fullfile(folder_pwd,'Result','PubFig2_2Upfrontal_Good');
folder_image_source = fullfile(folder_pwd,'Result','PubFig2_2UpfrontalAll');
U22_makeifnotexist(folder_save);
for idx_manual = 1:num_manual
    fn_manual = arr_manual{idx_manual};
    fn_long_source = fullfile(folder_image_source,sprintf('%s_Ours.png',fn_manual));
    fn_long_save =  fullfile(folder_save,sprintf('%s_Ours.png',fn_manual));
    str_command = sprintf('copy %s %s',fn_long_source,fn_long_save);
    disp(str_command);
    dos(str_command);
end
