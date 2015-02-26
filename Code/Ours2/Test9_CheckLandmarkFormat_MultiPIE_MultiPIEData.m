%09/10/12
%Chih-Yuan Yang
%No title, not blue box, with numbers
%Test9 03/20/14 I need to draw points on raw training data to check the number of points at a mouth.
clc
clear
close all


folder_pwd = pwd;
folder_code = fileparts(folder_pwd);
folder_project = fileparts(folder_code);
folder_multipie = fullfile(folder_project,'Dataset','Multi-PIE');
folder_landmark = fullfile(folder_multipie,'labeled data From Ralph Gross','CorrectLandmark_051');
folder_filelist = 'FileList';
fn_filelist = 'MultiPIE_051_Effective.txt';
folder_save = fullfile('Result','Test9_DrawLandmakr_MultiPIE');
U22_makeifnotexist(folder_save);
arr_file_landmark = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_file = length(arr_file_landmark);

for idx_file=1:num_file
    %open specific file
    fn_landmark = arr_file_landmark{idx_file};
    fn_short = fn_landmark(1:end-7);
    fn_image = [fn_short '.png'];
    fn_save = [fn_short '.png'];
    if exist(fullfile(folder_save,fn_save),'file')
        fprintf('skip idx_file %d, fn_file %s\n',idx_file,fn_landmark');
        continue;
    else
        fprintf('process idx_file %d, fn_file %s\n',idx_file,fn_landmark);
    end
    
    %convert the filename string to folders
    folder_container = F46_ConvertFilenameStringToFolderString_MultiPIE(fn_landmark);
    loaddata = load(fullfile(folder_landmark,fn_landmark));
    landmark = loaddata.pts;
    img_read = imread( fullfile(folder_multipie,folder_container,fn_image) );

    bdrawnumbers = true;
    bdrawpose = false;
    str_pose = [];
    bvisible = true;
    hfig = U21b_DrawLandmarks_Points_ReturnHandle(img_read,landmark,str_pose,bdrawnumbers,bdrawpose,bvisible);
    saveas(hfig, fullfile(folder_save,fn_save));
    close(hfig);
end