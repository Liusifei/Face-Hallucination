%Chih-Yuan Yang
%08/17/13
%Copy the test images for highly illumination contrasted faces from Multi-PIE to the project folder
%to run tests for PAMI
%S5b: the filelist is correct, no str_highconstrast_appendix is required.
%Why are there only 2167 images? Which files are missing?
folder_multipli = 'D:\Documents\Research\Datasets\Face\Multi-Pie';     %MultiPIE
folder_filelist = 'FileList';

%case Upfrontal3_1 exemplar
fn_filelist = 'TrainingImage2184Upfrontal3_1HighContrast.txt';
folder_dst = fullfile('Examples','Upfrontal3_1HighContrast','Raw');

%according to the file list, copy the raw files to the destination folder, but choose 15_01
arr_filelist = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_files = length(arr_filelist);

for idx_file = 1:num_files
    fn_read = arr_filelist{idx_file};
    str_identity = fn_read(1:3);
    str_session = fn_read(5:6);
    str_expression = fn_read(8:9);
    str_cameraposition = fn_read(11:13);        %in filename, it is 051; in folder, it is 05_1
    str_illumination = fn_read(15:16);
    %according to the data, to find the correct folder
    folder_session = sprintf('session%s',str_session);
    folder_multiview = fullfile(folder_multipli,'data',folder_session,'multiview');
    folder_identity = fullfile(folder_multiview,str_identity);
    folder_expression = fullfile(folder_identity,str_expression);
    folder_cameraposition = fullfile(folder_expression,[str_cameraposition(1:2) '_' str_cameraposition(3)]);
    fn_source = sprintf('%s_%s_%s_%s_%s.png',str_identity,str_session,str_expression,str_cameraposition,str_illumination);
    str_command = sprintf('copy %s %s',fullfile(folder_cameraposition,fn_source),fullfile(folder_dst,fn_source));
    dos(str_command);
end
