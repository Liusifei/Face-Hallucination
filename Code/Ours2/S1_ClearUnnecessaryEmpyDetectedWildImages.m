%Chih-Yuan Yang
%10/03/12
%Clear the unnecessary images in wild
clc
clear
close all

codefolder = fileparts(pwd);
addpath(genpath(fullfile(codefolder,'Lib')));
addpath(fullfile(codefolder,'Utility'));
addpath(fullfile(codefolder,'Common'));

detectedfolder = fullfile(codefolder,'Ours2_upfrontal','Temp','DetectedLandmarks','Wild1_BBImage');
filelist = dir(fullfile(detectedfolder,'*.png'));
filenumber = length(filelist);
for i=1:filenumber
    fn_png = filelist(i).name;
    fn_short = fn_png(1:end-4);
    fn_mat = [fn_short '.mat'];
    if ~exist(fullfile(detectedfolder,fn_mat),'file')
        strcmd = sprintf('del %s',fullfile(detectedfolder,fn_png));
        dos(strcmd);
    end
end
