% Image super-resolution using sparse representation
% Example code
%
% Nov. 2, 2007. Jianchao Yang
% IFP @ UIUC
%
% Revised version. April, 2009.
%
% Reference
% Jianchao Yang, John Wright, Thomas Huang and Yi Ma. Image superresolution
% via sparse representation of raw image patches. IEEE Computer Society
% Conference on Computer Vision and Pattern Recognition (CVPR), 2008. 
%
% For any questions, email me by jyang29@illinois.edu

clear all;
clc;

addpath('Solver');
addpath('Sparse coding');

TrainIIDS = dlmread('Data\Test\BSDS300\iids_train.txt');

% =====================================================================
% specify the parameter settings

patch_size = 3; % patch size for the low resolution input image
overlap = 1; % overlap between adjacent patches
lambda = 0.1; % sparsity parameter
zooming = 3; % zooming factor, if you change this, the dictionary needs to be retrained.

tr_dir = 'Data/training'; % path for training images
num_patch = 50000; % number of patches to sample as the dictionary
codebook_size = 1024; % size of the dictionary
load('Data/Dictionary/Dictionary.mat');
regres = 'L1'; % 'L1' or 'L2', use the sparse representation directly, or use the supports for L2 regression
% =====================================================================
% training coupled dictionaries for super-resolution
idxStart = 163;
Para.folder = 'train';

for i= idxStart:length(TrainIIDS)
    clear ReconIm
    FileNameShort = num2str(TrainIIDS(i));
    fname = ['Data\Test\BSDS300\images\' Para.folder '\' FileNameShort '.jpg'];
    testIm = imread(fname); % testIm is a high resolution image, we downsample it and do super-resolution

    if rem(size(testIm,1),2) ~=0,
        nrow = floor(size(testIm,1)/2)*2;
        testIm = testIm(1:nrow,:,:);
    end;
    if rem(size(testIm,2),2) ~=0,
        ncol = floor(size(testIm,2)/2)*2;
        testIm = testIm(:,1:ncol,:);
    end;

    lowIm = imresize(testIm , 1/2);

    interpIm = imresize(lowIm,zooming,'bicubic');

    % work with the illuminance domain only
    lowIm2 = rgb2ycbcr(lowIm);
    lImy = double(lowIm2(:,:,1));

    % bicubic interpolation for the other two channels
    interpIm2 = rgb2ycbcr(interpIm);
    hImcb = interpIm2(:,:,2);
    hImcr = interpIm2(:,:,3);

    % ======================================================================
    % Super-resolution using sparse representation

    disp('Start superresolution...');

    [hImy] = L1SR(lImy, zooming, patch_size, overlap, Dh, Dl, lambda, regres);

    ReconIm(:,:,1) = uint8(hImy);
    ReconIm(:,:,2) = hImcb;
    ReconIm(:,:,3) = hImcr;

    ReconIm = ycbcr2rgb(ReconIm);
    imwrite(uint8(ReconIm),['Data/Test/BSDS300Result\' num2str(i) '_' FileNameShort '_Jianchao.png']);
end