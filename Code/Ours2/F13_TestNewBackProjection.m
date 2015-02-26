%09/13/12
%Chih-Yuan Yang
function img_out = F13_TestNewBackProjection(img_lr, img_hr, Gau_sigma, iternum)
    img_initial = img_hr;
    img_out = img_initial;      %iternum may be 0
    for i=1:iternum
        %img_lr_gen = U3_GenerateLRImage_BlurSubSample(img_hr,zooming,Gau_sigma);
        gradients_old = F14_Img2Grad(img_hr);
        LoopNumber = 30;
        beta0 = 2^(i-1);
        beta1 = 1;
        bReport = true;
        img_out = F4_GenerateIntensityFromGradient(img_lr,img_initial,gradients_old,Gau_sigma,LoopNumber,beta0,beta1,bReport);
        img_initial = img_out;
    end
end