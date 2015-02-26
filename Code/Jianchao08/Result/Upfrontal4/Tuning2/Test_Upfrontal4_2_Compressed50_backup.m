%Chih-Yuan Yang
%4/29/13
%Apply Jianchao's face hallucination algorithm on JPEG compressed faces
clc
clear
close all

codefolder = fileparts(pwd);
addpath(genpath(fullfile(codefolder,'Lib')));
addpath(fullfile(codefolder,'Ours2'));
addpath(genpath('Solver'));
    
para.zooming = 4;
para.settingname = 'Upfrontal';
%para.testimagefolder = fullfile(codefolder,'Ours2','Source','Upfrontal3','Input');
para.testimagefolder = '\\VISION-U1\Sfliu\PIE_for Paper\testing\Upfrontal_show\50';
para.savefolder = 'GeneratedImages';
para.setting = 4;
para.settingnote = 'For compressed image';
para.tuning = 2;
para.tuningnote = 'compression parameter 50';
para.legend = 'Jianchao';
folder_dictionary = fullfile('Data','Upfrontal3','s4','Dictionary');
fn_dictionary = 'Dictionary.mat';
folder_basisW = fullfile('Data','Upfrontal3','s4');
fn_basisW = 'BasisW.mat';

patch_size = 5; % the same as the patch size to train the dictionary
overlap = 1; % overlap between adjacent patches
lambda = 0.005; % use the same value when dictionary training
regres = 'L1'; % 'L1' or 'L2', use the sparse representation directly, or use the supports for L2 regression


fileidx_start = 1;
fileidx_end = 'all';
para.mainfilename = mfilename;

if para.zooming == 4
    para.Gau_sigma = 1.6;
elseif para.zooming == 3
    para.Gau_sigma = 1.2;
end

resultfolder = 'Result';
para = U23a_PrepareResultFolder(resultfolder, para);

%load all training images
finalsavefolder = fullfile(para.tuningfolder, para.savefolder);
folder_recon = fullfile(para.tuningfolder,'HR_recon');
U22_makeifnotexist(folder_recon);

U22_makeifnotexist(finalsavefolder);
filelist = dir(fullfile(para.testimagefolder, '*.jpg'));
filenumber = length(filelist);
if isa(fileidx_end,'char')
    if strcmp(fileidx_end,'all')
        fileidx_end = filenumber;
    end
end

%load dictionary
load(fullfile(folder_dictionary,fn_dictionary));
%load basisW
loaddata = load(fullfile(folder_basisW,fn_basisW));
basisW = loaddata.W / 255;            %the training range is 0~255, so here it needs to be devided by 255
clear loaddata
for fileidx=fileidx_start:fileidx_end
    %open specific file
    fn_test = filelist(fileidx).name;
    fn_short = fn_test(1:end-4);
    fprintf('fileidx %d, fn_test %s\n',fileidx,fn_test);
    img_lr_rgb_double = im2double(imread(fullfile(para.testimagefolder,fn_test)));
    img_lr_ycbcr_double = rgb2ycbcr(img_lr_rgb_double);
    img_y = img_lr_ycbcr_double(:,:,1);
    [h_lr, w_lr] = size(img_y);
    img_cbcr_lr = img_lr_ycbcr_double(:,:,2:3);
    zooming = para.zooming;
    h_hr = h_lr * zooming;
    w_hr = w_lr * zooming;
    img_cbcr_hr = imresize(img_cbcr_lr,zooming);
    img_bi = imresize(img_y,zooming,'bilinear');
    vector_bi = reshape(img_bi,[h_hr*w_hr,1]);
    initial_variable = basisW\vector_bi;       %this is the least square error solution
    coeflength = size(basisW,2);
    %it takes long time to run.
    %the result is very close to c* already
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    lb = zeros(coeflength,1);
    ub = [];
    nonlcon = [];
    %the optimization also takes long time
    %it is terribly slow. It is impossible to produce the optimal coef in time.
    %[x fval]= fmincon(@(x) F4_OptimizationTerm(x,basisW,img_y,sigma), initial_variable, A,b,Aeq,beq,lb,ub,nonlcon,options);
    x = initial_variable;
    vector_recon = basisW * x;
    img_recon = reshape(vector_recon,[h_hr,w_hr]);
    fn_recon = sprintf('%s_%s_%d_%d_recon.png',fn_short,para.legend,para.setting,para.tuning);
    imwrite(img_recon,fullfile(folder_recon,fn_recon));
    img_recon_255 = img_recon * 255;
    %apply sparse dictionary
    img_out_255 = F3c_L1SR_HRHR_Dictionary(img_recon_255, patch_size, overlap, Dh, Dl, lambda, regres);
    img_out = img_out_255 / 255;
    img_out_ycbcr = img_out;
    img_out_ycbcr(:,:,2:3) = img_cbcr_hr;
    img_out_rgb = ycbcr2rgb(img_out_ycbcr);
    fn_save = sprintf('%s_%s_%d_%d.png',fn_short,para.legend,para.setting,para.tuning);
    imwrite(img_out_rgb, fullfile(finalsavefolder,fn_save));
end