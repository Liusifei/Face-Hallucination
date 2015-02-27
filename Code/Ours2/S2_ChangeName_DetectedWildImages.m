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
savefolder = fullfile(codefolder,'Ours2_upfrontal','Temp','DetectedLandmarks','Wild1_BBImage_correct');
U22_makeifnotexist(savefolder);
filelist = dir(fullfile(detectedfolder,'*.png'));
filenumber = length(filelist);
for i=1:filenumber
    fn_png = filelist(i).name;
    fn_short = fn_png(1:end-4);
    fn_mat = [fn_short '.mat'];
    k = strfind(fn_short,'_');
    firstname = fn_short(1:k(1)-1);
    lastname = fn_short(k(1)+1:k(2)-1);
    photoindex_str = fn_short(k(2)+1:k(3)-1);
    photoidx = str2double(photoindex_str);
    fn_new_png = sprintf('%s_%s_%04d_mi.png',firstname,lastname,photoidx);
    fn_new_mat = sprintf('%s_%s_%04d_mi.mat',firstname,lastname,photoidx);
    strcmd = sprintf('copy %s %s',fullfile(detectedfolder,fn_png),fullfile(savefolder,fn_new_png));
    dos(strcmd);
    strcmd = sprintf('copy %s %s',fullfile(detectedfolder,fn_mat),fullfile(savefolder,fn_new_mat));
    dos(strcmd);
end
