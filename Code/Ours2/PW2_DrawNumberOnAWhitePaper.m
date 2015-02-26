%09/10/12
%Chih-Yuan Yang
%No title, not blue box, with numbers
clc
clear
close all

para.zooming = 4;
para.testimagefolder = fullfile('Source','Input');
para.detectedlandmarkfolder = fullfile('Temp','DetectedLandmarks');
para.imagesavefolder = fullfile('Temp','BBImageAndLandmarks');
if ~exist(para.imagesavefolder,'dir')
    mkdir(para.imagesavefolder);
end

    %open specific file
    modelname = 'mi';
    fn_testfile = '167_01_02_051_05.png';
    para.sourcefile = fullfile(para.testimagefolder,fn_testfile);
    imd = im2double(imread( para.sourcefile) );

    imghrcolor = imresize(imd,para.zooming);
    fn_testfile_short = fn_testfile(1:end-4);
    fn_landmark = sprintf('%s_mi.mat',fn_testfile_short);
    %load bs and posemap
    clear bs posemap
    load(fullfile(para.detectedlandmarkfolder,fn_landmark));
    hfig = figure('PaperSize',[2400 1800]);
    if ~isempty(bs)           %sometimes be is empty if the threshold is high
        %Do not show blue boxes, only show red landmark points
        bdrawnumbers = true;
        bdrawpose = false;
        imghrcolor = ones(size(imghrcolor));
        U21_DrawLandmarks(imghrcolor, bs,posemap,bdrawnumbers,bdrawpose);
    end
    fnsave = fullfile(para.imagesavefolder,sprintf('%s_%s_drawnumberonly.png',fn_testfile_short, modelname));
    saveas(hfig, fnsave);
