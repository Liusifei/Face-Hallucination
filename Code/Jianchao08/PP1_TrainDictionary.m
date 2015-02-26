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

codefolder = fileparts(pwd);
exampleimagefolder = fullfile(codefolder,'Ours2','Examples','Upfrontal3','Training');
addpath(fullfile(codefolder,'Ours2'));
savefolder = fullfile('Data','Upfrontal3','s4');
U22_makeifnotexist(savefolder);

addpath('Solver');
addpath('Sparse coding');

% =====================================================================
% specify the parameter settings

patch_size = 3; % patch size for the low resolution input image
overlap = 1; % overlap between adjacent patches
lambda = 0.1; % sparsity parameter
zooming = 4; % zooming factor, if you change this, the dictionary needs to be retrained.

%tr_dir = 'Data/training'; % path for training images
tr_dir = exampleimagefolder;
skip_smp_training = false; % sample training patches
skip_dictionary_training = false; % train the coupled dictionary
num_patch = 50000; % number of patches to sample as the dictionary
codebook_size = 1024; % size of the dictionary
iterationnumber = 25;
regres = 'L1'; % 'L1' or 'L2', use the sparse representation directly, or use the supports for L2 regression
% =====================================================================
% training coupled dictionaries for super-resolution
if ~skip_smp_training,
    disp('Sampling image patches...');
    [Xh, Xl] = F1_rnd_smp_dictionary(tr_dir, patch_size, zooming, num_patch);
    save(fullfile(savefolder,'smp_patches.mat'), 'Xh', 'Xl');
    skip_dictionary_training = false;
end;

if ~skip_dictionary_training,
    load(fullfile(savefolder,'smp_patches.mat'));
    [Dh, Dl] = F2_coupled_dic_train(Xh, Xl, codebook_size, lambda,iterationnumber);
    save(fullfile(savefolder,'Dictionary.mat'), 'Dh', 'Dl');
else
    load(fullfile(savefolder,'Dictionary.mat'));
end;