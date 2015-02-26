%Chih-Yuan Yang
%11/19/12
%Generate images of the failure case for supplimentary material

clear
clc
close all
codefolder = fileparts(pwd);
projectfolder = fileparts(codefolder);

folder_input = fullfile('Source','Wild','Input');
fn_input = 'Ali_Landry_0071.png';
folder_groundtruth = fullfile('Source','Wild','GroundTruth');
fn_groundtruth = 'Ali_Landry_0071.jpg';
folder_landmarks = fullfile('Temp','DetectedLandmarks','Wild');
fn_landmarks = 'Ali_Landry_0071_mi.mat';

folder_result = fullfile('Result','Wild1','Tuning4','GeneratedImages');
fn_result = 'Ali_Landry_0071_Ours_1_4.png';

folder_save = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Results','Failure');
fn_save_short = 'Ali_Landry_0071';
U22_makeifnotexist(folder_save);


img_input = imread(fullfile(folder_input,fn_input));
loaddata = load(fullfile(folder_landmarks,fn_landmarks));
landmarks = F4_ConvertBStoMultiPieLandmarks(loaddata.bs);
scalingfactor = 4;
img_bb = imresize(img_input,scalingfactor);
scalingfactor2 = 4;
img_bb_up = imresize(img_bb,scalingfactor2,'nearest');
img_result = imread(fullfile(folder_result,fn_result));
img_result_up = imresize(img_result,scalingfactor2,'nearest');
img_groundtruth = imread(fullfile(folder_groundtruth,fn_groundtruth));
img_groundtruth_up = imresize(img_groundtruth,scalingfactor2,'nearest');

%show a region
top_face = 1;
left_face = 291;
height_face = 320;
width_face = 240;
bottom_face = top_face + height_face -1;
right_face = left_face + width_face -1;

top_eye = 415;
bottom_eye = 664;
left_eye = 1275;
right_eye = 1700;

hfig = figure;
imshow(img_bb_up);
hold
landmarks_up = landmarks * scalingfactor2;
plot(landmarks_up(:,1),landmarks_up(:,2),'r.','MarkerSize',30);     %why the color changes after hfig returns?

ylim([top_eye bottom_eye]);
xlim([left_eye right_eye]);
saveas(hfig,fullfile(folder_save,[fn_save_short '_eye_Ib.png']));
close

hfig = figure;
imshow(img_bb)
hold
plot(landmarks(:,1),landmarks(:,2),'r.','MarkerSize',7);     %why the color changes after hfig returns?
ylim([top_face bottom_face]);
xlim([left_face right_face]);
saveas(hfig,fullfile(folder_save,[fn_save_short '_face_Ib.png']));
drawnow
close

hfig = figure;
imshow(img_result_up);
hold
%show a region
ylim([top_eye bottom_eye]);
xlim([left_eye right_eye]);
saveas(hfig,fullfile(folder_save,[fn_save_short '_eye_result.png']));
close

hfig = figure;
imshow(img_result)
hold
ylim([top_face bottom_face]);
xlim([left_face right_face]);
saveas(hfig,fullfile(folder_save,[fn_save_short '_face_result.png']));
drawnow
close

hfig = figure;
imshow(img_groundtruth_up);
hold
%show a region
ylim([top_eye bottom_eye]);
xlim([left_eye right_eye]);
saveas(hfig,fullfile(folder_save,[fn_save_short '_eye_groundtruth.png']));
close

hfig = figure;
imshow(img_groundtruth)
hold
ylim([top_face bottom_face]);
xlim([left_face right_face]);
saveas(hfig,fullfile(folder_save,[fn_save_short '_face_groundtruth.png']));
drawnow
close
