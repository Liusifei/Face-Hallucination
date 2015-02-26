%Chih-Yuan Yang
%09/01/13
%Verify the manually selected list and create a list for testing
%S9a: add some more controls because the manually selected list may contain comments
clc
clear
close all
folder_filelist = 'FileList';
fn_manualselected = 'Result_Good_PubFig2_2All.txt';
fn_acceptednamelist = 'PubFig_Labeled_Upfrontal_6398.txt';      %all file names have to be included in this list
fn_savelist = 'Result_Good_PubFig2_2All_Verified.txt';
arr_accepted = U5_ReadFileNameList(fullfile(folder_filelist,fn_acceptednamelist));
arr_manual = U5c_ReadFileNameList_NoIdx_MoreComment(fullfile(folder_filelist,fn_manualselected));
num_manual = length(arr_manual);
num_accepted = length(arr_accepted);
fid = fopen(fullfile(folder_filelist, fn_savelist),'w+');
for idx_manual = 1:num_manual
    fn_manual = arr_manual{idx_manual};
    bfound = false;
    for idx_accepted = 1:num_accepted
        fn_accepted = arr_accepted{idx_accepted}(1:end-4);
        if strcmp(fn_accepted,fn_manual)
            bfound = true;
            %fprintf(fid,'Find %s\n',fn_manual);
            break;
        end
    end
    if bfound == false
        fprintf(fid,'Not find %s\n',fn_manual);
    end
end
fclose(fid);