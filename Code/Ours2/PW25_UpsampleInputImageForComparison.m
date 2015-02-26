%1/27/2015
%PW25 Upsample input images for comparsion
clc
clear
close all
folder_Ours = pwd;
folder_save = fullfile('Result',mfilename);
folder_filelist = 'Filelist';
Quality = 100;

switch Quality
    case 25
        fn_filelist = 'Upfrontal3_342_Q25.txt';
        folder_test = fullfile('Source','Upfrontal3','Input','25');
    case 50
        fn_filelist = 'Upfrontal3_342_Q50.txt';
        folder_test = fullfile('Source','Upfrontal3','Input','50');
    case 75
        fn_filelist = 'Upfrontal3_342_Q75.txt';
        folder_test = fullfile('Source','Upfrontal3','Input','75');
    case 100
        fn_filelist = 'Upfrontal3_342_Q100.txt';
        folder_test = fullfile('Source','Upfrontal3','Input','100');
end
idx_file_start = 54;
idx_file_end = 54;
sf = 4;
U22_makeifnotexist(folder_save);
arr_filename = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_file = length(arr_filename);
if isa(idx_file_end,'char')
    if strcmp(idx_file_end,'all')
        idx_file_end = num_file;
    end
end
for fileidx=idx_file_start:idx_file_end
    %open specific file
    fn_test = arr_filename{fileidx};
    fn_short = fn_test(1:end-4);
    fprintf('fileidx %d, fn_test %s\n',fileidx,fn_test);
    img_lr_load_ui8 = imread(fullfile(folder_test,fn_test));
    img_hr_nearestneighbor = imresize(img_lr_load_ui8,sf,'nearest');
    fn_save = [fn_short '_nearestneighbor.png'];
    imwrite(img_hr_nearestneighbor, fullfile(folder_save,fn_save));
end