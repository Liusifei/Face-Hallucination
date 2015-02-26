%Chih-Yuan Yang
%10/29/12
%Rename a folder
clc
clear
close all

folder_Code = fileparts(pwd);
%folder_work = fullfile(pwd,'Source','Upfrontal3','Input');
%folder_work = fullfile(pwd,'Examples','Upfrontal3','Training');
%folder_work = fullfile(pwd,'Examples','Upfrontal3','Landmarks');
%folder_work = fullfile(pwd,'Temp','DetectedLandmarks','Upfrontal3');
%folder_work = fullfile(codefolder,'Jianchao08','Data','Upfrontal3','s4','Reconstructed');
%folder_work = fullfile(folder_Code,'Ours2','Source','Upfrontal3','Input','100');
%folder_work = fullfile(folder_Code,'Ours2','Source','Upfrontal3','GroundTruth');
folder_work = 'F:\Documents\Task2';
filelist = dir(fullfile(folder_work,'face_traning*.png'));
filenumber = length(filelist);
str_remove = 'traning';
str_substitute = 'training';
for i=1:filenumber
    fn_original = filelist(i).name;
    fn_new = strrep(fn_original, str_remove, str_substitute);
    strcmd = sprintf('rename %s %s',fullfile(folder_work,fn_original),fn_new);
    dos(strcmd);
end
