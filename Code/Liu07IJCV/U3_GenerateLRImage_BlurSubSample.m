function lrimg = U3_GenerateLRImage_BlurSubSample(hrimg,s,sigma)
    [h w d] = size(hrimg);
    htrim = h-mod(h,s);
    wtrim = w-mod(w,s);
    imtrim = hrimg(1:htrim,1:wtrim,1:d);
    
    kernel = Sigma2Kernel(sigma);
    if d == 1
        blurimg = imfilter(imtrim,kernel,'replicate');
    elseif d == 3
        blurimg = zeros(htrim,wtrim,d);
        for i=1:3
            blurimg(:,:,i) = imfilter(imtrim(:,:,i),kernel,'replicate');
        end
    end
    lrimg = imresize(blurimg,1/s,'bilinear','antialias',false);
end
