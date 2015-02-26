%Chih-Yuan Yang
%04/30/13
%Convert color image to grayscale image for paper writing
clc
clear
close all
folder_dropbox = 'C:\Users\Chih-Yuan\Dropbox\vision\paper\2013\BMVC\super\manuscript\fig\results';
folder_src = fullfile(folder_dropbox,'BackProjection','NonUpfrontal','100');
folder_save = folder_src;
filelist = dir(fullfile(folder_src,'*.png'));
num_files = length(filelist);
for i=1:num_files
    fn_withext = filelist(i).name;
    fn_short = fn_withext(1:end-4);
    img_read = imread(fullfile(folder_src,fn_withext));
    img_gray = rgb2gray(img_read);
    fn_save = [fn_short '_gray.png'];
    imwrite(img_gray,fullfile(folder_save,fn_save));
end