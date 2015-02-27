%08/18/13
%Chih-Yuan Yang
%Raw landmarks on example images to see the feasible component region
%This function is used after PP2 to check the correctness of transformed landmarks
%S3a: slightly modify the path for Upfrontal3_1 because I use new paths
clear
close all
clc
%load image
%folder_exampleimage = fullfile('Examples','Upfrontal3_1HighContrast','High');
%folder_landmark = fullfile('Landmarks','ManuallyLabeled','Upfrontal','Aligned');
%folder_save = fullfile('Examples','Upfrontal3_1HighContrast','VerifyLandmark');
%fn_filelist = 'TrainingImage2167Upfrontal3_1HighContrast.txt';
folder_exampleimage = fullfile('Examples','NonUpfrontal3','Training');
folder_landmark = fullfile('Examples','NonUpfrontal3','Landmarks');
folder_save = fullfile('Examples','NonUpfrontal3','VerifyLandmark');
fn_filelist = 'NonUprightFrontal_Training274.txt';
U22_makeifnotexist(folder_save);
folder_filelist = 'FileList';
arr_filename = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_files = length(arr_filename);

for idx_file = 1:num_files
    hfig = figure('Visible','off');
    fn_example = arr_filename{idx_file};
    fn_short = fn_example(1:end-4);
    fn_no_illumination = fn_short(1:end-3);
    fn_landmark = [fn_no_illumination '_05_lm.mat'];
    img_load = imread(fullfile(folder_exampleimage,fn_example));
    loaddata = load(fullfile(folder_landmark,fn_landmark),'pts');
    landmarks = loaddata.pts;      %for different folder, I have different names
    clear loaddata
    imshow(img_load);
    hold on         %the hold on makes a hfig contain numerous figure, so close all before next iteration
    for j=1:68
        plot(landmarks(j,1),landmarks(j,2),'r.','markersize',15);
    end
    fn_save_png = sprintf('%s.png',fn_short);
    saveas(hfig,fullfile(folder_save,fn_save_png));
    close all
end

