%09/12/12
%Chih-Yuan Yang, EECS, UC Merced
%Compute PSNR, SSIM, DIVINE
%If you encounter a MATLAB error: Undefined function 'buildSFpyr' for input arguments of type 'double'.
%You need to install libraries which are dependencies of DIIVINE
%Steerable Pyramid Toolbox, Download from: http://www.cns.nyu.edu/~eero/steerpyr/
% action ==>compile mex in MEX subfolder, copy the pointOp.mexw64 to matlabPyrTools folder
%        ==>addpath('matlabPyrTools')
%LibSVM package for MATLAB, Download from: http://www.csie.ntu.edu.tw/~cjlin/libsvm/

function [PSNR, SSIM, DIIVINE] = F7_ComputePSNR_SSIM_DIIVINE(img_gt, img_input, bComputeDIIVINE)
    %check the type
    if isa(img_gt,'double')
        img_gt = im2uint8(img_gt);
        img_input = im2uint8(img_input);
    end
    
    if size(img_gt,3) > 1
        img_gt = rgb2gray(img_gt);
    end
    if size(img_input,3) > 1
        img_input = rgb2gray(img_input);
    end
    PSNR = measerr(img_gt, img_input);
    SSIM = ssim( img_gt, img_input);

    DIIVINE = 0;
    if ~exist('bComputeDIIVINE','var')
        bComputeDIIVINE = false;
    end
    if bComputeDIIVINE
        DIIVINE = divine(img_input);
    end
end