%Chih-Yuan Yang
%10/13/12
%imwrite images from a mat file for a figure in the paper
%PW14a: new figures, show the maps and gradients

clc
clear
close all
codefolder = fileparts(pwd);
projectfolder = fileparts(codefolder);

folder_data = fullfile('Result','Upfrontal2','Tuning2','GeneratedImages');
folder_save = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Illustration','ThreeSources2');
folder_input = fullfile('Source','Upfrontal2','Input');
fn_short = '001_01_02_051_05'; 
fn_data = [fn_short '_Ours_2_2_data.mat'];
fn_final = [fn_short '_Ours_2_2.png'];
fn_save_image_edge = [fn_short '_img_edge.png'];
fn_save_cheek_edge = [fn_short '_cheek_edge.png'];
fn_save_cheek_patch = [fn_short '_cheek_patch.png'];
fn_save_image_background = [fn_short '_img_background.png'];
fn_save_eye_component = [fn_short '_eye_component.png'];
fn_save_eye_patch = [fn_short '_eye_patch.png'];
enlargerate = 4;        %just for display, not zooming

%load data
fn_input = [fn_short '.png'];
img_input = im2double(imread(fullfile(folder_input,fn_input)));
img_y = rgb2gray(img_input);
loaddata = load(fullfile(folder_data,fn_data));
mask_hr_record = loaddata.mask_hr_record;
weightmap_edge = loaddata.weightmap_edge;
img_texture_backprojection = loaddata.img_texture_backprojection;
gradient_background = F14_Img2Grad(img_texture_backprojection);
gradient_edge = loaddata.gradient_edge;
gradient_component = loaddata.gradient_component;
gradient_final = loaddata.gradient_final;
clear loaddata

%generate the weight_component
[h_lr, w_lr] = size(img_y);
[h_weightmap, w_weightmap] = size(weightmap_edge);
zooming = round(h_weightmap/h_lr);
if zooming == 4
    Gau_sigma = 1.6;
elseif zooming == 3
    Gau_sigma = 1.2;
end
h_hr = h_lr * zooming;
w_hr = w_lr * zooming;
weightmap_component = zeros(h_hr, w_hr);
for i=1:4
    weightmap_component = weightmap_component + mask_hr_record{i};
end
weightmap_component(weightmap_component>1) = 1;
fn_save_weightmap_component = [fn_short '_weightmap_component.png'];
imwrite(weightmap_component,fullfile(folder_save,fn_save_weightmap_component));

fn_save_weightmap_edge = [fn_short '_weightmap_edge.png'];
imwrite(weightmap_edge,fullfile(folder_save,fn_save_weightmap_edge));

caxisrange = [-0.2 0.2];
%save gradient component
hfig = figure;
imagesc(gradient_component(:,:,3));
colormap gray
caxis(caxisrange);
axis off image
fn_save_gradient_component = [fn_short '_gradient_component.png'];
saveas(hfig,fullfile(folder_save,fn_save_gradient_component));
close

%save gradient edge
hfig = figure;
imagesc(gradient_edge(:,:,3));
colormap gray
caxis(caxisrange);
axis off image
fn_save_gradient_edge = [fn_short '_gradient_edge.png'];
saveas(hfig,fullfile(folder_save,fn_save_gradient_edge));
close

%save gradient background
hfig = figure;
imagesc(gradient_background(:,:,3));
colormap gray
caxis(caxisrange);
axis off image
fn_save_gradient_background = [fn_short '_gradient_background.png'];
saveas(hfig,fullfile(folder_save,fn_save_gradient_background));
close

%save gradient integrated
hfig = figure;
imagesc(gradient_final(:,:,3));
colormap gray
caxis(caxisrange);
axis off image
fn_save_gradient_final = [fn_short '_gradient_final.png'];
saveas(hfig,fullfile(folder_save,fn_save_gradient_final));
close


cheek_top = 257+1;
cheek_height = 46;
cheek_left = 250+1;
cheek_width = 37;
cheek_bottom = cheek_top + cheek_height -1;
cheek_right = cheek_left + cheek_width -1;
eye_top = 181+1;
eye_left = 270+1;
eye_height = 43;
eye_width = 39;
eye_bottom = eye_top + eye_height -1;
eye_right = eye_left + eye_width -1;

%save image background
imwrite(img_texture_backprojection,fullfile(folder_save,fn_save_image_background));
region_cheek = img_texture_backprojection(cheek_top:cheek_bottom,cheek_left:cheek_right);
imwrite(imresize(region_cheek,enlargerate),fullfile(folder_save,fn_save_cheek_patch));
region_eye = img_texture_backprojection(eye_top:eye_bottom,eye_left:eye_right);
imwrite(imresize(region_eye,enlargerate),fullfile(folder_save,fn_save_eye_patch));

%save image edge and the cropped region
bReport = true;
img_initial = imresize(img_y,zooming);
if exist(fullfile(folder_save,fn_save_image_edge),'file')
    img_edge = imread(fullfile(folder_save,fn_save_image_edge));
else
    img_edge = F4b_GenerateIntensityFromGradient(img_y,img_initial,gradient_edge,Gau_sigma,bReport);
    imwrite(img_edge,fullfile(folder_save,fn_save_image_edge));
end
region_cheek = img_edge(cheek_top:cheek_bottom,cheek_left:cheek_right);
imwrite(imresize(region_cheek,enlargerate),fullfile(folder_save,fn_save_cheek_edge));

%save image final and the cropped region
img_final = rgb2gray(im2double(imread(fullfile(folder_data,fn_final))));
region_eye = img_final(eye_top:eye_bottom,eye_left:eye_right);
imwrite(imresize(region_eye,enlargerate),fullfile(folder_save,fn_save_eye_component));
