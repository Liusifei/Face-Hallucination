%Chih-Yuan Yang
%11/07/12
%Rename a folder
clc
clear
close all

folder_code = fileparts(pwd);
%folder_work = fullfile(pwd,'Source','Upfrontal3','Input');
%folder_work = fullfile(pwd,'Examples','Upfrontal3','Training');
%folder_work = fullfile(pwd,'Examples','Upfrontal3','Landmarks');
%folder_work = fullfile(pwd,'Temp','DetectedLandmarks','Upfrontal3');
%folder_work = fullfile(codefolder,'Jianchao08','Data','Upfrontal3','s4','Reconstructed');
%folder_work = fullfile(pwd,'Examples','NonUpfrontal2','Training');
%folder_work = fullfile(pwd,'Source','NonUpfrontal2','GroundTruth');
%folder_work = fullfile(folder_code,'Ma10','Result','Test2_PAMI_website');
folder_work = fullfile(folder_code,'Ours2','Result','Test18_CompressedFaceHallucinationOnLinux');
Test18_CompressedFaceHallucinationOnLinux
filelist = dir(fullfile(folder_work,'*.png'));
str_target = 'UCI_test18';
str_insert = 'test2';
number_file = length(filelist);
for i=1:number_file
    fn_original = filelist(i).name;
    k = strfind(fn_original,str_target);
    if ~isempty(k)
        %do nothing
    else
        location_insert = strfind(fn_original,str_insert);
        str_first = fn_original(1:location_insert(1)-1);
        fn_goal = [str_first str_target '.png'];
        strcmd = sprintf('rename %s %s',fullfile(folder_work,fn_original),fn_goal);
        dos(strcmd);        
    end
end
