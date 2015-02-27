%Chih-Yuan Yang
%09/28/12
%Change the method of subsampling
%Sifei Liu
%02/22/13
%Generating compressed LR image
% hrimg: estimated HR image;
% s: zooming factor
% sigma: gaussian scale
% quality: jpeg compress quality 
function lrimg = F19b_GenerateLRImage_jpeg(hrimg,s,sigma,quality)
    if isa(hrimg,'uint8')
        hrimg = im2double(hrimg);
    end
    [h w d] = size(hrimg);
    htrim = h-mod(h,s);
    wtrim = w-mod(w,s);
    imtrim = hrimg(1:htrim,1:wtrim,1:d);
    h_lr = htrim/s;
    w_lr = wtrim/s;
    
    %detect image type
    if s == 3   %or any odd number
        kernel = F20_Sigma2Kernel(sigma);
        if d == 1
            blurimg = imfilter(imtrim,kernel,'replicate');
        elseif d == 3
            blurimg = zeros(htrim,wtrim,d);
            for i=1:3
                blurimg(:,:,i) = imfilter(imtrim(:,:,i),kernel,'replicate');
            end
        end
        lrimg = imresize(blurimg,1/s,'nearest');
    elseif s == 4
        kernelsize = ceil(sigma*3)*2+2;
        kernel = fspecial('gaussian',kernelsize,sigma);
        if d == 1
            blurimg = imfilter(imtrim,kernel,'replicate');
        elseif d == 3
            blurimg = zeros(htrim,wtrim,d);
            for i=1:3
                blurimg(:,:,i) = imfilter(imtrim(:,:,i),kernel,'replicate');
            end
        end
        lrimg = zeros(h_lr,w_lr,d);
        for didx = 1:d
            for rl=1:h_lr
                r_hr_sample = (rl-1)*s+2;       %the shift is the key issue, because the effect of imfilter using a kernel
                                                %shapened in even number width is equivalent to a 0.5 pixel shift in the
                                                %original image
                for cl = 1:w_lr
                    c_hr_sample = (cl-1)*s+2;
                    lrimg(rl,cl,didx) = blurimg(r_hr_sample,c_hr_sample,didx);
                end
            end
        end
    end
    
    % JPEG compression
    lrimg = im2jpeg(lrimg,quality);
    lrimg = lrimg.image;    
end
