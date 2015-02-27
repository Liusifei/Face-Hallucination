%Chih-Yuan Yang
%10/26/12
%Generate image for flow chart

clear
close all
clc
codefolder = fileparts(pwd);
projectfolder = fileparts(codefolder);

folder_load = fullfile('Result','Upfrontal2','Tuning1','GeneratedImages');
folder_landmark = fullfile('Temp','DetectedLandmarks','Upfrontal2');
folder_save = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','illustration','FlowChart2');
fn_load_short = '001_01_02_051_05';
fn_landmark = [fn_load_short '_mi.mat'];
fn_mat = [fn_load_short '_Ours_2_1_data.mat'];
fn_save = [fn_load_short '_landmarks.png'];

loaddata = load(fullfile(folder_landmark,fn_landmark));
landmarks = F4_ConvertBStoMultiPieLandmarks(loaddata.bs);
clear loaddata
img_black = ones(480,640);
bshowtext = false;
hfig = U9_DrawMultiPieLandmarkVisualCheck(img_black,landmarks,bshowtext);
saveas(hfig,fullfile(folder_save,fn_save));

%Generate mandmarks for the three example images
folder_landmark = fullfile('Examples','MetaData','AllLandmarks_Upfrontal');
for i=1:3
    switch i
        case 1
            fn_load_short = '014_02_02_051_05';
        case 2
            fn_load_short = '024_01_01_051_07';
        case 3
            fn_load_short = '031_03_02_051_05';
    end
            
    fn_landmark = [fn_load_short '_lm.mat'];
    fn_save = [fn_load_short '_landmarks.png'];
    loaddata = load(fullfile(folder_landmark,fn_landmark));
    landmarks = loaddata.pts;
    clear loaddata
    img_black = ones(480,640);
    bshowtext = false;
    hfig = U9_DrawMultiPieLandmarkVisualCheck(img_black,landmarks,bshowtext);
    saveas(hfig,fullfile(folder_save,fn_save));
end

%Generate landmarks for the three nonupfrontal images
folder_landmark = fullfile('Examples','MetaData','AllLandmarks_NonUpfrontal');
folder_image = fullfile('Examples','MetaData','AllLabeledImages_NonUpfrontal');
for i=1:3
    switch i
        case 1
            fn_load_short = '002_01_01_041_09';
        case 2
            fn_load_short = '046_01_01_041_05';
        case 3
            fn_load_short = '079_02_01_041_05';
    end
            
    fn_landmark = [fn_load_short '_lm.mat'];
    fn_save = [fn_load_short '_landmarks.png'];
    fn_image = [fn_load_short '.png'];
    loaddata = load(fullfile(folder_landmark,fn_landmark));
    img_rgb = imread(fullfile(folder_image,fn_image));
    img_gray = rgb2gray(img_rgb);
    imwrite(img_gray,fullfile(folder_save,fn_image));
    landmarks = loaddata.pts;
    clear loaddata
    img_black = ones(480,640);
    bshowtext = false;
    hfig = U9_DrawMultiPieLandmarkVisualCheck(img_black,landmarks,bshowtext);
    saveas(hfig,fullfile(folder_save,fn_save));
end

%close all
%Generate the alingd HR images and LR images
%folder_input = fullfile('Source','Upfrontal2','Input'); 
%fn_input = '001_01_02_051_05';
%loaddata = load(fullfile(folder_landmark,fn_landmark));
%landmarks = F4_ConvertBStoMultiPieLandmarks(loaddata.bs);
