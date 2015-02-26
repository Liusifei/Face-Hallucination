%Chih-Yuan Yang
%10/26/12
%Extract images of Multi_PIE according to the file sets of given landmarks
clear

%the folder has moved and the string needs to update
folder_multipie = 'D:\Documents\Research\code\090916SuperResolution\Dataset\Face\Multi-PIE';

folder_landmark = fullfile('Examples','MetaData','AllLandmarks_NonUpfrontal');
folder_save = fullfile('Examples','MetaData','AllLabeledImage_NonUpfrontal');
filelist = dir(fullfile(folder_landmark,'*.mat'));
fileidx_start = 1;
fileidx_end = length(filelist);
U22_makeifnotexist(folder_save);
for i= fileidx_start:fileidx_end
    fn_load = filelist(i).name;
    fn_load_short = fn_load(1:end-4);
    loaddata = load(fullfile(folder_landmark,fn_load));
    landmarks = loaddata.pts;
    %load image
    A = sscanf(fn_load_short,'%03d_%02d_%02d_%02d%01d_%02d_lm');
    subjectid = A(1);
    sessionnumber = A(2);
    expressionnumber = A(3);
    cameraid_major = A(4);
    cameraid_minor = A(5);
    illuminationid = A(6);
    imagefolder = fullfile(folder_multipie,'data',sprintf('session%02d',sessionnumber),'multiview',...
        sprintf('%03d',subjectid),sprintf('%02d',expressionnumber),sprintf('%02d_%01d',cameraid_major,cameraid_minor));
    fn_img = [fn_load_short(1:end-3) '.png'];
    %copy files
    str_cmd = sprintf('copy %s %s',fullfile(imagefolder,fn_img), folder_save);
    dos(str_cmd);
end