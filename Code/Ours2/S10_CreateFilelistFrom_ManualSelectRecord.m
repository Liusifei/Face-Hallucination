%Chih-Yuan Yang
%08/24/13
%To create a list for high contrast facial illumination
clc
clear
close all
folder_filelist = 'FileList';
fn_manualselected = 'FrontalFace_LeftIllumination_ManualSelectRecord.txt';
fn_savelist = 'FrontalFace_LeftIllumination.txt';
arr_manual = U5b_ReadFileNameList_NoIdx_Comment(fullfile(folder_filelist,fn_manualselected));
U1a_CreateFilelistFromArr(fullfile(folder_filelist,fn_savelist),arr_manual);