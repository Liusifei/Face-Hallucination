%Chih-Yuan Yang
%10/10/12
clear
close all
codefolder = fileparts(pwd);

projectfolder = fileparts(codefolder);
datafolder = fullfile(codefolder,'Ours2','Result','Upfrontal2','Tuning1','GeneratedImages');
inputfolder = fullfile(codefolder,'Ours2','Source','Upfrontal2','Input');
savefolder = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Illustration','Components_SimonBaker');
U22_makeifnotexist(savefolder);
fn_load_short = '001_01_02_051_05';
fn_load_input = [fn_load_short '.png'];
fn_generated = [fn_load_short '_Ours_2_1.png'];
fn_load_data = [fn_load_short '_Ours_2_1_data.mat'];

%load input
img_input = imread(fullfile(inputfolder,fn_load_input));
img_y = rgb2gray(im2double(img_input));
fn_save = ['inputimage.png'];
imwrite(img_y,fullfile(savefolder,fn_save));

%load generated image and save
img_generated = rgb2gray(im2double(imread(fullfile(datafolder,fn_generated))));
fn_save = 'HRimage.png';
imwrite(img_generated,fullfile(savefolder,fn_save));

%load data

loaddata = load(fullfile(datafolder,fn_load_data));
img_texture= loaddata.img_texture;
figure
imshow(img_texture);
title('img\_texture');
img_texture_backprojection = loaddata.img_texture_backprojection;
figure
imshow(img_texture_backprojection);
title('img\_texture\_backprojection');
componentrecord_lr(1).mask_lr = loaddata.mask_lr_record{1};
componentrecord_lr(2).mask_lr = loaddata.mask_lr_record{2};
componentrecord_lr(3).mask_lr = loaddata.mask_lr_record{3};
componentrecord_lr(4).mask_lr = loaddata.mask_lr_record{4};

%fn_save_full = fullfile(savefolder,'maskedinputimage.png');
%U26_DrawMask(img_y,componentrecord_lr,bsave,fn_save_full);
for i=1:4
    switch i
        case 1
            strcomponent = 'mouth';
        case 2
            strcomponent = 'eyebrows';
        case 3
            strcomponent = 'eyes';
        case 4
            strcomponent = 'nose';
    end
%    figure
%    imshow(loaddata.retrievedhrimagerecord{i});
%    title(['retrivedhrimage ' strcomponent]);
    fn_save = ['retrivedhrimage_' strcomponent '.png'];
    imwrite(loaddata.retrievedhrimagerecord{i},fullfile(savefolder,fn_save));
    
    %save the gradient
    grad = F14_Img2Grad(loaddata.retrievedhrimagerecord{i});
    hfig = figure;
    imagesc(grad(:,:,3));
    colormap gray
    caxis([-0.3 0.3]);
    axis off
    fn_save = ['grad_' strcomponent '.png'];
    saveas(hfig,fullfile(savefolder,fn_save));
    close
    
    
    %save mask
    fn_save = ['mask_' strcomponent '.png'];
    imwrite(componentrecord_lr(i).mask_lr,fullfile(savefolder,fn_save));
    
    
%    figure
%    imshow( loaddata.retrievedlrimagerecord{i});
%    title(['retrivedhrimage ' strcomponent]);    
    fn_save = ['retrivedlrimage_' strcomponent '.png'];
    imwrite(loaddata.retrievedlrimagerecord{i},fullfile(savefolder,fn_save));
end
