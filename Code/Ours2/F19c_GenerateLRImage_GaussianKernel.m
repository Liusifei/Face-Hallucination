%Chih-Yuan Yang
%03/15/13
%Change the method of subsampling
%F19b, add the mode of scaling as 2
%F19c, add the mode of scaling as 8
function lrimg = F19c_GenerateLRImage_GaussianKernel(hrimg,s,sigma)
    if isa(hrimg,'uint8')
        hrimg = im2double(hrimg);
    end
    [h, w, d] = size(hrimg);
    htrim = h-mod(h,s);
    wtrim = w-mod(w,s);
    imtrim = hrimg(1:htrim,1:wtrim,1:d);
    h_lr = htrim/s;
    w_lr = wtrim/s;
    
    %detect image type
    if mod(s,2) == 1   
        kernelsize = ceil(sigma * 3)*2+1;       %the kernel size is odd
        kernel = fspecial('gaussian',kernelsize,sigma);
        if d == 1
            blurimg = imfilter(imtrim,kernel,'replicate');
        elseif d == 3
            blurimg = zeros(htrim,wtrim,d);
            for i=1:3
                blurimg(:,:,i) = imfilter(imtrim(:,:,i),kernel,'replicate');
            end
        end
        lrimg = imresize(blurimg,1/s,'nearest');
    elseif mod(s,2) == 0        %s is even
        sampleshift = s/2;
        kernelsize = ceil(sigma*3)*2+2;     %the kernel size is even
        kernel = fspecial('gaussian',kernelsize,sigma);         %kernel is always a symmetric matrix
        blurimg = imfilter(imtrim,kernel,'replicate');
        lrimg = zeros(h_lr,w_lr,d);
        for didx = 1:d
            for rl=1:h_lr
                r_hr_sample = (rl-1)*s+sampleshift; %the shift is the key issue, because the effect of imfilter using a kernel
                                                %shapened in even number width is equivalent to a 0.5 pixel shift in the
                                                %original image
                for cl = 1:w_lr
                    c_hr_sample = (cl-1)*s+sampleshift;
                    lrimg(rl,cl,didx) = blurimg(r_hr_sample,c_hr_sample,didx);
                end
            end
        end
    end        
end
