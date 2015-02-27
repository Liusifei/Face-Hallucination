%Chih-Yuan Yang
%2/3/15
%Apply Jianchao's face hallucination algorithm on JPEG compressed faces
clc
clear
close all

folder_code = fileparts(pwd);
folder_ours = fullfile(folder_code, 'Ours2');
folder_lib = fullfile(folder_code,'Lib');
folder_bilateralfilter = fullfile(folder_lib,'BilateralFilter');
addpath(folder_bilateralfilter);
folder_filelist = fullfile(folder_ours, 'Filelist');
addpath(folder_ours);
folder_save = fullfile('Result',mfilename);
U22_makeifnotexist(folder_save);

addpath(genpath('Solver'));
folder_YIQconverter = fullfile(folder_lib,'YIQConverter');
addpath(folder_YIQconverter);
    
idx_file_start = 1;
idx_file_end = 'all';
str_legend = 'Yang08_test6';

scalingfactor = 4;
folder_dictionary = fullfile('Data','NonUpfrontal3','s4','Dictionary');
fn_dictionary = 'Dictionary.mat';
folder_basisW = fullfile('Data','NonUpfrontal3','s4');
fn_basisW = 'BasisW.mat';



patch_size = 5; % the same as the patch size to train the dictionary
overlap = 1; % overlap between adjacent patches
lambda = 0.005; % use the same value when dictionary training
regres = 'L1'; % 'L1' or 'L2', use the sparse representation directly, or use the supports for L2 regression

%load dictionary
load(fullfile(folder_dictionary,fn_dictionary));
%load basisW
loaddata = load(fullfile(folder_basisW,fn_basisW));
basisW = loaddata.W / 255;            %the training range is 0~255, so here it needs to be devided by 255
clear loaddata

fn_filelist = 'MultiPIE_NonUpfrontal3_JPEGCompressed.txt';
folder_test = fullfile(folder_ours,'Source','NonUpfrontal3','Input','JPEGCompressed');

arr_filename = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_file = length(arr_filename);
if isa(idx_file_end,'char')
    if strcmp(idx_file_end,'all')
        idx_file_end = num_file;
    end
end

for idx_file=idx_file_start:idx_file_end
    %open specific file
    fn_test = arr_filename{idx_file};
    fn_short = fn_test(1:end-4);
    fn_save = sprintf('%s_%s.png', fn_short, str_legend);        
    fprintf('fileidx %d, fn_test %s\n',idx_file,fn_test);
    if exist(fullfile(folder_save,fn_save),'file')
        fprintf('output file exist\n');
        continue
    else
        fid = fopen(fullfile(folder_save,fn_save),'w+');
        fclose(fid);
    end
    img_lr_rgb_double = im2double(imread(fullfile(folder_test,fn_test)));
    img_lr_ycbcr_double = rgb2ycbcr(img_lr_rgb_double);
    img_y = img_lr_ycbcr_double(:,:,1);
    [h_lr, w_lr] = size(img_y);
    img_cbcr_lr = img_lr_ycbcr_double(:,:,2:3);
    h_hr = h_lr * scalingfactor;
    w_hr = w_lr * scalingfactor;
    img_cbcr_hr = imresize(img_cbcr_lr,scalingfactor);
    img_bi = imresize(img_y,scalingfactor,'bilinear');
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
%    fn_recon = sprintf('%s_%s_%d_%d_recon.png',fn_short,para.legend,para.setting,para.tuning);
%    imwrite(img_recon,fullfile(folder_recon,fn_recon));
    img_recon_255 = img_recon * 255;
    %apply sparse dictionary
    img_out_255 = F3c_L1SR_HRHR_Dictionary(img_recon_255, patch_size, overlap, Dh, Dl, lambda, regres);
    img_out = img_out_255 / 255;
    img_out_ycbcr = img_out;
    img_out_ycbcr(:,:,2:3) = img_cbcr_hr;
    img_out_rgb = ycbcr2rgb(img_out_ycbcr);
%    fn_save = sprintf('%s_%s.png',fn_short,str_legend);
    imwrite(img_out_rgb, fullfile(folder_save,fn_save));
end
