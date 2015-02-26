%Chih-Yuan Yang
%09/15/12
%Generate gray example images for paper writing
clear
fn_test = '145_03_01_051_05.png';
alignedcomponent = 'eyebrows';
sourcefolder = fullfile('Source','Input');
landmarkfolder = fullfile('Temp','DetectedLandmarks');
savefolder = fullfile('PaperWriting','InputPartialLandmarks');
U22_makeifnotexist(savefolder);

%load input
fn_read = fn_test;
fn_short = fn_test(1:end-4);
img_lr_color = imread(fullfile(sourcefolder,fn_read));
img_hr_gray = rgb2gray(imresize(img_lr_color,4));
%load landmarks
fn_load = sprintf('%s_mi.mat',fn_short);
loaddata = load(fullfile(landmarkfolder,fn_load));
bs = loaddata.bs;
landmarks_multipie = F4_ConvertBStoMultiPieLandmarks(bs);
switch alignedcomponent
    case 'nose'
        inputpoints = landmarks_multipie(28:36,:);
    case 'eyebrows'
        inputpoints = landmarks_multipie(18:27,:);
end
posemap =[];
bshownumbers = false;
bdrawpose = false;
bvisible = false;
hfig = U21a_DrawLandmarks_Points_ReturnHandle(img_hr_gray,inputpoints,posemap,bshownumbers,bdrawpose,bvisible);
fn_write = sprintf('%s_%s.png',fn_short,alignedcomponent);
saveas(hfig,fullfile(savefolder,fn_write));
