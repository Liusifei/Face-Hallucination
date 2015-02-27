%Chih-Yuan Yang
%09/11/12
%Solve the hair and background problem
%This idea does not work
function gradientcandidate = F8_RetriveAreaGradientsByAlign_Optimization_PatchCompare(testimage_lr, rawexampleimage, inputpoints, basepoints, region_lr, zooming, Gau_sigma)
    region_hr = U18_ConvertLRRegionToHRRegion(region_lr, zooming);
    exampleimagenumber = size(rawexampleimage,3);
    %find the transform matrix by solving an optimization problem
    parfor i=1:exampleimagenumber
        alignedexampleimage_hr(:,:,i) = U20_AlignExampleImageByLandmarkSet(rawexampleimage(:,:,i),inputpoints(:,:,i),basepoints);
        alignedexampleimage_lr(:,:,i) = U3_GenerateLRImage_BlurSubSample(im2double(alignedexampleimage_hr(:,:,i)),zooming,Gau_sigma);
    end

    %Patch to patch searching to reconstruct the back ground and hair, take how much NN? try 5
    patchsize_lr = 5;
    %use feature as intensity
    [h_hr w_hr] = size(alignedexampleimage_hr(:,:,1));
    [h_lr w_lr] = size(alignedexampleimage_lr(:,:,1));
    %how much overlap? try 1
    overlap_lr = 1;
    stepforward_lr = patchsize_lr - overlap_lr;
    r_last = h_lr-patchsize_lr+1;
    rlist = 1:stepforward_lr:r_last;
    if rlist(end) ~= r_last
        rlist = [rlist r_last];
    end
    c_last = w_lr-patchsize_lr+1;
    clist = 1:stepforward_lr:c_last;
    if clist(end) ~= c_last
        clist = [clist c_last];
    end
    
    samplenumber = length(clist)*length(rlist);
    for r = rlist
        for c = clist
            
        end
    end
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