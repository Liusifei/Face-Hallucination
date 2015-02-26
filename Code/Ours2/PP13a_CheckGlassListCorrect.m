%Chih-Yuan Yang
%08/18/13
%generate class list
%PP13a: slightly modify the code because I changed the name and path of glasslist and images
clear
clc
close all

folder_exampleimages = fullfile('Examples','Upfrontal3_1HighContrast','High');
folder_glasslist = 'FileList';
fn_glasslist = 'GlassList_Upfrontal3_1HighContrast_Example_2167.txt';
folder_ourput_glass = fullfile('Examples','Upfrontal3_1HighContrast','VerifyGlassList','Glass');
folder_ourput_noglass = fullfile('Examples','Upfrontal3_1HighContrast','VerifyGlassList','NoGlass');
U22_makeifnotexist(folder_ourput_glass);
U22_makeifnotexist(folder_ourput_noglass);

%open glass list file
[arr_filename, arr_glasslabel] = U5a_ReadGlassList(fullfile(folder_glasslist,fn_glasslist));
num_files = length(arr_filename);

for idx_file=1:num_files
    fn_copy = arr_filename{idx_file};
    if arr_glasslabel(idx_file) == 0
        strcmd = sprintf('copy %s %s',fullfile(folder_exampleimages,fn_copy), fullfile(folder_ourput_noglass,fn_copy));
    else
        strcmd = sprintf('copy %s %s',fullfile(folder_exampleimages,fn_copy), fullfile(folder_ourput_glass,fn_copy));
    end
    dos(strcmd);
end
