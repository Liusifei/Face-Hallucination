%Chih-Yuan Yang
%1/22/2015
%Code for PAMI. Redraw the figure of edge-preserving upsampling

clc
clear
close all
folder_source = 'C:\Users\chih-yuan\Dropbox\vision\paper\2015\PAMI\StructuredFaceHallucination\figs2\Edge';
fn_read = '001_01_02_051_05.png';
img_read = imread(fullfile(folder_source,fn_read));
%generate the bb image and save it
img_gray = rgb2gray(img_read);
fn_write = '001_01_02_051_05_gray.png';
folder_write = folder_source;
imwrite(img_gray,fullfile(folder_write,fn_write));
