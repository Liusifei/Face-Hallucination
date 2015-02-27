%Chih-Yuan Yang
%10/29/12
%solve the optimization problem
function termvalue = F4_OptimizationTerm(c, basisW,img_y,sigma)
    [h_lr, w_lr] = size(img_y);
    vector_hr = basisW * c;
    zooming = round(sqrt(size(vector_hr,1)/(h_lr* w_lr)));
    h_hr = h_lr * zooming;
    w_hr = w_lr * zooming;
    img_hr = reshape(vector_hr,[h_hr,w_hr]);
    img_downsample = F19a_GenerateLRImage_GaussianKernel(img_hr,zooming,sigma);
    diff = img_downsample - img_y;
    term1 = sum(sum(diff.^2));
    %what is the high pass filter? the difference of two Gaussian function?
    kernel1 = fspecial('gaussian',11,1.6);
    kernel2 = fspecial('gaussian',11,1.2);
    img_Gau1 = imfilter(img_hr,kernel1,'replicate');
    img_Gau2 = imfilter(img_hr,kernel2,'replicate');
    diff = img_Gau1 - img_Gau2;
    term2 = sqrt(sum(sum(diff.^2)));
    termvalue = term1 + term2;
end