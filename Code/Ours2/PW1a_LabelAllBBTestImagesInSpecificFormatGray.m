%09/15/12
%Chih-Yuan Yang
%for gray
clc
clear
close all

zooming = 4;
testimagefolder = fullfile('Source','Input');
detectedlandmarkfolder = fullfile('Temp','DetectedLandmarks');
imagesavefolder = fullfile('Temp','BBImageAndLandmarksGray');
U22_makeifnotexist(imagesavefolder);

filelist = dir(fullfile(testimagefolder, '*.png'));
filecount = length(filelist);

fileidx_start = 1;
fileidx_end = filecount;
modelname = 'mi';
for fileidx=fileidx_start:fileidx_end
    %open specific file
    fn_testfile = filelist(fileidx).name;
    fprintf('fileidx %d, fn_testfile %s\n',fileidx,fn_testfile);
    sourcefile = fullfile(testimagefolder,fn_testfile);
    imd = im2double(imread( sourcefile) );

    imghrcolor = imresize(imd,zooming);
    imghrgray = rgb2gray(imghrcolor);
    fn_testfile_short = fn_testfile(1:end-4);
    fn_landmark = sprintf('%s_mi.mat',fn_testfile_short);
    %load bs and posemap
    clear bs posemap
    load(fullfile(detectedlandmarkfolder,fn_landmark));
    hfig = figure('Visible','off');
    if ~isempty(bs)           %sometimes be is empty if the threshold is high
        %Do not show blue boxes, only show red landmark points
        bdrawnumbers = false;
        bdrawpose = false;
        U21_DrawLandmarks(imghrgray, bs,posemap,bdrawnumbers,bdrawpose);
    end
    fnsave = fullfile(imagesavefolder,sprintf('%s_%s.png',fn_testfile_short, modelname));
    saveas(hfig, fnsave);
    close(hfig);
end