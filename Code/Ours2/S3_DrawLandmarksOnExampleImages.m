%10/29/12
%Chih-Yuan Yang
%Raw landmarks on example images to see the feasible component region
%This function is used after PP2 to check the correctness of transformed landmarks

clear
close all
%load image
folder_trainingimage = fullfile('Examples','Upfrontal3','Training');
folder_landmark = fullfile('Examples','Upfrontal3','Landmarks');
folder_save = fullfile('Examples','Upfrontal3','VisualCheckLandmarks');
U22_makeifnotexist(folder_save);
filelist = dir(fullfile(folder_trainingimage,'*.png'));
filenumber = length(filelist);

for i=1:filenumber
    hfig = figure('Visible','off');
    fn_example = filelist(i).name;
    fn_short = fn_example(1:end-4);
    %fn_landmark = sprintf('%s_lm.mat',fn_short);
    fn_landmark = [fn_short '_lm.mat'];
    img_load = imread(fullfile(folder_trainingimage,fn_example));
    %loaddata = load(fullfile(folder_landmark,fn_landmark),'pts');
    loaddata = load(fullfile(folder_landmark,fn_landmark),'landmarks_aligned_offset');
%    landmarks = loaddata.pts;
    landmarks = loaddata.landmarks_aligned_offset;      %for different folder, I have different names
    clear loaddata
    imshow(img_load);
    hold on         %the hold on makes a hfig contain numerous figure, so close all before next iteration
    for j=1:68
        plot(landmarks(j,1),landmarks(j,2),'r.','markersize',15);
    end
    fn_save_png = sprintf('%s.png',fn_short);
    %fn_save_fig = sprintf('%s.fig',fn_short);
    saveas(hfig,fullfile(folder_save,fn_save_png));
    %saveas(hfig,fullfile(savefolder,fn_save_fig));
    close all
end

