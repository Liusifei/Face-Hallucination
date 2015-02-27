%Chih-Yuan Yang
%11/09/12
%Separate the function from PW17
clc
clear
close all

folder_code = fileparts(pwd);
folder_project = fileparts(folder_code);
addpath(genpath(fullfile(folder_code,'Lib')));
    
zooming = 4;
settingname = 'Upfrontal';
folder_source = fullfile('Source','Upfrontal2','Input');
fn_source = '001_01_02_051_05.png';
folder_save = fullfile(folder_project,'PaperWriting','CVPR13','manuscript','figs','Illustration','SmoothnessPreservingUpsampling');

U22_makeifnotexist(folder_save);

imd = im2double(imread(fullfile(folder_source,fn_source)));
img_yiq = RGB2YIQ(imd);
img_y = img_yiq(:,:,1);
    img_bb = imresize(img_y,zooming);

    %compute the similarity from low
    Coef = 10;
    PatchSize = 3;
    Sqrt_low = F45_SimilarityEvaluation(img_y);           %I may need more directions, 16 may be too small
    Similarity_low = exp(-Sqrt_low*Coef);
    [h_high, w_high] = size(img_bb);
    ExpectedSimilarity = zeros(h_high,w_high,16);
    %upsamplin the similarity
    for dir=1:16
        ExpectedSimilarity(:,:,dir) = imresize(Similarity_low(:,:,dir),zooming,'bilinear');
    end

    for i=1:16
        fn_save = sprintf('Similarity_lr_%d.png',i);
        hfig = figure;
        imagesc(Similarity_low(:,:,i));
        caxis([0,1]);
        axis off image
        saveas(hfig,fullfile(folder_save,fn_save));
        close
        
        fn_save = sprintf('Similarity_hr_%d.png',i);
        hfig = figure;
        imagesc(ExpectedSimilarity(:,:,i));
        caxis([0,1]);
        axis off image
        saveas(hfig,fullfile(folder_save,fn_save));
        close        
    end
    