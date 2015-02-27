%Chih-Yuan Yang
%09/30/12
%change rawexampleimage to uint8 to save memroy
function gradientcandidate = F6_RetriveAreaGradientsByAlign_Optimization(testimage_lr, rawexampleimage, inputpoints, basepoints, region_lr, zooming, Gau_sigma)
    %the rawexampleimage should be double
    if ~isa(rawexampleimage,'uint8')
        error('wrong class');
    end
    region_hr = F30_ConvertLRRegionToHRRegion(region_lr, zooming);

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
    area_test = im2double(testimage_lr(region_lr.top_idx:region_lr.bottom_idx,region_lr.left_idx:region_lr.right_idx));
    %extract feature from the eyerange, the features are the gradient of LR eye region
    feature_test = U16_ExtractFeatureFromArea(area_test);     %the unit is double

    %search for the thousand example images to find the most similar eyerange
    normvalue = zeros(exampleimagenumber,1);
    parfor j=1:exampleimagenumber
        examplearea_lr = alignedexampleimage_lr(region_lr.top_idx:region_lr.bottom_idx,region_lr.left_idx:region_lr.right_idx,j);
        feature_example_lr = U16_ExtractFeatureFromArea(examplearea_lr);     %the unit is double
        normvalue(j) = norm(feature_test - feature_example_lr);
    end
    %find the small norm
    [sortnorm ix] = sort(normvalue);
    %some of them are very similar
    %mostsimilarindex = ix(1:20);

    gradientcandidate = zeros(region_hr.height,region_hr.width,8,1);        %the 3rd dim is dx and dy
    %parfor j=1:20
    j=1;
        examplehrregion = alignedexampleimage_hr(region_hr.top_idx:region_hr.bottom_idx,region_hr.left_idx:region_hr.right_idx,ix(j));
        gradientcandidate(:,:,:,j) = F14_Img2Grad(im2double(examplehrregion));
    %end

end