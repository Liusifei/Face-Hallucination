%Chih-Yuan Yang
%3/22/14
%I try to replace the patch match method by ICCV 13
function img_hr = F47_Upsample_ICCV13(img_y,sf, clustercenter,coef_matrix)
    %load the coef_matrix

    patchsize_hr = 3*sf;
    num_predictedpixel = (patchsize_hr)^2;
    num_pixel_hr = num_predictedpixel;
    num_cluster = size(clustercenter,2);

    [h_lr, w_lr] = size(img_y);
    %predict the hr image by learned regressor
    patchsize = 7;
    halfpatchsize = (patchsize - 1) /2;
    img_y_ext = wextend('2d','symw',img_y,halfpatchsize);       %3 pixels are extended
    arr_clusteridx = zeros(h_lr*w_lr,1);
    grad_img_y_ext = F14c_Img2Grad_fast_suppressboundary(img_y_ext);
    patchtovectorindexset = [2:6 8:42 44:48];
    
    arr_smoothpatch = false(h_lr*w_lr,1);
    img_y_ext_bb = imresize(img_y_ext,sf);
    [h_hr_ext, w_hr_ext] = size(img_y_ext_bb);
    img_hr_ext_sum = zeros(h_hr_ext,w_hr_ext);
    img_hr_ext_count = zeros(h_hr_ext,w_hr_ext);
    
    intensity_hr = zeros(num_pixel_hr,h_lr*w_lr);
    for idx=1:h_lr*w_lr         %this is prepare for parallel computing
    %parfor idx=1:h_lr*w_lr
        r = mod(idx-1,h_lr)+1;      %the (r,c) is the top-left of a patch
        c = ceil(idx/h_lr);
        r1 = r+patchsize-1;
        c1 = c+patchsize-1;
        %label the smooth region
        patch_lr_grad = grad_img_y_ext(r+1:r1-1,c+1:c1-1,:);  %this check can be further reduced
        smooth_grad = abs(patch_lr_grad) <= 0.05;       
        if sum(smooth_grad(:)) == 200
            arr_smoothpatch(idx) = true;
        else
            patch_lr = img_y_ext(r:r1,c:c1);
            vector_lr = patch_lr(patchtovectorindexset);
            patch_lr_mean = mean(vector_lr);
            feature = vector_lr' - patch_lr_mean;   %use column vector
            %determine the cluster index
            diff = repmat(feature,[1 num_cluster]) - clustercenter;     %it takes time here, try to use ANN to reduce the computational load
            l2normsquare = sum((diff.^2));
            [~,clusteridx] = min(l2normsquare);
            arr_clusteridx(idx) = clusteridx;
            if nnz(coef_matrix(:,:,clusteridx) > 10000)        %this is a bad coef
                %use bicubic interpolation
                %but the generated intensities are correct.
                arr_smoothpatch(idx) = true;
                feature_hr = coef_matrix(:,:,clusteridx) * [feature;1];            
                intensity_hr_this = feature_hr + patch_lr_mean;
                intensity_hr(:,idx) = intensity_hr_this;
            else
                feature_hr = coef_matrix(:,:,clusteridx) * [feature;1];            
                intensity_hr_this = feature_hr + patch_lr_mean;
                intensity_hr(:,idx) = intensity_hr_this;
            end
        end
    end
    intensity_hr(intensity_hr>1) = 1;
    intensity_hr(intensity_hr<0) = 0;
    
    %reconstruct hr image from predicted image
    dist = 2 * sf;      %the algorithm only recover the central (3*sf) *(3*sf) in HR, so there is a dist in HR
    for idx=1:h_lr*w_lr
        r = mod(idx-1,h_lr)+1;      %the (r,c) is the top-left of a patch
        c = ceil(idx/h_lr);

        ch = (c-1)*sf +1 + dist;
        ch1 = ch + patchsize_hr -1;
        rh = (r-1)*sf+1 + dist;
        rh1 = rh+patchsize_hr-1;
        if arr_smoothpatch(idx)
            img_hr_ext_sum(rh:rh1,ch:ch1) = img_hr_ext_sum(rh:rh1,ch:ch1) + img_y_ext_bb(rh:rh1,ch:ch1);
        else
            img_hr_ext_sum(rh:rh1,ch:ch1) = img_hr_ext_sum(rh:rh1,ch:ch1) + reshape(intensity_hr(:,idx),[patchsize_hr, patchsize_hr]);
        end
        img_hr_ext_count(rh:rh1,ch:ch1) = img_hr_ext_count(rh:rh1,ch:ch1) + 1;
    end
    
    img_hr_ext_avg = img_hr_ext_sum ./ img_hr_ext_count;
    extended_boundary_hr = halfpatchsize * sf;
    img_hr = img_hr_ext_avg(extended_boundary_hr+1:end-extended_boundary_hr,extended_boundary_hr+1:end-extended_boundary_hr);
end

