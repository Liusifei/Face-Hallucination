%Chih-Yuan Yang
%09/16/12
%for CVPR13
clear
codefolder = fileparts(pwd);
projectfolder = fileparts(codefolder);
%trimfolder = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','ComparisonFigures','Comparison39');
%trimfolder = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Illustration','FlowChart2');
%trimfolder = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Illustration','Edge2');
%trimfolder = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Illustration','ThreeSources3');
%trimfolder = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Illustration','Components_SimonBaker');
%trimfolder = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','EdgePriors');
%trimfolder = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Illustration','SmoothnessPreservingUpsampling');
%trimfolder = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Results','Failure');
%trimfolder = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','EdgePriors2');
%trimfolder = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Results','Failure2','Ali_Landry_0071');
%trimfolder = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Results','Failure2','156_02_03_051_05');
%trimfolder = 'C:\Users\Chih-Yuan\Dropbox\vision\paper\2013\CVPR\facehallucination\Poster\figs_new\Components3_ForPoster';
%trimfolder = 'C:\Users\Chih-Yuan\Dropbox\vision\paper\2013\CVPR\facehallucination\Poster\figs_new\ThreeSources5_ReUpsample';
%trimfolder = 'C:\Users\Chih-Yuan\Dropbox\vision\paper\2013\PAMI13\facehallucination\figs\Illustration\DirectionPreservingUpsampling2';
%trimfolder = 'C:\Users\Chih-Yuan\Dropbox\vision\paper\2013\PAMI13\facehallucination\figs\Illustration\Components3';
%trimfolder = 'C:\Users\Chih-Yuan\Dropbox\vision\paper\2013\PAMI13\facehallucination\figs\Illustration\Edge3';
%trimfolder = 'C:\Users\Chih-Yuan\Dropbox\vision\paper\2013\PAMI13\facehallucination\figs\Illustration\ThreeSources4_Comparison';
%trimfolder = 'C:\Users\Chih-Yuan\Dropbox\vision\paper\2013\PAMI13\facehallucination\figs\Illustration\EdgePrior3';
%trimfolder = 'F:\Documents\Research\Project\120801SRForFace\PaperWriting\CVPR13\manuscript\figs\Illustration\SmoothnessPreservingUpsampling';
trimfolder = 'F:\Documents\Research\Project\120801SRForFace\Code\Ours2\Result\Test17_GenerateFigureForPAMI15';
if ~exist(trimfolder,'dir')
    error('folder does not exist.');
end
savefolder = fullfile(trimfolder,'TrimResults');
U22_makeifnotexist(savefolder);
filetype = 'png';
filelist = dir(fullfile(trimfolder,sprintf('*.%s',filetype)));
filenumber = length(filelist);
downratio = 0.5;

for i=1:filenumber
    fn_read = filelist(i).name;
    fn_short = fn_read(1:end-4);
    img = im2double(imread(fullfile(trimfolder,fn_read)));
    if size(img,3) == 3
        img_gray = rgb2gray(img);
    else
        img_gray = img;
    end
    [h w] = size(img_gray);
    nonwhite = img_gray < 1;
    [r_set c_set] = find(nonwhite);
    top = min(r_set);
    bottom = max(r_set);
    left = min(c_set);
    right = max(c_set);
    img_trim = img(top:bottom,left:right,:);
    fn_save = sprintf('%s_trim.%s',fn_short,filetype);
    imwrite(img_trim,fullfile(savefolder,fn_save));

    fn_save = sprintf('%s_trimdown.%s',fn_short,filetype);
    img_trimdown = imresize(img_trim,downratio);
    imwrite(img_trimdown,fullfile(savefolder,fn_save));
end
