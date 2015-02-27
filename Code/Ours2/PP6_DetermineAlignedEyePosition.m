%Chih-Yuan Yanglefte
%08/17/12
%PP6: Separate PP2 into two files. The first file is PP6 to determine the locatio of the two eyes
%for alignment. The second file is to load the determined location for alignment. The separation is
%taken for the purpose of aligning hihgly contrast illuminated images for PAMI.

clear
clc
close all
fn_save = 'Upfrontal.mat';
folder_save = 'LocationOfTwoEyesForAlignment';
%2184 images are used for compute the center of eyes
folder_filelist = fullfile('Source','FileList');
fn_filelist = 'TrainingImage2184Upfrontal.txt';
arr_filename = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
folder_landmark_raw = fullfile('Examples','MetaData','AllLandmarks_Upfrontal');
num_files = length(arr_filename);

%compute means of two eyes among all training image
eyecenter_training = zeros(2,2,num_files);  %right eye x, right eye y, left eye x, left eye y    
%record all landmarks for alignment
rawlandmarks_image = zeros(68,2,num_files);
%only right eye and left eye are used
for idx_file=1:num_files
    %load the landmark
    fn_read = arr_filename{idx_file};
    fn_short = fn_read(1:end-4);
    fn_landmark = [fn_short '_lm.mat'];
    loaddata = load(fullfile(folder_landmark_raw,fn_landmark));
    landmarks = loaddata.pts;
    rawlandmarks_image(:,:,idx_file) = loaddata.pts;
    %find the location of center of eyes
    %the landmark numbers are 37 to 42 (the subject's right eye)
    %43 to 48 (the subject's left eye)
    eyecenter_training(1,:,idx_file) = mean(landmarks(37:42,:));        %left eye
    eyecenter_training(2,:,idx_file) = mean(landmarks(43:48,:));        %right eye
end
%compute the average of the three points as aligned position
eyecentermean = mean(eyecenter_training,3);
lefteye.x = eyecentermean(1,1);      %the left eye is the eye on the image
lefteye.y = eyecentermean(1,2);
righteye.x = eyecentermean(2,1);
righteye.y = eyecentermean(2,2);
%The two eyes are not horizontal
%rotate the right eye as high as the left eye
eyeslopeangle = atan(-(righteye.y-lefteye.y)/(righteye.x-lefteye.x));
eyedist = sqrt((righteye.y-lefteye.y)^2+(righteye.x-lefteye.x)^2);
newrighteye.x = lefteye.x + eyedist;
newrighteye.y = lefteye.y;
neweyecenter.x = (lefteye.x + newrighteye.x)/2;
neweyecenter.y = (lefteye.y + newrighteye.y)/2;
%save the two points for further use. It is best to seperate the computation of eye points and the
%alignment of images.

righteye.x = newrighteye.x;
righteye.y = newrighteye.y;
fn_full = fullfile(folder_save, fn_save);
U22_makeifnotexist(folder_save);
save(fn_full,'lefteye','righteye');

