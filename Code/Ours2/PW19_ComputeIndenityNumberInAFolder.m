%Chih-Yuan Yang
%10/30/12
%save gradient_component for paper writing
clc
clear
close all

codefolder = fileparts(pwd);
projectfolder = fileparts(codefolder);
addpath(genpath(fullfile(codefolder,'Lib')));
    
folder_compute = fullfile('Examples','Upfrontal3','Training');
filelist = dir(fullfile(folder_compute,'*.png'));
filenumber = length(filelist);
for i=1:filenumber
    fn_image = filelist(i).name;
    str_id = fn_image(1:3);
    id = str2double(str_id);
    idlist(id) = 1;
end
totalnumber_identity = sum(idlist);
fprintf('%d identities in this folder\n',totalnumber_identity);    