%Chih-Yuan Yang
%07/20/14 I update the file to support the scaling factor of 3.
%This function is the same as IF5 used in F4d,
function diff_hr = F26_UpsampleAndBlur(diff_lr,zooming, Gau_sigma)
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