%Chih-Yuan Yang
%09/04/12
function gradientcandidate = F5_RetriveAreaGradientsByAlign(testimage_lr, rawexampleimage, inputpoints, basepoints, region_lr, zooming, Gau_sigma)
    %copy nose region
%    region_lr.left_coor = min(landmarks_test_lr(28:36,1));
%    region_lr.right_coor = max(landmarks_test_lr(28:36,1));
%    region_lr.top_coor = min(landmarks_test_lr(28:36,2));
%    region_lr.bottom_coor = max(landmarks_test_lr(28:36,2));
    %extend the coordinate range to pixel index
%    region_lr.left_idx = floor(region_lr.left_coor);
%    region_lr.top_idx = floor(region_lr.top_coor);
%    region_lr.right_idx = floor(region_lr.right_coor) +1;
%    region_lr.bottom_idx = floor(region_lr.bottom_coor) +1;
    
    region_hr.left_idx = (region_lr.left_idx-1) * zooming + 1;
    region_hr.top_idx = (region_lr.top_idx-1) * zooming + 1;
    region_hr.right_idx = region_lr.right_idx * zooming;
    region_hr.bottom_idx = region_lr.bottom_idx * zooming;
    region_hr.width = region_hr.right_idx - region_hr.left_idx + 1;
    region_hr.height = region_hr.bottom_idx - region_hr.top_idx + 1;

    %realign for nose point 28 and 34
    %I am not sure whether the two points are the best two, test more positions later
    %compute inputpoints of nose
    disp('aligning HR images and generating LR images');
    exampleimagenumber = size(rawexampleimage,3);
    parfor i=1:exampleimagenumber
        alignedexampleimage_hr(:,:,i) = U17_AlignExampleImageByTwoPoints(rawexampleimage(:,:,i),inputpoints(:,:,i),basepoints);
        alignedexampleimage_lr(:,:,i) = U3_GenerateLRImage_BlurSubSample(im2double(alignedexampleimage_hr(:,:,i)),zooming,Gau_sigma);
    end

    %crop the region
    area_test = testimage_lr(region_lr.top_idx:region_lr.bottom_idx,region_lr.left_idx:region_lr.right_idx);
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

    gradientcandidate = zeros(region_hr.height,region_hr.width,8,20);        %the 3rd dim is dx and dy
    parfor j=1:20
        examplehrregion = alignedexampleimage_hr(region_hr.top_idx:region_hr.bottom_idx,region_hr.left_idx:region_hr.right_idx,ix(j));
        gradientcandidate(:,:,:,j) = Img2Grad(im2double(examplehrregion));
    end

end