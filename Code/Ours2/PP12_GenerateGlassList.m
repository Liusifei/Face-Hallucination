%Chih-Yuan Yang
%10/19/12
%generate class list
clear
codefolder = fileparts(pwd);
addpath(genpath(fullfile(codefolder,'Lib')));

exampleimagefolder = fullfile('Examples','NonUpfrontal3','Training');
outputfolder = fullfile('Examples','NonUpfrontal3');
fn_save = 'GlassList.txt';
U22_makeifnotexist(outputfolder);
bchangenamereorder = true;

filelist = dir( fullfile(exampleimagefolder,'*.png') );
filenumber = length(filelist);
filelist_name = cell(filenumber,1);
for i=1:filenumber
    filelist_name{i} = filelist(i).name;
end
fn_write = fullfile(outputfolder,fn_save);
U27_CreateSymphonyFile(fn_write,filenumber,filelist_name);