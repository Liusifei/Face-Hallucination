%Chih-Yuan Yang
%10/07/12
%Super-Resolution for faces
clc
clear
close all

codefolder = fileparts(pwd);
projectfolder = fileparts(codefolder);
zooming = 4;
folder_save = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Illustration','Edge2');
folder_input = fullfile('Source','Upfrontal2','Input');
folder_grdient_edge = fullfile('Result','Upfrontal2','Tuning1','GeneratedImages');
folder_img_edge = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Illustration','Edge2');
fn_load_short = '001_01_02_051_05';
fn_input = [fn_load_short '.png'];

U22_makeifnotexist(folder_save);

img_input = im2double(imread(fullfile(folder_input,fn_input)));
img_y = rgb2gray(img_input);
img_bb = imresize(img_y,zooming);
img_edge = im2double(imread(fullfile(folder_img_edge,'img_edge.png')));

left_hr = 215;
right_hr = left_hr+131-1;
top_hr = 53;
bottom_hr = top_hr+312-1;

left_lr = floor((left_hr-1)/4)+1;
right_lr = floor((right_hr-1)/4)+1;
top_lr = floor((top_hr-1)/4)+1;
bottom_lr = floor((bottom_hr-1)/4)+1;

imwrite(img_edge(top_hr:bottom_hr,left_hr:right_hr),fullfile(folder_save,'edge_part.png'));
imwrite(img_y(top_lr:bottom_lr,left_lr:right_lr),fullfile(folder_save,'input_part.png'));


img_recon = F27_SmoothnessPreserving(img_y,zooming,Gau_sigma);
imwrite(img_recon(top_hr:bottom_hr,left_hr:right_hr),fullfile(finalsavefolder,'ReconstructedHRImage.png'));
mag_recon = F15_ComputeSRSSD(img_recon);
colorrange = [0 0.8];
hfig = U24_sc(mag_recon,colorrange);
title('');
saveas(hfig,fullfile(finalsavefolder,'Magnitude_Reconstructed.png'));
ridgemap = edge(img_recon,'canny',[0 0.01],0.05);
ridgemap_invert = 1-ridgemap;
imwrite(ridgemap_invert(top_hr:bottom_hr,left_hr:right_hr),fullfile(finalsavefolder,'EdgeCenter.png'));

gradients_edge = F21e_EdgePreserving_GaussianKernel(img_y,zooming,Gau_sigma);
mag_restore = sqrt(sum(gradients_edge.^2,3));
hfig = U24_sc(mag_restore,colorrange);
title('');
saveas(hfig,fullfile(finalsavefolder,'Magnitude_Restored.png'));


mag_gt = F15_ComputeSRSSD(img_gt);
hfig = U24_sc(mag_gt,colorrange);
title('');
saveas(hfig,fullfile(finalsavefolder,'Magnitude_gt.png'));

left = 271;
right = left+8;
top = 295;
bottom = 310;
mag_recon_region = mag_recon(top:bottom,left:right);
mag_gt_region = mag_gt(top:bottom,left:right);
ridgemap_region = ridgemap(top:bottom,left:right);
mag_restore_region = mag_restore(top:bottom,left:right);

[h w] = size(mag_recon_region);
for r=1:h
    for c=1:w
        if ridgemap_region(r,c) == 1 
            mag_recon_region(r,c) = 1;
        end
    end
end

hfig = U24_sc(mag_recon_region,colorrange);
title('');
axis off
saveas(hfig,fullfile(finalsavefolder,'Magnitude_Reconstructed_region.png'));

hfig = U24_sc(mag_gt_region,colorrange);
title('');
axis off
saveas(hfig,fullfile(finalsavefolder,'Magnitude_gt_region.png'));

hfig = U24_sc(mag_restore_region,colorrange);
title('');
axis off
saveas(hfig,fullfile(finalsavefolder,'Magnitude_restore_region.png'));
