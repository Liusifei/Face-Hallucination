%Chih-Yuan Yang
%08/18/13
%Generate the glass list for Upfrontal3_1 from Upfrontal3, because the exemple sets are slightly
%different. The Upfrontal3_1 has fewer images. Some images in the Upfrontal3 set are redundent
%because of multiple illumination.

clear
clc
close all

folder_glasslist_all = 'FileList';
fn_glasslist_all = 'GlassList_Upfrontal_All_2526.txt';
folder_filelist_compare = 'FileList';
fn_filelist_compare = 'TrainingImage2167Upfrontal3_1HighContrast.txt';
folder_save = 'FileList';
fn_save = 'GlassList_Upfrontal3_1HighContrast_Example_2167.txt';

U22_makeifnotexist(folder_save);

%load glass list
[arr_filename_all, arr_glasslabel_all] = U5a_ReadGlassList(fullfile(folder_glasslist_all,fn_glasslist_all));
num_files_all = length(arr_filename_all);

%load compared filelist
arr_filename_check = U5_ReadFileNameList(fullfile(folder_filelist_compare,fn_filelist_compare));
num_files_check = length(arr_filename_check);

%prepare the file to write
fid = fopen(fullfile(folder_save,fn_save),'w+');

for idx_file_check = 1:num_files_check
    fn_check = arr_filename_check{idx_file_check};
    fn_check_short = fn_check(1:end-4);
    fn_check_no_illumination = fn_check_short(1:end-3);
    
    %check the glass lable    
    val_glasslabel = nan;
    for j=1:num_files_all
        fn_known = arr_filename_all{j};
        fn_known_short = fn_known(1:end-4);
        fn_known_no_illumination = fn_known_short(1:end-3);
        if strcmp(fn_known_no_illumination, fn_check_no_illumination)
            val_glasslabel = arr_glasslabel_all(j);
            break;
        end
    end
    fprintf(fid,'%05d %s %d\n',idx_file_check,fn_check,val_glasslabel);
end
fclose(fid);
