%Chih-Yuan Yang
%6/11/2013
%Code for PAMI, re-draw the facial component figure

clc
clear
close all
folder_source = fullfile('Source','PaperWriting1_PAMI');
fn_read = 'inputimage.png';
img_read = imread(fullfile(folder_source,fn_read));
%generate the bb image and save it
img_bb = imresize(img_read,4);
fn_write = 'SimonBaker_bb.png';
folder_write = fullfile('Result','PaperWriting1_PAMI');
imwrite(img_bb,fullfile(folder_write,fn_write));
%draw the facial landmarks and save it
fn_landmarks = '001_01_02_051_05_mi.mat';
loaddata = load(fullfile(folder_source,fn_landmarks));
bs = loaddata.bs;
landmarks = F4_ConvertBStoMultiPieLandmarks(bs);
hfig = figure;
axes('position', [0 0 1 1]);        %remove the boundary
axis off
imshow(img_bb);
hold on

%draw landmarks and save it
plot(landmarks(:,1),landmarks(:,2),'r.');
fn_write = 'SimonBaker_bb_landmark.png';
%can I control the output image size?
%to set the paper size or resolution. If my expected output size is 640x480
%can I set the resolution as -r100, and paper size as 6.4 * 4.8?
%no, the generated image is still too large (801 * 601)
set(hfig, 'PaperSize',[6.4 4.7]);       %there is a hidden PaperSize [8, 6], and I can not change it. why?
print('-dpng','-r80',fullfile(folder_write,fn_write));  

%draw landmarks on a white paper
img_white = ones(size(img_bb));

imshow(img_white);
plot(landmarks(:,1),landmarks(:,2),'k.');
fn_write = 'SimonBaker_landmark.png';
print('-dpng','-r80',fullfile(folder_write,fn_write));  

%draw the four source images
% moues: Upfrontal2, imageidx = 908
% eyebrows: Upfrontal2, imageidx = 869
% eye: Upfrontal2, imageidx = 1274
% nose: Upfrontal2, imageidx = 1225
folder_example = fullfile('Examples','Upfrontal2','Training');
%load all images filenames
filelist = dir(fullfile(folder_example, '*.png'));
%get the file names of the four files
arr_source_idx = [908,869,1274,1225];
fn_example = cell(4,1);
for i=1:4
    idx = arr_source_idx(i);
    fn_example{i} = filelist(idx).name;
end
%dump the four raw image
%load all training images
folder_load = fullfile('Examples','Upfrontal2','PreparedMatForLoad');
fn_load = 'ExampleDataForLoad.mat';

loaddata = load(fullfile(folder_load,fn_load),'exampleimages','exampleimages_lr','landmarks');
rawexamplelandmarks = loaddata.landmarks;
rawexampleimage = loaddata.exampleimages;
allLRexampleimages = loaddata.exampleimages_lr;
for i=1:4
    idx = arr_source_idx(i);    
    image_source_raw = rawexampleimage(:,:,idx);
    %dump it
    fn_write = sprintf('rawsouceimage_%d.png',i);
    imwrite(image_source_raw,fullfile(folder_write,fn_write));
end
%draw the landmarks of the raw image
for i=1:4
    hfig = figure;
    set(hfig, 'PaperSize',[6.4 4.7]);       %there is a hidden PaperSize [8, 6], and I can not change it. why?
    axes('position', [0 0 1 1]);        %remove the boundary
    axis off
    hold on
    
    imshow(img_white);
    idx = arr_source_idx(i);      
    landmarks = rawexamplelandmarks(:,:,idx);
    plot(landmarks(:,1),landmarks(:,2),'k.');
    fn_write = sprintf('rawlandmarks_%d.png',i);
    print('-dpng','-r80',fullfile(folder_write,fn_write));  
    close(hfig);
end
%draw the aligned images and aligned landmarks
%load data
folder_load = fullfile('Result','Upfrontal2','Tuning3','GeneratedImages');
fn_testshort = '001_01_02_051_05';
para.setting = 2;
para.tuning = 3;
para.legend = 'Ours';
fn_load = sprintf('%s_%s_%d_%d_data.mat',fn_testshort,para.legend,para.setting,para.tuning);
loaddata = load(fullfile(folder_load,fn_load),'mask_hr_record','mask_lr_record','retrievedidxrecord',...
    'retrievedhrimagerecord','retrievedlrimagerecord','img_texture','img_texture_backprojection','weightmap_edge',...
    'gradient_edge','gradient_component','gradient_final','rec_alignedlandmarks');
%dump the recorded images
for i=1:4
    fn_write = sprintf('alignedhrimage_%d.png',i);
    imwrite(loaddata.retrievedhrimagerecord{i},fullfile(folder_write,fn_write));
end
for i=1:4
    fn_write = sprintf('alignedlrimage_%d.png',i);
    imwrite(loaddata.retrievedlrimagerecord{i},fullfile(folder_write,fn_write));
end
%dump aligned landmarks
for i=1:4
    hfig = figure;
    set(hfig, 'PaperSize',[6.4 4.7]);       %there is a hidden PaperSize [8, 6], and I can not change it. why?
    axes('position', [0 0 1 1]);        %remove the boundary
    axis off
    hold on
    
    imshow(img_white);
    idx = arr_source_idx(i);      
    landmarks = loaddata.rec_alignedlandmarks{i};       %format: 2xN
    plot(landmarks(1,:),landmarks(2,:),'k.');
    fn_write = sprintf('landmarks_aligned_%d.png',i);
    print('-dpng','-r80',fullfile(folder_write,fn_write));  
    close(hfig);
end
%dump the masks using white background
%this part is somehow unnecessary
% for i=1:4
%     mask_blackbackground = loaddata.mask_hr_record{i};
%     [r_set,c_set] = find(mask_blackbackground);
%     r_min = min(r_set);
%     r_max = max(r_set);
%     c_min = min(c_set);
%     c_max = max(c_set);
%     mask_whitebackground = 1- mask_blackbackground;
%     mask_whitebackground_crop = mask_whitebackground(r_min:r_max,c_min:c_max);
%     fn_write = sprintf('mask_hr_%d.png',i);
%     imwrite(mask_whitebackground_crop,fullfile(folder_write,fn_write));
% end
%dump the used regions. I need to crop them
%in this case, I need to control the overlap of eyebrows and the eyes and nose
for i=1:4
    mask_blackbackground = loaddata.mask_hr_record{i};
    [r_set,c_set] = find(mask_blackbackground);
    r_min = min(r_set);
    r_max = max(r_set);
    c_min = min(c_set);
    c_max = max(c_set);
    mask_whitebackground = 1- mask_blackbackground;
    exemplar_aligned = im2double(loaddata.retrievedhrimagerecord{i});
    if i==2
        mask_exclusive = loaddata.mask_hr_record{3} + loaddata.mask_hr_record{4};
        mask_exclusive(mask_exclusive>1) = 1;
        mask_active = mask_blackbackground - mask_exclusive;
        %refine it
        mask_active(mask_active < 0 ) = 0;
        mask_inactive  = 1 - mask_active;
        image_masked = mask_active .* exemplar_aligned + mask_inactive;
    else
        image_masked = mask_blackbackground .* exemplar_aligned + mask_whitebackground;
    end
    image_masked_crop = image_masked(r_min:r_max,c_min:c_max);
    fn_write = sprintf('image_masked_%d.png',i);
    imwrite(image_masked_crop,fullfile(folder_write,fn_write));
end

