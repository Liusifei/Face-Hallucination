%08/09/12
%Chih-Yuan Yang, EECS, UC Merced
%Compute PSNR, SSIM, DIVINE
%If you encounter a MATLAB error: Undefined function 'buildSFpyr' for input arguments of type 'double'.
%You need to install libraries which are dependencies of DIIVINE
%Steerable Pyramid Toolbox, Download from: http://www.cns.nyu.edu/~eero/steerpyr/
% action ==>compile mex in MEX subfolder, copy the pointOp.mexw64 to matlabPyrTools folder
%        ==>addpath('matlabPyrTools')
%LibSVM package for MATLAB, Download from: http://www.csie.ntu.edu.tw/~cjlin/libsvm/

function [PSNR SSIM DIIVINE] = F15_ComputePSNR_RMSE_SSIM_DIIVINE(img_test, img_gt, para)
    %in the future, change the pathes of lib by para
    addpath(fullfile('Lib','SSIM'))
    addpath(genpath(fullfile('Lib','matlabPyrTools')));
    addpath(genpath(fullfile('Lib','libsvm-3.12')));
    addpath(fullfile('Lib','DIIVINE'))     %DIIVINE

    img_test255 = img_test * 255;
    img_gt255 = img_gt * 255;
    PSNR = measerr(img_gt255, img_test255);
    SSIM = ssim( img_gt255, img_test255);
    DIIVINE = divine(img_test255);
end