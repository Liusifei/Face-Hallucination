%09/15/12
%Chih-Yuan Yang
%save the results as an MAT file to plot figures
clc
clear
close all

Setting = 'Ours2_39';

%common, before setting
codefolder = fileparts(pwd);         %the Code
%addpath(fullfile(projectfolder,'Utility'));

%setting dependent
switch Setting
    case 'Ours3_1'
        datafolder = fullfile(projectfolder,'Ours3_nonupfrontal','Comparison','AutoCropAndEv_1');
        filelist = dir(fullfile(datafolder,'*.mat'));
        filenumber = length(filelist);

        methodname{1} = 'Ours3_1_1';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'GroundTruth';

        legendname{1} = 'Proposed';
        legendname{2} = 'Glasner [8]';
        legendname{3} = 'Bicubic';
        legendname{4} = 'GroundTruth';

        linespec{1} = '-bo';
        linespec{2} = '-g*';
        linespec{3} = '-r+';
        linespec{4} = '-c.';        %Cyan

        comparenumber = 4;
    case 'Ours2_20'
        datafolder = fullfile(projectfolder,'Ours2_upfrontal','Comparison','AutoCropAndEv_20');
        filelist = dir(fullfile(datafolder,'*.mat'));
        filenumber = length(filelist);

        methodname{1} = 'Ours2_1_20';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'GroundTruth';

        legendname{1} = 'Proposed';
        legendname{2} = 'Glasner [8]';
        legendname{3} = 'Bicubic';
        legendname{4} = 'GroundTruth';

        linespec{1} = '-bo';
        linespec{2} = '-g*';
        linespec{3} = '-r+';
        linespec{4} = '-c.';        %Cyan

        comparenumber = 4;
    case 'Ours2_20_Whole'
        datafolder = fullfile(projectfolder,'Ours2_upfrontal','Comparison','WholeImageEv_20');
        filelist = dir(fullfile(datafolder,'*.mat'));
        filenumber = length(filelist);

        methodname{1} = 'Ours2_1_20';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'GroundTruth';

        legendname{1} = 'Proposed';
        legendname{2} = 'Glasner [8]';
        legendname{3} = 'Bicubic';
        legendname{4} = 'GroundTruth';

        linespec{1} = '-bo';
        linespec{2} = '-g*';
        linespec{3} = '-r+';
        linespec{4} = '-c.';        %Cyan

        comparenumber = 4;
        
    case 'Ours2_21'
        datafolder = fullfile(projectfolder,'Ours2_upfrontal','Comparison','AutoCropAndEv_21');
        filelist = dir(fullfile(datafolder,'*.mat'));
        filenumber = length(filelist);

        methodname{1} = 'Ours2_1_21';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'GroundTruth';

        legendname{1} = 'Proposed';
        legendname{2} = 'Glasner [8]';
        legendname{3} = 'Bicubic';
        legendname{4} = 'GroundTruth';

        linespec{1} = '-bo';
        linespec{2} = '-g*';
        linespec{3} = '-r+';
        linespec{4} = '-c.';        %Cyan

        comparenumber = 4;
    case 'Ours2_27'
        datafolder = fullfile(projectfolder,'Ours2_upfrontal','Comparison','AutoCropAndEv_27');
        filelist = dir(fullfile(datafolder,'*.mat'));
        filenumber = length(filelist);

        methodname{1} = 'Ours_1_27';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'BicubicPlusBackProjection';
        methodname{5} = 'Sun08';
        methodname{6} = 'GroundTruth';

        legendname{1} = 'Proposed';
        legendname{2} = 'Glasner [8]';
        legendname{3} = 'Bicubic';
        legendname{4} = 'Back Projection [3]';
        legendname{5} = 'Sun08 [7]';
        legendname{6} = 'GroundTruth';

        linespec{1} = '-bo';
        linespec{2} = '-g*';
        linespec{3} = '-r+';
        linespec{4} = '-cd';        %Cyan
        linespec{5} = '-mx';
        linespec{6} = '-ks';        %black

        comparenumber = 6;
    case 'Ours2_33'
        datafolder = fullfile(projectfolder,'Ours2_upfrontal','Comparison','AutoCropAndEv_33');
        filelist = dir(fullfile(datafolder,'*.mat'));
        filenumber = length(filelist);

        methodname{1} = 'Ours_1_33';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'BicubicPlusBackProjection';
        methodname{5} = 'Sun08';
        methodname{6} = 'GroundTruth';

        legendname{1} = 'Proposed';
        legendname{2} = 'Glasner [8]';
        legendname{3} = 'Bicubic';
        legendname{4} = 'Back Projection [3]';
        legendname{5} = 'Sun08 [7]';
        legendname{6} = 'GroundTruth';

        linespec{1} = '-bo';
        linespec{2} = '-g*';
        linespec{3} = '-r+';
        linespec{4} = '-cd';        %Cyan
        linespec{5} = '-mx';
        linespec{6} = '-ks';        %black

        comparenumber = 6;
    case 'Ours2_39'
        datafolder = fullfile(codefolder,'Ours2_upfrontal','Comparison','AutoCropAndEv_39');
        filelist = dir(fullfile(datafolder,'*.mat'));
        filenumber = length(filelist);

        methodname{1} = 'Ours_1_39';
        methodname{2} = 'Glasner';
        methodname{3} = 'Bicubic';
        methodname{4} = 'BackProjection';
        methodname{5} = 'Sun08';
        methodname{6} = 'GroundTruth';

        legendname{1} = 'Proposed';
        legendname{2} = 'Glasner [8]';
        legendname{3} = 'Bicubic';
        legendname{4} = 'Back Projection [3]';
        legendname{5} = 'Sun08 [7]';
        legendname{6} = 'GroundTruth';

        linespec{1} = '-bo';
        linespec{2} = '-g*';
        linespec{3} = '-r+';
        linespec{4} = '-cd';        %Cyan
        linespec{5} = '-mx';
        linespec{6} = '-ks';        %black

        comparenumber = 6;
end
PSNRmatrix = zeros(filenumber,comparenumber);
SSIMmatrix = zeros(filenumber,comparenumber);
DIIVINEmatrix = zeros(filenumber,comparenumber);
iistart = 1;
iiend = 51;
for i=iistart:iiend
    %open specific file
    fn_data = filelist(i).name;
    loaddata = load(fullfile(datafolder,fn_data));
    for j=1:comparenumber
        PSNRmatrix(i,j) = loaddata.result.(methodname{j}).PSNR;
        SSIMmatrix(i,j) = loaddata.result.(methodname{j}).SSIM;
        DIIVINEmatrix(i,j) = loaddata.result.(methodname{j}).DIIVINE;
    end
end
hfig = figure;
hold on
for j=1:comparenumber-1
    plot(PSNRmatrix(:,j),linespec{j});
end
%title('PSNR');
ylabel('Db');
xlabel('File index');
legend(legendname,'Location','Northwest');
fn_save = sprintf('PSNR.png');
saveas(hfig,fullfile(datafolder,fn_save));
close(hfig);

hfig = figure;
hold on
for j=1:comparenumber-1
    plot(SSIMmatrix(:,j),linespec{j});
end
%title('SSIM');
ylabel('SSIM value');
xlabel('File index');
legend(legendname,'Location','Northwest');
fn_save = sprintf('SSIM.png');
saveas(hfig,fullfile(datafolder,fn_save));
close(hfig);

hfig = figure;
hold on
for j=1:comparenumber
    plot(DIIVINEmatrix(:,j),linespec{j});
end
%title('DIIVINE');
ylabel('DIVINE index');
xlabel('File index');
legend(legendname,'Location','Northwest');
fn_save = sprintf('DIIVINE.png');
saveas(hfig,fullfile(datafolder,fn_save));
close(hfig);
