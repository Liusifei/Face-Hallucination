%Chih-Yuan Yang
%08/17/13
%Some files in a filelist are missed in S5b, find them
%Is the filelist wrong? Are some of them repeated?
folder_multipli = 'D:\Documents\Research\Datasets\Face\Multi-Pie';     %MultiPIE
folder_filelist = 'FileList';

%case Upfrontal3_1 exemplar
fn_filelist = 'TrainingImage2184Upfrontal3_1HighContrast.txt';
folder_search = fullfile('Examples','Upfrontal3_1HighContrast','Raw');

%according to the file list, copy the raw files to the destination folder, but choose 15_01
arr_filelist = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_files = length(arr_filelist);

for idx_file = 1:num_files
    fn_read = arr_filelist{idx_file};
    if ~exist(fullfile(folder_search,fn_read),'file')
        fprintf('Missing %s\n',fn_read); 
    end
end
