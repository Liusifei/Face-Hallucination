%show data
%Chih-Yuan Yang
%08/21/12
%10/09/12 just copy the file from "Dataset\Face\Multi-PIE\labeled data From Ralph Gross" and does not modify it
clear
strpwd = pwd;
[pathstr, name, ext] = fileparts(strpwd);
multipifolder = pathstr;

landmarkfolder = 'correct landmark';
filelist = dir(fullfile(landmarkfolder,'*.mat'));
fileidx_start = 1;
fileidx_end = length(filelist);
savefolder = 'LabeledImages';
if ~exist(savefolder,'dir')
    mkdir(savefolder);
end
for i= fileidx_start:fileidx_end
    fn_load = filelist(i).name;
    fn_load_short = fn_load(1:end-4);
    loaddata = load(fullfile(landmarkfolder,fn_load));
    landmarks = loaddata.pts;
    %load image
    A = sscanf(fn_load_short,'%03d_%02d_%02d_%02d%01d_%02d_lm');
    subjectid = A(1);
    sessionnumber = A(2);
    expressionnumber = A(3);
    cameraid_major = A(4);
    cameraid_minor = A(5);
    illuminationid = A(6);
    imagefolder = fullfile(multipifolder,'data',sprintf('session%02d',sessionnumber),'multiview',...
        sprintf('%03d',subjectid),sprintf('%02d',expressionnumber),sprintf('%02d_%01d',cameraid_major,cameraid_minor));
    fn_img = [fn_load_short(1:end-3) '.png'];
    %copy files
    str_cmd = sprintf('copy %s %s',fullfile(imagefolder,fn_img), savefolder);
    dos(str_cmd);
    %draw
%    img = imread(fullfile(imagefolder,fn_img));
%    hfig = figure;
%    imshow(img);
%    hold on
%    for j=1:68
%         plot(landmarks(j,1),landmarks(j,2),'r.','markersize',15);
%    end
%    fn_save = sprintf('%s.png',fn_load_short);
%    saveas(hfig,fullfile(savefolder,fn_save));
%    close all
%    drawnow
end