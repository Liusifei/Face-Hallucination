%Chih-Yuan Yang
%10/02/12
%Use mask
function [retrievedhrimage retrievedlrimage retrievedidx] = F6b_RetriveAreaGradientsByAlign_Optimization_UseMask(testimage_lr, ...
    rawexampleimage, inputpoints, basepoints, mask_lr, zooming, Gau_sigma)
    %the rawexampleimage should be double
    if ~isa(rawexampleimage,'uint8')
        error('wrong class');
    end
%    region_hr = F30_ConvertLRRegionToHRRegion(component_lr, zooming);

    exampleimagenumber = size(rawexampleimage,3);
    %find the transform matrix by solving an optimization problem
    alignedexampleimage_hr = zeros(480,640,exampleimagenumber,'uint8');     %set as uint8 to reduce memory demand
    alignedexampleimage_lr = zeros(120,160,exampleimagenumber);
    parfor i=1:exampleimagenumber
        alignedexampleimage_hr(:,:,i) = F18_AlignExampleImageByLandmarkSet(rawexampleimage(:,:,i),inputpoints(:,:,i),basepoints);
        %F19 automatically convert uint8 input to double
        alignedexampleimage_lr(:,:,i) = F19a_GenerateLRImage_GaussianKernel(alignedexampleimage_hr(:,:,i),zooming,Gau_sigma);
    end

    %crop the region
%    mask_lr = component_lr.mask_lr;
    [r_set c_set] = find(mask_lr);
    top = min(r_set);
    bottom = max(r_set);
    left = min(c_set);
    right = max(c_set);
    area_test = im2double(testimage_lr(top:bottom,left:right));
    area_mask = mask_lr(top:bottom,left:right);
    area_test_aftermask = area_test .* area_mask;
    %extract feature from the eyerange, the features are the gradient of LR eye region
    feature_test = U16_ExtractFeatureFromArea(area_test_aftermask);     %the unit is double

    %search for the thousand example images to find the most similar eyerange
    normvalue = zeros(exampleimagenumber,1);
    parfor j=1:exampleimagenumber
        examplearea_lr = alignedexampleimage_lr(top:bottom,left:right,j);
        examplearea_lr_aftermask = examplearea_lr .* area_mask;
        feature_example_lr = U16_ExtractFeatureFromArea(examplearea_lr_aftermask);     %the unit is double
        normvalue(j) = norm(feature_test - feature_example_lr);
    end
    %find the small norm
    [sortnorm ix] = sort(normvalue);
    %some of them are very similar

    %only return the 1nn
    retrievedhrimage = alignedexampleimage_hr(:,:,ix(1)); 
    retrievedlrimage = alignedexampleimage_lr(:,:,ix(1));
    retrievedidx = ix(1);
end