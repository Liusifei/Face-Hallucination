%Chih-Yuan Yang
%08/24/13
%Verify the manually selected list and create a list for testing
clc
clear
close all
folder_filelist = 'FileList';
fn_manualselected = 'FrontalFace_LeftIllumination_ManualSelectRecord.txt';
fn_acceptednamelist = 'PubFig_Readable_12077.txt';      %all file names have to be included in this list
fn_savelist = 'FrontalFace_LeftIllumination.txt';
arr_manual = U5b_ReadFileNameList_NoIdx_Comment(fullfile(folder_filelist,fn_manualselected));
arr_accepted = U5_ReadFileNameList(fullfile(folder_filelist,fn_acceptednamelist));
num_manual = length(arr_manual);
num_accepted = length(arr_accepted);
for idx_manual = 1:num_manual
    fn_manual = arr_manual{idx_manual};
    bfound = false;
    for idx_accepted = 1:num_accepted
        fn_accepted = arr_accepted{idx_accepted};
        if strfind(fn_accepted,fn_manual)
            bfound = true;
            fprintf('Find %s\n',fn_manual);
            break;
        end
    end
    if bfound == false
        fprintf('Not find %s\n',fn_manual);
    end
end