%Chih-Yuan Yang
%11/21/12
%From PW4g, but the format is different
%evaluate a single file

clc
clear
close all
folder_code = fileparts(pwd);
folder_project = fileparts(folder_code);
addpath(genpath(fullfile(folder_code,'Lib')));

%folder_files = fullfile(folder_project,'PaperWriting','CVPR13','manuscript','figs','Results','Upfrontal3','146_01_01_051_05');
%fn_short = '146_01_01_051_05';
folder_files = fullfile(folder_project,'PaperWriting','CVPR13','manuscript','figs','Results','Upfrontal3','152_01_02_051_05');
fn_short = '152_01_02_051_05';

k=0;
k=k+1;appendix_read{k} = '_backprojection_3_1.png';
k=k+1;appendix_read{k} = '_Jianchao_3_4.png';
k=k+1;appendix_read{k} = '_Ma10.png';
k=k+1;appendix_read{k} = '_Liu07.png';
k=k+1;appendix_read{k} = '_Ours_3_1.png';
k=k+1;appendix_read{k} = '.png';
groundtruthfileext = '.png';

k=0;
k=k+1;appendix_write{k} = '_backprojection_3_1';
k=k+1;appendix_write{k} = '_Jianchao_3_4';
k=k+1;appendix_write{k} = '_Ma10';
k=k+1;appendix_write{k} = '_Liu07';
k=k+1;appendix_write{k} = '_Ours_3_1';
k=k+1;appendix_write{k} = '_GroundTruth';

k=0;
k=k+1;methodname{k} = 'Irani91';
k=k+1;methodname{k} = 'Yang10';
k=k+1;methodname{k} = 'Ma10';
k=k+1;methodname{k} = 'Liu07';
k=k+1;methodname{k} = 'Proposed';
k=k+1;methodname{k} = 'GroundTruth';

folder_computeddata = fullfile(folder_files,'ComputedData');
folder_save = fullfile(folder_files,'EvaluationResults');
%common, after setting
U22_makeifnotexist(folder_save);
U22_makeifnotexist(folder_computeddata);
comparenumber = k;
PSNRlist = zeros(comparenumber,1);
SSIMlist = zeros(comparenumber,1);
DIIVINElist = zeros(comparenumber,1);

img_gt = imread(fullfile(folder_files,sprintf('%s%s',fn_short,groundtruthfileext)));
bComputeDIIVINE = true;    
for j=1:comparenumber
    img_full = imread(fullfile(folder_files,sprintf('%s%s',fn_short,appendix_read{j})));
    fn_computeddatafilename = sprintf('%s%s',fn_short,appendix_read{j});
    fn_computeddata = fullfile(folder_computeddata,sprintf('%s_computeddata.mat',fn_computeddatafilename));
    %add code here to reduce repeated computation
    if ~exist(fn_computeddata,'file');
        [PSNR, SSIM, DIIVINE] = F7_ComputePSNR_SSIM_DIIVINE(img_gt,img_full,bComputeDIIVINE);
        %save computed data
        save(fn_computeddata,'PSNR','SSIM','DIIVINE');
    else
        loaddata = load(fn_computeddata);
        PSNR = loaddata.PSNR;
        SSIM = loaddata.SSIM;
        DIIVINE = loaddata.DIIVINE;
    end

    PSNRlist(j) = PSNR;
    SSIMlist(j) = SSIM;
    DIIVINElist(j) = DIIVINE;
    result.(methodname{j}).PSNR = PSNR;
    result.(methodname{j}).SSIM = SSIM;
    result.(methodname{j}).DIIVINE = DIIVINE;
end
result.fn_short = fn_short;

%save to text file
fid = fopen(fullfile(folder_save,sprintf('%s_Ev.txt',fn_short)),'w');
for j=1:comparenumber
    fprintf(fid,'PSNR_%s%s %.2f\n',fn_short,appendix_write{j},PSNRlist(j));
end
fprintf(fid,'\n');
for j=1:comparenumber
    fprintf(fid,'SSIM_%s%s %.4f\n',fn_short,appendix_write{j},SSIMlist(j));
end
fprintf(fid,'\n');
for j=1:comparenumber
    fprintf(fid,'DIIVINE_%s%s %.2f\n',fn_short,appendix_write{j},DIIVINElist(j));
end
fclose(fid);
fn_save = sprintf('%s_Ev.mat',fn_short);
save(fullfile(folder_save,fn_save),'result');
