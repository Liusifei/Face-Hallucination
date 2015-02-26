%Chih-Yuan Yang
%10/22/12
%This file requires UCI face landmark algroithm and only can run on Linux
clc
clear
close all

codefolder = fileparts(pwd);
addpath(genpath(fullfile(codefolder,'Lib')));

zooming = 4;
testimagefolder = fullfile('Source','Wild2','Input');
imagesavefolder = fullfile('Temp','DetectedLandmarks','Wild2');
U22_makeifnotexist(imagesavefolder);

filelist = dir(fullfile(testimagefolder, '*.png'));
filecount = length(filelist);

fileidx_start = 4;
fileidx_end = 4;
for fileidx=fileidx_start:fileidx_end
    %open specific file
    fn_testfile = filelist(fileidx).name;
    fprintf('fileidx %d, fn_testfile %s\n',fileidx,fn_testfile);
    sourcefile = fullfile(testimagefolder,fn_testfile);
    imd = im2double(imread( sourcefile) );

    imghrcolor = imresize(imd,zooming);
    %bicubic interpolation generates some values less than 0 or greater
    %than 1. We need to clear them.
    imghrcolor(imghrcolor > 1) = 1;
    imghrcolor(imghrcolor < 0) = 0;

    %apply the detection algorithm
    modelname = 'mi';
    try
        [bs posemap] = F2_ReturnLandmarks(imghrcolor,modelname);
    catch err
        continue
    end
    
    if ~isempty(bs)           %sometimes be is empty if the threshold is high
        hfig = figure('Visible','off');
        fn_testfile_short = fn_testfile(1:end-4);
        %Do not show blue boxes, only show red landmark points
        bshownumbers = false;
        bdrawpose = true;
        U21_DrawLandmarks(imghrcolor, bs,posemap,bshownumbers,bdrawpose);
        %record the bs
        fnsave = fullfile(imagesavefolder,sprintf('%s_%s.mat',fn_testfile_short, modelname));
        save(fnsave,'bs','posemap');
        fnsave = fullfile(imagesavefolder,sprintf('%s_%s.png',fn_testfile_short, modelname));
        saveas(hfig, fnsave);
        close(hfig);
    end
end