%09/15/12
%Chih-Yuan Yang
%Raw landmarks on example images to see the feasible component region
%This function has been replaced by S3

clear
close all
%load image
trainingimagefolder = fullfile('Examples','Training');
landmarkfolder = fullfile('Examples','RawLandmarks');
savefolder = fullfile('Examples','TrainingImageWithLandmarkPointsGray');
U22_makeifnotexist(savefolder);
filelist = dir(fullfile(trainingimagefolder,'*.png'));
filenumber = length(filelist);

for i=1:filenumber
    hfig = figure('Visible','off');
    fn_raw = filelist(i).name;
    fn_short = fn_raw(1:end-4);
    fn_load = fn_raw;
    fn_landmark = sprintf('%s_lm.mat',fn_short);
    img_load = imread(fullfile(trainingimagefolder,fn_load));
    img_gray = rgb2gray(img_load);
    load(fullfile(landmarkfolder,fn_landmark));
    imshow(img_gray);
    hold on         %the hold on makes a hfig contain numerous figure, so close all before next iteration
    for j=1:68
        plot(pts(j,1),pts(j,2),'r.','markersize',15);
    end
    fn_save_png = sprintf('%s.png',fn_short);
%    fn_save_fig = sprintf('%s.fig',fn_short);
    saveas(hfig,fullfile(savefolder,fn_save_png));
%    saveas(hfig,fullfile(para.savefolder,fn_save_fig));
    close all
end

