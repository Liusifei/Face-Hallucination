%Chih-Yuan Yang
%09/28/12
%Change the method of subsampling
%F19f 03/20/14 update the function to accept integer scaling factors
function img_lr = F19f_GenerateLRImage_IntegerSF(img_hr,sf,sigma)
    if isa(img_hr,'uint8')
        img_hr = im2double(img_hr);
    end
    [h_hr, w_hr, d] = size(img_hr);
    h_hr_trim = h_hr-mod(h_hr,sf);
    w_hr_trim = w_hr-mod(w_hr,sf);
    img_hr_trim = img_hr(1:h_hr_trim,1:w_hr_trim,1:d);
    h_lr = h_hr_trim/sf;
    w_lr = w_hr_trim/sf;
    
    %detect image type
    if mod(sf,2) == 1   %an odd number
        kernelsize = ceil(sigma*3)*2+1;
        kernel = fspecial('gaussian',kernelsize,sigma);         %kernel is always a symmetric matrix
        img_blur = zeros(img_hr_trim,wtrim,d);
        for idx_d = 1:d
            img_blur(:,:,idx_d) = imfilter(img_hr_trim(:,:,idx_d),kernel,'replicate');
        end
        img_lr = imresize(img_blur,1/sf,'nearest');
    elseif mod(sf,2) == 0        %s is even
        sampleshift = sf/2;
        kernelsize = ceil(sigma*3)*2+2;
        kernel = fspecial('gaussian',kernelsize,sigma);         %kernel is always a symmetric matrix
        img_blur = imfilter(img_hr_trim,kernel,'replicate');
        img_lr = zeros(h_lr,w_lr,d);
        for idx_d = 1:d
            for rl=1:h_lr
                r_hr_sample = (rl-1)*sf+sampleshift; %the shift is the key issue, because the effect of imfilter using a kernel
                                                %shapened in even number width is equivalent to a 0.5 pixel shift in the
                                                %original image
                for cl = 1:w_lr
                    c_hr_sample = (cl-1)*sf+sampleshift;
                    img_lr(rl,cl,idx_d) = img_blur(r_hr_sample,c_hr_sample,idx_d);
                end
            end
        end
    end        
        
end
