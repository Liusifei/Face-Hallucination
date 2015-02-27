%Chih-Yuan Yang
%08/18/13
%Generate filelist
%This file does not generate list sorted by file extension, but sorted by name and filter out by file
%extension
clc
clear
close all

% folder_source = fullfile('Source','Upfrontal3','Input','25_50_75_100');
% fn_save = 'MultiPIE_Upfrontal_Compressed_25_50_75_100.txt';
% set_ext = {'.jpg'};
%folder_source = fullfile('Source','PubFig2_2Foundable','JPEGCompressed');
%fn_save = 'PubFig2_2Foundable_JPEGCompressed25_50_75_100.txt';
%set_ext = {'.jpg'};
%folder_source = fullfile('Source','Upfrontal3','GroundTruth');
%fn_save = 'PubFig2_2Foundable_JPEGCompressed25_50_75_100.txt';
%set_ext = {'.jpg'};
%folder_source = fullfile('Source','NonUpfrontal3','GroundTruth');
%fn_save = 'NonUpfrontal3.txt';
%set_ext = {'.png'};
%folder_source = fullfile('Source','NonUpfrontal3','Input','JPEGCompressed');
%fn_save = 'NonUpfrontal3_JPEGCompressed.txt';
%set_ext = {'.jpg'};
folder_source = fullfile('Examples','NonUpfrontal3','Training');
fn_save = 'NonUprightFrontal_Training274.txt';
set_ext = {'.png'};


folder_filelist = 'FileList';
num_ext = length(set_ext);

U22_makeifnotexist(folder_filelist);
fid = fopen(fullfile(folder_filelist,fn_save),'w+');
list_file_all = dir(folder_source);
num_files = length(list_file_all);
idx_save = 0;
for idx_file = 1:num_files
    fn_read = list_file_all(idx_file).name;
    set_location_dot = strfind(fn_read,'.');
    location_dot = set_location_dot(end);
    str_ext = fn_read(location_dot:end);
    for j=1:num_ext
        if strcmp(str_ext,set_ext{j})
            idx_save = idx_save+1;
            fprintf(fid,'%d %s\n',idx_save,fn_read);
        end
    end
end
fclose(fid);
