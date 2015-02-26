%Chih-Yuan Yang
%2/8/15
%PP19: Generate JPEG compressed wild faces images

clc
clear
close all

folder_filelist = 'FileList';
%fn_filelist = 'PubFig2_2Foundable.txt';
%folder_source = fullfile('Source','PubFig2_2Foundable','input');
%folder_save = fullfile('Source','PubFig2_2Foundable','JPEGCompressed');
fn_filelist = 'NonUpfrontal3.txt';
folder_source = fullfile('Source','NonUpfrontal3','input');
folder_save = fullfile('Source','NonUpfrontal3','JPEGCompressed');
U22_makeifnotexist(folder_save);

arr_filename = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_file = length(arr_filename);
for idx_file = 1:num_file
    fn_test = arr_filename{idx_file};
    fn_short = fn_test(1:end-4);
    img = im2double(imread( fullfile(folder_source, fn_test)) );     %There is no para.SourceFile
    for Q=25:25:100
        fn_save = sprintf('%s_Q%d.jpg',fn_short,Q);
        imwrite(img,fullfile(folder_save,fn_save),'Quality',Q);
        fprintf('%s\n',fn_save)
    end
end