%Chih-Yuan Yang
%08/17/13
%Generate filelist
%The file is copied from project SISRBenchmark
%PP1a: generate new list from existing list
clc
clear
close all
folder_filelist_original = fullfile('Source','FileList');
fn_filelist_original = 'TrainingImage2184Upfrontal.txt';

folder_filelist_save = 'FileList';
fn_filelist_save = 'TrainingImage2184Upfrontal3_1HighContrast.txt';

U22_makeifnotexist(fn_filelist_save);
arr_filename = U5_ReadFileNameList(fullfile(folder_filelist_original,fn_filelist_original));
num_files = length(arr_filename);
fid = fopen(fullfile(folder_filelist_save,fn_filelist_save),'w+');
for idx_file=1:num_files
    fn_original = arr_filename{idx_file};
    fn_short = fn_original(1:end-4);
    fn_no_illuminationnumber = fn_short(1:end-3);
    fn_new = [fn_no_illuminationnumber '_13.png'];
    fprintf(fid,'%d %s\n',idx_file,fn_new);
end
fclose(fid);
