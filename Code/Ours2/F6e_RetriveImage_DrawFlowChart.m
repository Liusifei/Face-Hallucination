%Chih-Yuan Yang
%6/12/13
%F6d: return the alinged images to draw the flowchart
%F6e: return the aligned landmarks so that I can draw the new figure for PAMI
function [retrievedhrimage, retrievedlrimage, retrievedidx, alignedexampleimage_hr, alignedexampleimage_lr, ...
    alignedlandmarks] = ...
    F6e_RetriveImage_DrawFlowChart(testimage_lr, ...
    rawexampleimage, inputpoints, basepoints, mask_lr, zooming, Gau_sigma, glasslist, bglassavoid)
    %the rawexampleimage should be double
    if ~isa(rawexampleimage,'uint8')
        error('wrong class');
    end

    [h_hr, w_hr, exampleimagenumber] = size(rawexampleimage);
    [h_lr, w_lr] = size(testimage_lr);
    %find the transform matrix by solving an optimization problem
    alignedexampleimage_hr = zeros(h_hr,w_hr,exampleimagenumber,'uint8');     %set as uint8 to reduce memory demand
    alignedexampleimage_lr = zeros(h_lr,w_lr,exampleimagenumber);
    arr_alignedlandmarks = cell(exampleimagenumber,1);
    parfor i=1:exampleimagenumber
        [alignedexampleimage_hr(:,:,i) , arr_alignedlandmarks{i}]= F18b_AlignExampleImageByLandmarkSet(rawexampleimage(:,:,i),inputpoints(:,:,i),basepoints);
        %F19 automatically convert uint8 input to double
        alignedexampleimage_lr(:,:,i) = F19a_GenerateLRImage_GaussianKernel(alignedexampleimage_hr(:,:,i),zooming,Gau_sigma);
    end

    [r_set, c_set] = find(mask_lr);
    top = min(r_set);
    bottom = max(r_set);
    left = min(c_set);
    right = max(c_set);
    area_test = im2double(testimage_lr(top:bottom,left:right));
    area_mask = mask_lr(top:bottom,left:right);
    area_test_aftermask = area_test .* area_mask;
    %extract feature from the eyerange, the features are the gradient of LR eye region
    feature_test = F24_ExtractFeatureFromArea(area_test_aftermask);     %the unit is double

    %search for the thousand example images to find the most similar eyerange
    normvalue = zeros(exampleimagenumber,1);
    parfor j=1:exampleimagenumber
        examplearea_lr = alignedexampleimage_lr(top:bottom,left:right,j);
        examplearea_lr_aftermask = examplearea_lr .* area_mask;
        feature_example_lr = F24_ExtractFeatureFromArea(examplearea_lr_aftermask);     %the unit is double
        normvalue(j) = norm(feature_test - feature_example_lr);
    end
    %find the small norm
    [sortnorm, ix] = sort(normvalue);
    %some of them are very similar

    %only return the 1nn
    if bglassavoid
        for k=1:exampleimagenumber
            if glasslist(ix(k)) == false
                break
            end
        end
    else
        k =1;
    end
    retrievedhrimage = alignedexampleimage_hr(:,:,ix(k)); 
    retrievedlrimage = alignedexampleimage_lr(:,:,ix(k));
    alignedlandmarks = arr_alignedlandmarks{ix(k)};
    retrievedidx = ix(k);
end