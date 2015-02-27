%Chih-Yuan Yang
%11/21/12
%Generate images of the failure case for supplimentary material
%PW21a: the input image changes, now it is the alinged cropped image
clear
clc
close all
codefolder = fileparts(pwd);
projectfolder = fileparts(codefolder);

folder_input = fullfile('Source','Wild2','Input');
fn_input = 'Ali_Landry_0071.png';
folder_groundtruth = fullfile('Source','Wild2','GroundTruth');
fn_groundtruth = 'Ali_Landry_0071.jpg';
folder_landmarks = fullfile('Temp','DetectedLandmarks','Wild2');
fn_landmarks = 'Ali_Landry_0071_mi.mat';

folder_result = fullfile('Result','Wild2','Tuning1','GeneratedImages');
fn_result = 'Ali_Landry_0071_Ours_2_1.png';

folder_save = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Results','Failure2','Ali_Landry_0071');
fn_save_short = 'Ali_Landry_0071';
U22_makeifnotexist(folder_save);


img_input = imread(fullfile(folder_input,fn_input));
loaddata = load(fullfile(folder_landmarks,fn_landmarks));
landmarks = F4_ConvertBStoMultiPieLandmarks(loaddata.bs);
scalingfactor = 4;
img_bb = imresize(img_input,scalingfactor);

hfig = figure;
imshow(img_bb)
hold
plot(landmarks(:,1),landmarks(:,2),'r.','MarkerSize',15);     %why the color changes after hfig returns?
saveas(hfig,fullfile(folder_save,[fn_save_short '_IbAndLandmark.png']));
drawnow
close

scalingfactor2 = 4;
img_bb_up = imresize(img_bb,scalingfactor2,'nearest');
hfig = figure;
imshow(img_bb_up)
hold
landmarks_up = landmarks * scalingfactor2;
plot(landmarks_up(:,1),landmarks_up(:,2),'r.','MarkerSize',60);     %why the color changes after hfig returns?
X = 61;
Y = 148;
width = 45;
height = 30;
r = Y+1;
c = X+1;
r1 = r + height-1;
c1 = c + width-1;
r_up = (r-1)*scalingfactor2+1;
r1_up = r1*scalingfactor2;
c_up = (c-1)*scalingfactor2+1;
c1_up = c1*scalingfactor2;
xlim([c_up c1_up]);
ylim([r_up r1_up]);
saveas(hfig,fullfile(folder_save,[fn_save_short '_EyeAndLandmark.png']));
drawnow
close
