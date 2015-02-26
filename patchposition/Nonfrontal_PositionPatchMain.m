% PositionPatchMain.m
clear all
close all
clc;
% Setting Path
codefolder = fileparts(pwd);
addpath(genpath(fullfile(codefolder,'Lib')));
TrainingLow = '\\vision-u1\Research\120801SRForFace\code\Ours2\Examples\NonUpfrontal3\LowResolutionImages';
TestingLow = '\\vision-u1\Research\120801SRForFace\code\Ours2\Source\NonUpfrontal3\Input';
TrainingHigh = '\\vision-u1\Research\120801SRForFace\code\Ours2\Examples\NonUpfrontal3\Training';
savedir = '\\vision-u1\Research\120801SRForFace\code\PositionPatch\Data\Nonfrontal\';
RCtestLow = fullfile(savedir,'NonUpfrontal3_RCtestFaces_LRGray');
RCtestHigh = fullfile(savedir,'NonUpfrontal3_RCtestFaces_HRGray');
if ~exist(savedir,'dir')
    mkdir(savedir);
end
if ~exist(RCtestLow,'dir')
    mkdir(RCtestLow)
end
if ~exist(RCtestHigh,'dir')
    mkdir(RCtestHigh);
end

% =================Generating Training Patches====================
% set parameters
% addpath('H:\patchmatch-2.1');
Lpatchsize = 14;
Linterval = 3;
factor = 4;

% extract LR training patches
LRtraindir = dir(fullfile(TrainingHigh,'\*.png'));
LtrainNum = length(LRtraindir);
% LRpatchesFull = cell(1,LtrainNum);
if ~exist([savedir,'LRpathchesFull.mat'],'file')
    for m = 1:LtrainNum
        im = imread(fullfile(TrainingLow,LRtraindir(m).name));
        yiq = RGB2YIQ(im);
        im = yiq(:,:,1);
        [patches,max_x,max_y] = im2patches(im,Lpatchsize,Linterval);
        if m==1
            LRpatchesFull = zeros(size(patches,1),size(patches,2),LtrainNum);
        end
        LRpatchesFull(:,:,m) = patches;
    end 
    save([savedir,'LRpathchesFull.mat'],'LRpatchesFull','max_x','max_y');
else
    load([savedir,'LRpathchesFull.mat'],'LRpatchesFull','max_x','max_y');
%     clear LRpatchesFull
end

% extract HR training patches
% HRpathchesFull = cell(1,LtrainNum);
if ~exist([savedir,'HRpathchesFull.mat'],'file')
    for m = 1:LtrainNum
        %     if ~exist(fullfile(TrainingLow,sprintf('HRpatches_%.4d.mat',m)),'file')
        im = imread(fullfile(TrainingHigh,LRtraindir(m).name));
        yiq = RGB2YIQ( im ); 
        im = yiq(:,:,1);
%         imr = imresize(yiq,'bicubic');
        [patches,max_x,max_y] = im2patches(im, Lpatchsize*factor, Linterval*factor);
        if m==1
            HRpathchesFull = uint8(zeros(size(patches,1),size(patches,2),LtrainNum));
        end
        HRpathchesFull(:,:,m) = patches;
        %         save(fullfile(TrainingLow,sprintf('HRpatches_%.4d.mat',m)),'patches');
    end
    save([savedir,'HRpathchesFull.mat'],'HRpathchesFull','max_x','max_y');
else
    load([savedir,'HRpathchesFull.mat'],'HRpathchesFull','max_x','max_y');
end

%     clear HRoatchesFull


% Testing: 
% 1 downsample; 2 caculating w; 3 synthesis HR patches; 4 Present Patches
addpath('D:\Projects\PositionPatch\Bilateral Filtering');
LRtestdir = dir(fullfile(TestingLow,'*.png'));
% LRtestpatch = 'D:\Projects\PositionPatch\Data\Sele_TestFaces_LRGray';
% if ~exist(LRtestpatch,'dir')
%     mkdir(LRtestpatch);
% end
LRtestNum = length(LRtestdir);
pk = 100;
for m = 1:LRtestNum
    fprintf('Processing %.4d test image...\n',m);
    % generating LR testing image
    im = imread(fullfile(TestingLow, LRtestdir(m).name));
    img_yiq = RGB2YIQ( im2double(im) );
    IQLayer = img_yiq(:,:,2:3);
    IQLayer_upsampled = imresize(IQLayer,factor);
    IM = zeros(size(IQLayer_upsampled,1),size(IQLayer_upsampled,2),3);
    IM(:,:,2:3) = IQLayer_upsampled;
    
    img_yiq = RGB2YIQ( im );
    im = img_yiq(:,:,1);
    
%     im = Downsampling(im,factor);
%     if ~exist(fullfile(LRtestpatch, LRtestdir(m).name),'file')
%         imwrite(im,fullfile(LRtestpatch, LRtestdir(m).name));
%     end
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
    imwrite(Cons_a,[RCtestLow,'\','RC_',LRtestdir(m).name]);
    % Reconstruction of HR faces
    Cons_ha = LayoutPatches(HRreco, size(im).* factor, Linterval * factor, Lpatchsize * factor);
    %----------------------------------------------------------------------
    % Biliteral Filtering
    %----------------------------------------------------------------------
    SP_IMG = bfilter2((Cons_ha-min(Cons_ha(:)))/(max(Cons_ha(:))-min(Cons_ha(:))), 2,[1.5,0.2]);
    IM(:,:,1) = (SP_IMG-min(SP_IMG(:)))/(max(SP_IMG(:))-min(SP_IMG(:)));
    imr = YIQ2RGB(IM);
    imwrite(imr,[RCtestHigh,'\',LRtestdir(m).name]);
end
