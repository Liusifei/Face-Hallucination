%Chih-Yuan Yang
%09/28/12
%Change from square kernel to Gaussian Kernel
function img_bp = F11c_BackProjection_GaussianKernel(img_lr, img_hr, Gau_sigma, iternum,bReport)
    [h_hr] = size(img_hr,1);
    [h_lr] = size(img_lr,1);
    zooming = h_hr/h_lr;
    for i=1:iternum
        img_lr_gen = F19a_GenerateLRImage_GaussianKernel(img_hr,zooming,Gau_sigma);
        diff_lr = img_lr - img_lr_gen;
        term_diff_lr_SSD = sum(sum(diff_lr.^2));
        diff_hr = IF5_Upsample(diff_lr,zooming, Gau_sigma);
        %diff_hr = imresize(diff_lr,zooming,'bilinear');
        img_hr = img_hr + diff_hr;
        img_lr_new = F19a_GenerateLRImage_GaussianKernel(img_hr,zooming,Gau_sigma);
        diff_lr_new = img_lr - img_lr_new;       
        term_diff_lr_SSD_afteronebackprojection = sum(sum(diff_lr_new.^2));
        if bReport
            fprintf('backproject iteration=%d, term_before=%0.3f, term_after=%0.3f\n', ...
            i,term_diff_lr_SSD,term_diff_lr_SSD_afteronebackprojection);        
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
            for cl = 1:c
                ch = (cl-1) * zooming + 2;
                upsampled(rh,ch) = diff_lr(rl,cl);
            end
        end
        kernel = Sigma2Kernel(Gau_sigma);
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
        error('not processed');
    end
end