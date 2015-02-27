%Chih-Yuan Yang
%10/03/12
%generate class list
clear
codefolder = fileparts(pwd);
addpath(genpath(fullfile(codefolder,'Lib')));
addpath(fullfile(codefolder,'Utility'));
addpath(fullfile(codefolder,'Common'));

exampleimagefolder = fullfile(codefolder,'Ours2_upfrontal','Examples','Training_Gray');
outputfolder = fullfile('Examples');
U22_makeifnotexist(outputfolder);

filelist = dir( fullfile(exampleimagefolder,'*.png') );
filenumber = length(filelist);
for i=1:filenumber
    fn_load = filelist(i).name;
    img_load_ui8_gray = imread(fullfile(exampleimagefolder,fn_load));
    img_load_double_gray = im2double(img_load_ui8_gray);
    img_small = F5_RetriveAreaGradientsByAlig
end
