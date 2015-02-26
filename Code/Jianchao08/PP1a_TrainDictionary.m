%Chih-Yuan Yang
%10/29/12
%To implement Jianchao's ICIP08 algorithm
%PP1a: according to the ICIP paper of Jianchao, the Xl and Xh are both high-resolution patch

clear all;
clc;

codefolder = fileparts(pwd);
folder_exampleimages = fullfile(codefolder,'Ours2','Examples','NonUpfrontal3','Training');
folder_reconstructedimages = fullfile('Data','NonUpfrontal3','s4','Reconstructed');
addpath(fullfile(codefolder,'Ours2'));
folder_sampledpatches = fullfile('Data','NonUpfrontal3','s4','SampledPatches_test1');
note = '';
folder_dictionary = fullfile('Data','NonUpfrontal3','s4','Dictionary');
U22_makeifnotexist(folder_sampledpatches);
U22_makeifnotexist(folder_dictionary);

addpath('Solver');
addpath('Sparse coding');

% =====================================================================
% specify the parameter settings

patch_size = 5; %according to ICIP08 paper, the patch size is 5x5
overlap = 1; % overlap between adjacent patches
lambda = 0.005; % the parameter used in ICIP 08 paper
zooming = 4; % zooming factor, if you change this, the dictionary needs to be retrained.

skip_smp_training = true; % sample training patches
skip_dictionary_training = false; % train the coupled dictionary
num_patch = 100000; % 100000 is the number mentioned in ICIP 08 paper
codebook_size = 1024; % size of the dictionary
iterationnumber = 25;
regres = 'L1'; % 'L1' or 'L2', use the sparse representation directly, or use the supports for L2 regression
% =====================================================================
% training coupled dictionaries for super-resolution
if ~skip_smp_training,
    disp('Sampling image patches...');
    [Xh, Xl] = F1a_rnd_smp_dictionary(folder_exampleimages, folder_reconstructedimages, patch_size, num_patch);
    save(fullfile(folder_sampledpatches,'smp_patches.mat'), 'Xh', 'Xl');
    skip_dictionary_training = false;
end;

if ~skip_dictionary_training,
    load(fullfile(folder_sampledpatches,'smp_patches.mat'));
    [Dh, Dl] = F2_coupled_dic_train(Xh, Xl, codebook_size, lambda,iterationnumber);
    save(fullfile(folder_dictionary,'Dictionary.mat'), 'Dh', 'Dl');
else
    load(fullfile(folder_dictionary,'Dictionary.mat'));
end;