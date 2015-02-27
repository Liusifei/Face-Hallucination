%Chih-Yuan Yang
%2/3/15

clear
close all
clc

folder_code = fileparts(pwd);
folder_ours = fullfile(folder_code, 'Ours2');
folder_lib = fullfile(folder_code,'Lib');
folder_YIQconverter = fullfile(folder_lib,'YIQConverter');
addpath(folder_YIQconverter);
folder_bilateralfilter = fullfile(folder_lib,'BilateralFilter');
addpath(folder_bilateralfilter);
folder_filelist = fullfile(folder_ours, 'Filelist');
addpath(folder_ours);
folder_save = fullfile('Result',mfilename);
U22_makeifnotexist(folder_save);

idx_file_start = 1;
idx_file_end = 'all';
str_legend = 'Ma10_test2';

%fn_filelist = 'PubFig2_2Foundable_JPEGCompressed25_50_75_100.txt';
%folder_test = fullfile(folder_ours,'Source','PubFig2_2Foundable','JPEGCompressed');
fn_filelist = 'MultiPIE_Upfrontal_Compressed_25_50_75_100.txt';
folder_test = fullfile(folder_ours,'Source','Upfrontal3','Input','25_50_75_100');

arr_filename = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_file = length(arr_filename);
if isa(idx_file_end,'char')
    if strcmp(idx_file_end,'all')
        idx_file_end = num_file;
    end
end


% Setting Path
TrainingLow = fullfile('Data','Sele_TrainingFaces_LRGray');
TestingHigh = fullfile('Data','Sele_TestFaces_Gray');
TrainingHigh = fullfile('Data','Sele_TrainingFaces_HRGray');

RCtestLow = fullfile('Data','Sele_RCtestFaces_LRGray');
RCtestHigh = fullfile('Data','Sele_RCtestFaces_HRGray');
if ~exist(RCtestLow,'dir')
    mkdir(RCtestLow)
end
if ~exist(RCtestHigh,'dir')
    mkdir(RCtestHigh);
end
% =================Generating Training Patches====================
% set parameters
% addpath('H:\patchmatch-2.1');
Lpatchsize = 10;
Linterval = 5;
factor = 4;
scalingfactor = factor;

% extract LR training patches
LRtraindir = dir(fullfile(TrainingLow,'*.png'));
LtrainNum = length(LRtraindir);
% LRpatchesFull = cell(1,LtrainNum);
if ~exist('LRpathchesFull.mat','file')
    for m = 1:LtrainNum
        im = imread(fullfile(TrainingLow,LRtraindir(m).name));
        [patches,max_x,max_y] = im2patches(im,Lpatchsize,Linterval);
        if m==1
            LRpatchesFull = zeros(size(patches,1),size(patches,2),LtrainNum);
        end
        LRpatchesFull(:,:,m) = patches;
    end 
    save('LRpathchesFull.mat','LRpatchesFull','max_x','max_y');
else
    load('LRpathchesFull.mat','LRpatchesFull','max_x','max_y');
%     clear LRpatchesFull
end

% extract HR training patches
% HRpathchesFull = cell(1,LtrainNum);
if ~exist('HRpathchesFull.mat','file')
    for m = 1:LtrainNum
        %     if ~exist(fullfile(TrainingLow,sprintf('HRpatches_%.4d.mat',m)),'file')
        im = imread(fullfile(TrainingHigh,LRtraindir(m).name));
        [patches,max_x,max_y] = im2patches(im, Lpatchsize*factor, Linterval*factor);
        if m==1
            HRpathchesFull = uint8(zeros(size(patches,1),size(patches,2),LtrainNum));
        end
        HRpathchesFull(:,:,m) = patches;
        %         save(fullfile(TrainingLow,sprintf('HRpatches_%.4d.mat',m)),'patches');
    end
    save('HRpathchesFull.mat','HRpathchesFull','max_x','max_y');
else
    load('HRpathchesFull.mat','HRpathchesFull','max_x','max_y');
end

%     clear HRoatchesFull


% Testing: 
% 1 downsample; 2 caculating w; 3 synthesis HR patches; 4 Present Patches
%HRtestdir = dir(fullfile(TestingHigh,'*.png'));
%LRtestpatch = fullfile('Data','Sele_TestFaces_LRGray');
%if ~exist(LRtestpatch,'dir')
%    mkdir(LRtestpatch);
%end
%HRtestNum = length(HRtestdir);
pk = 50;
for idx_file = idx_file_start:idx_file_end
    fprintf('Processing %.4d test image...\n',idx_file);
    % generating LR testing image
    fn_test = arr_filename{idx_file};
    fn_short = fn_test(1:end-4);
    fn_save = sprintf('%s_%s.png', fn_short, str_legend);    
    if exist(fullfile(folder_save,fn_save),'file')
        fprintf('output file exist\n');
        %If this an empty file, its previous program may crash already. Check the size and created time
        fileinfo = dir(fullfile(folder_save,fn_save));
        if fileinfo(1).bytes == 0
            date_difference_day = now - datenum(fileinfo(1).date);
            date_difference_hour = date_difference_day * 24;
            if date_difference_hour > 3
                %overwrite the existing empty file
                fprintf('Overwrite the exiting empty file %s\n', fn_save);
                fid = fopen(fullfile(folder_save,fn_save),'w+');
                fclose(fid);   
            else
                continue
            end
        else
            continue
        end
    else
        fid = fopen(fullfile(folder_save,fn_save),'w+');
        fclose(fid);
    end
    
    img_read = im2double(imread(fullfile(folder_test, fn_test)));
    img_yiq = RGB2YIQ(img_read);
    img_y = img_yiq(:,:,1);
    im = im2uint8(img_y);
    img_iq = img_yiq(:,:,2:3);
    [patches,max_x,max_y] = im2patches(im, Lpatchsize, Linterval);
    LRreco = patches;
    HRreco = uint8(zeros(size(patches,1),size(patches,2)*factor^2));
    [pn,pl] = size(patches);
    C = ones(pk,1);
    w = zeros(pn,pk);
    pn_ind = zeros(pn,pk);
    % caculating w for each position
    for k = 1:pn
        test_P = double(patches(k,:)');
        rn = randperm(LtrainNum);
        rind = rn(1:pk);
        pn_ind(k,:) = rind;
        Y = reshape(LRpatchesFull(k,:,rind),[pl, pk]);
        X = test_P * C';
        Z = (X-Y)' * (X-Y);
        w(k,:) = ((Z+ eye(pk))\ C)/(C'* (Z+ eye(pk))^(-1) * C);
        % check LR reconstruction
        LRreco(k,:) = Y * w(k,:)'; 
        % check HR reconstruction
        HY = reshape(HRpathchesFull(k,:,rind), pl*factor^2, pk);
        HRreco(k,:) = double(HY) * w(k,:)'; 
    % HRreco(k,:) = double(HY) * ones(100,1)/100; 
    end   
    Cons_a = LayoutPatches(LRreco, size(im), Linterval, Lpatchsize);
    Cons_a = (Cons_a - min(Cons_a(:)))/(max(Cons_a(:))-min(Cons_a(:)));
%    imwrite(Cons_a,[RCtestLow,'\','RC_',HRtestdir(idx_file).name]);
    % Reconstruction of HR faces
    Cons_ha = LayoutPatches(HRreco, size(im).* factor, Linterval * factor, Lpatchsize * factor);
    %----------------------------------------------------------------------
    % Biliteral Filtering
    %----------------------------------------------------------------------
    SP_IMG = bfilter2((Cons_ha-min(Cons_ha(:)))/(max(Cons_ha(:))-min(Cons_ha(:))), 3,[1.5,0.1]);
    img_y_hr = SP_IMG;
%    imwrite(SP_IMG,[RCtestHigh,'\','RC_',HRtestdir(idx_file).name]);
    
    %Combine the Y and IQ channels
    img_iq_hr = imresize(img_iq, scalingfactor );
    img_yiq_hr = cat(3,img_y_hr,img_iq_hr);
    img_rgb_hr = YIQ2RGB(img_yiq_hr);
    imwrite(img_rgb_hr,fullfile(folder_save, fn_save));
end
