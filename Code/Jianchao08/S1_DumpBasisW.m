%Chih-Yuan Yang
%10/30/12
%Dump basisW for website
clear;
close all
clc;

codefolder = fileparts(pwd);
folder_exampleimages = fullfile(codefolder,'Ours2','Examples','Upfrontal3','Training');
fileext = '.png';
exampleMATfolder = fullfile(codefolder,'Ours2','Examples','Upfrontal3','PreparedMatForLoad');
fn_exampleMAT = 'ExampleDataForLoad.mat';
addpath(fullfile(codefolder,'Ours2'));
folder_save = fullfile('Data','Upfrontal3','s4','BasisWDump');
folder_basisW = fullfile('Data','Upfrontal3','s4');
fn_basisW = 'TempDHWi_setting1.mat';
U22_makeifnotexist(folder_save);

%load the basisW
loaddata = load(fullfile(folder_basisW,fn_basisW),'W');
basisW = loaddata.W / 255;            %the training range is 0~255, so here it needs to be devided by 255
clear loaddata

%load training image
loaddata = load(fullfile(exampleMATfolder,fn_exampleMAT),'exampleimages_hr','exampleimages_lr');
exampleimages_hr = loaddata.exampleimages_hr;
[h_hr, w_hr] = size(exampleimages_hr(:,:,1));
clear loaddata exampleimages_hr

for idx = 1:3
    img_basis = reshape(basisW(:,idx),[h_hr,w_hr]);
    img_basis_adjust = img_basis/max(img_basis(:))*3;
    %save the result
    fn_save = sprintf('Basis%04d.png',idx);
    imwrite(img_basis_adjust,fullfile(folder_save,fn_save));
end