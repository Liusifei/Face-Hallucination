%Chih-Yuan Yang
%09/14/13
%The file is modified from Test_Upfrontal3_4, for the new demand from
%Ming-Hsuan about the JANUS proposal
%I also modify the stting to use a filelist, to remove the para, and to
%change the variable naming convention
clc
clear
close all

folder_code = fileparts(pwd);
addpath(genpath(fullfile(folder_code,'Lib')));
folder_ours = fullfile(folder_code,'Ours2');
addpath(folder_ours);
addpath(genpath('Solver'));
    
sf = 4;
fn_filelist_test = 'JANUSProposalDone_14.txt';
folder_recon = fullfile('Result','JANUSProposal1','Recon');
folder_save = fullfile('Result','JANUSProposal1');
folder_test = fullfile(folder_ours,'Source','JANUSProposal','input');
folder_filelist = fullfile(folder_ours,'FileList');
str_legend = 'Jianchao';
folder_dictionary = fullfile('Data','Upfrontal3','s4','Dictionary_test1_actualUpfrontal');
fn_dictionary = 'Dictionary.mat';
folder_basisW = fullfile('Data','Upfrontal3','s4');
fn_basisW = 'BasisW.mat';

patch_size = 5; % the same as the patch size to train the dictionary
overlap = 1; % overlap between adjacent patches
lambda = 0.005; % use the same value when dictionary training
regres = 'L1'; % 'L1' or 'L2', use the sparse representation directly, or use the supports for L2 regression


idx_file_start = 2;
idx_file_end = 'all';
U22_makeifnotexist(folder_save);
U22_makeifnotexist(folder_recon);
arr_filename_test = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist_test));
num_files_test = length(arr_filename_test);
if isa(idx_file_end,'char')
    if strcmp(idx_file_end,'all')
        idx_file_end = num_files_test;
    end
end

%load dictionary
load(fullfile(folder_dictionary,fn_dictionary));
%load basisW
loaddata = load(fullfile(folder_basisW,fn_basisW));
basisW = loaddata.W / 255;            %the training range is 0~255, so here it needs to be devided by 255
clear loaddata
for idx_file = idx_file_start:idx_file_end
    %open specific file
    fn_test = arr_filename_test{idx_file};
    fn_short = fn_test(1:end-4);
    fprintf('idx_file %d, fn_test %s\n',idx_file,fn_test);
    img_lr_rgb_double = im2double(imread(fullfile(folder_test,fn_test)));
    img_lr_ycbcr_double = rgb2ycbcr(img_lr_rgb_double);
    img_y = img_lr_ycbcr_double(:,:,1);
    [h_lr, w_lr] = size(img_y);
    img_cbcr_lr = img_lr_ycbcr_double(:,:,2:3);
    zooming = sf;
    h_hr = h_lr * zooming;
    w_hr = w_lr * zooming;
    img_cbcr_hr = imresize(img_cbcr_lr,zooming);
    img_bi = imresize(img_y,zooming,'bilinear');
    vector_bi = reshape(img_bi,[h_hr*w_hr,1]);
    initial_variable = basisW\vector_bi;       %this is the least square error solution
    coeflength = size(basisW,2);
    %it takes long time to run.
    %the result is very close to c* already
%     A = [];
%     b = [];
%     Aeq = [];
%     beq = [];
%     lb = zeros(coeflength,1);
%     ub = [];
%     nonlcon = [];
    %the optimization also takes long time
    %it is terribly slow. It is impossible to produce the optimal coef in time.
    %[x fval]= fmincon(@(x) F4_OptimizationTerm(x,basisW,img_y,sigma), initial_variable, A,b,Aeq,beq,lb,ub,nonlcon,options);
    x = initial_variable;
    vector_recon = basisW * x;
    img_recon = reshape(vector_recon,[h_hr,w_hr]);
    fn_recon = sprintf('%s_%s_recon.png',fn_short,str_legend);
    imwrite(img_recon,fullfile(folder_recon,fn_recon));
    img_recon_255 = img_recon * 255;
    %apply sparse dictionary
    img_out_255 = F3c_L1SR_HRHR_Dictionary(img_recon_255, patch_size, overlap, Dh, Dl, lambda, regres);
    img_out = img_out_255 / 255;
    img_out_ycbcr = img_out;
    img_out_ycbcr(:,:,2:3) = img_cbcr_hr;
    img_out_rgb = ycbcr2rgb(img_out_ycbcr);
    fn_save = sprintf('%s_%s.png',fn_short,str_legend);
    imwrite(img_out_rgb, fullfile(folder_save,fn_save));
end