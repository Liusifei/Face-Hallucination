%Chih-Yuan Yang
%07/20/14
%I replace F19a to F19c to support the scaling factor of 3. In addition, F19c is simpler.
function f = F28_ComputeSquareSumLowHighDiff(img,img_low,Gau_sigma)
    zooming = size(img,1)/size(img_low,1);
    img_lr_generated = F19c_GenerateLRImage_GaussianKernel(img,zooming,Gau_sigma);
    diff = img_low - img_lr_generated;
    Sqr = diff.^2;
    f = sum(Sqr(:));
end
