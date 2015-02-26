%Chih-Yuan Yang
%10/13/12
%imwrite images from a mat file for a figure in the paper
clc
clear
close all
codefolder = fileparts(pwd);
projectfolder = fileparts(codefolder);

loadfolder = fullfile('Result','Upfrontal2','Tuning1','GeneratedImages');
savefolder = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Illustration','ThreeSources2');
fn_data = '001_01_02_051_05_Ours_2_1_data.mat';
enlargerate = 4;        %just for display, not zooming

x=280;
y=153;
width = 32;
height = 26;
region_eye.left_idx = x+1;
region_eye.top_idx = y+1;
region_eye.right_idx = region_eye.left_idx + width-1;
region_eye.bottom_idx = region_eye.top_idx + height-1;
region_eye_hr = F23_ConvertLRRegionToHRRegion(region_eye,enlargerate);

x=302;
y=236;
width = 36;
height = 24;
mouth.left_idx = x+1;
mouth.top_idx = y+1;
mouth.right_idx = mouth.left_idx + width-1;
mouth.bottom_idx = mouth.top_idx + height-1;
mouth_hr = F23_ConvertLRRegionToHRRegion(mouth,enlargerate);


fn_short = fn_data(1:end-9);
fn_png = [fn_short '.png'];
img_final_rgb = imread(fullfile(loadfolder,fn_png));
img_final_gray = rgb2gray(img_final_rgb);
fn_save = [fn_short '_final_gray.png'];
imwrite(img_final_gray,fullfile(savefolder,fn_save));
img_final_gray_enlarged = imresize(img_final_gray,enlargerate,'nearest');
load(fullfile(loadfolder,fn_data));
fn_save = [fn_short '_img_texture.png'];
imwrite(img_texture,fullfile(savefolder,fn_save));
fn_save = [fn_short '_img_texture_backprojection.png'];
imwrite(img_texture_backprojection,fullfile(savefolder,fn_save));
img_texture_backprojection_enlarged = imresize(img_texture_backprojection,enlargerate,'nearest');

fn_save = [fn_short '_img_final_gray_enlarged_eyes.png'];
imwrite(img_final_gray_enlarged(region_eye_hr.top_idx:region_eye_hr.bottom_idx,region_eye_hr.left_idx:region_eye_hr.right_idx),...
    fullfile(savefolder,fn_save));
fn_save = [fn_short '_img_final_gray_enlarged_mouth.png'];
imwrite(img_final_gray_enlarged(mouth_hr.top_idx:mouth_hr.bottom_idx,mouth_hr.left_idx:mouth_hr.right_idx),...
    fullfile(savefolder,fn_save));

fn_save = [fn_short '_img_texture_backprojection_enlarged_eyes.png'];
imwrite(img_texture_backprojection_enlarged(region_eye_hr.top_idx:region_eye_hr.bottom_idx,region_eye_hr.left_idx:region_eye_hr.right_idx),...
    fullfile(savefolder,fn_save));
fn_save = [fn_short '_img_texture_backprojection_enlarged_mouth.png'];
imwrite(img_texture_backprojection_enlarged(mouth_hr.top_idx:mouth_hr.bottom_idx,mouth_hr.left_idx:mouth_hr.right_idx),...
    fullfile(savefolder,fn_save));

hfig = U24_sc(weightmap_edge);
fn_save = [fn_short '_weightmap_edge.png'];
saveas(hfig,fullfile(savefolder,fn_save));
close
fn_save = [fn_short '_source_mouth.png'];
imwrite(retrievedhrimagerecord{1},fullfile(savefolder,fn_save));
fn_save = [fn_short '_source_eyebrows.png'];
imwrite(retrievedhrimagerecord{2},fullfile(savefolder,fn_save));
fn_save = [fn_short '_source_eyes.png'];
imwrite(retrievedhrimagerecord{3},fullfile(savefolder,fn_save));
fn_save = [fn_short '_source_nose.png'];
imwrite(retrievedhrimagerecord{4},fullfile(savefolder,fn_save));
