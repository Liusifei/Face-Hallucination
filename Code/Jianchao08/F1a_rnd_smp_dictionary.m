%Chih-Yuan Yang
%10/29/12
%F1: Change the original file to load '*.png'
%F1a: according to the ICIP paper of Jianchao, the Xl and Xh are both high-resolution patch
function [Xh, Xl] = F1a_rnd_smp_dictionary(folder_exampleimages, folder_reconstructedimages, patch_size, num_patch)

fpath = fullfile(folder_reconstructedimages, '*.png');
filelist = dir(fpath);
Xh = [];
Xl = [];

filenumber = length(filelist);

nums = zeros(1, filenumber);

for num = 1:length(filelist),
    img_reconstructed = imread(fullfile(folder_reconstructedimages, filelist(num).name));
    nums(num) = prod(size(img_reconstructed));
end;

nums = floor(nums*num_patch/sum(nums));

for ii = 1:filenumber,
    
    patch_num = nums(ii);
    fn_load_recon = filelist(ii).name;
    fn_short = fn_load_recon(1:end-10);
    fn_original = [fn_short '.png'];
    img_reconstructed = im2double(imread(fullfile(folder_reconstructedimages, fn_load_recon)));
    img_original = rgb2gray(im2double(imread(fullfile(folder_exampleimages, fn_original))));
    
    [H, L] = F5_sample_patches(img_reconstructed, img_original, patch_size, patch_num);
    
    Xh = [Xh, H];
    Xl = [Xl, L];
    
    fprintf('Sampled...%d\n', size(Xh, 2));
end;

