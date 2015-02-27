%Chih-Yuan Yang
%07/20/14 I update the code to support the scaling factor of 3.
%F11c: controlled by iternum
%F11d: controled by TolF
%This file should be replace by F11e
%function img_bp = F11d_BackProjection_GaussianKernel(img_lr, img_hr, Gau_sigma, iternum,bReport,TolF)
    [h_hr] = size(img_hr,1);
    [h_lr] = size(img_lr,1);
    zooming = h_hr/h_lr;
    for i=1:iternum
        img_lr_gen = F19a_GenerateLRImage_GaussianKernel(img_hr,zooming,Gau_sigma);
        diff_lr = img_lr - img_lr_gen;
        RMSE_diff_lr = sqrt(mean2(diff_lr.^2));
        diff_hr = IF5_Upsample(diff_lr,zooming, Gau_sigma);
        %diff_hr = imresize(diff_lr,zooming,'bilinear');
        img_hr = img_hr + diff_hr;
        img_lr_new = F19a_GenerateLRImage_GaussianKernel(img_hr,zooming,Gau_sigma);
        diff_lr_new = img_lr - img_lr_new;       
        RMSE_diff_lr_afteronebackprojection = sqrt(mean2(diff_lr_new.^2));
        if bReport
            fprintf('backproject iteration=%d, RMSE_before=%0.6f, RMSE_after=%0.6f\n', ...
            i,RMSE_diff_lr,RMSE_diff_lr_afteronebackprojection);        
        end
        if RMSE_diff_lr_afteronebackprojection < TolF
            disp('RMSE_diff_lr_afteronebackprojection < TolF');
            break;
        end
    end
    img_bp = img_hr;
end
function diff_hr = IF5_Upsample(diff_lr,zooming, Gau_sigma)
    [h w] = size(diff_lr);
    h_hr = h*zooming;
    w_hr = w*zooming;
    upsampled = zeros(h_hr,w_hr);
    if zooming == 3
        for rl = 1:h
            rh = (rl-1) * zooming + 2;
            for cl = 1:w
                ch = (cl-1) * zooming + 2;
                upsampled(rh,ch) = diff_lr(rl,cl);
            end
        end
        kernelsize = ceil(Gau_sigma * 3)*2+1;
        kernel = fspecial('gaussian',kernelsize,Gau_sigma);
        diff_hr = imfilter(upsampled,kernel,'replicate');
    elseif zooming == 4
        %compute the kernel by ourself, assuming the range is 
        %control the kernel and the position of the diff
        kernelsize = ceil(Gau_sigma * 3)*2+2;      %+2 this is the even number
        kernel = fspecial('gaussian',kernelsize,Gau_sigma);
        %subsample diff_lr to (3,3), because of the result of imfilter
        for rl = 1:h
            rh = (rl-1) * zooming + 3;
            for cl = 1:w
                ch = (cl-1) * zooming + 3;
                upsampled(rh,ch) = diff_lr(rl,cl);
            end
        end
        diff_hr = imfilter(upsampled, kernel,'replicate');
    else
        error('not supported');
    end
end