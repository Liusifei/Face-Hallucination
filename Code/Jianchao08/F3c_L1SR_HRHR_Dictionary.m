%Chih-Yuan yang
%10/24/12
%remove a bug where the upsampled image size in not always 3x, but should be controlled by zooming
%remove a bug where the boundary can not be well filled in Jianchao's original code
%note: the format of the first argument img_recon is double but the range is 0~255
%F3a: dymanically change the dictionary so that the overlapped region can be taken into consideration
%F3b: Jianchao does not mention how to handle the overlap, the average look 
%F3c: The new dictioanry maps HR patch to HR patch, so the code in the file changes, too.
function img_hr = F3c_L1SR_HRHR_Dictionary(img_recon, patchsize, overlap, Dh, Dl, lambda, regres)
% Use sparse representation as the prior for image super-resolution
% Usage
%       [img_hr] = L1SR(img_recon, zooming, patchsize, overlap, Dh, Dl, lambda)
% 
% Inputs
%   -img_recon:           low resolution input image, single channel, e.g.
%   illuminance
%   -zooming:       zooming factor, e.g. 3
%   -patchsize:    patch size for the low resolution image
%   -overlap:       overlap among patches, e.g. 1
%   -Dh:            dictionary for the high resolution patches
%   -Dl:            dictionary for the low resolution patches
%   -regres:       'L1' use the sparse representation directly to high
%                   resolution dictionary;
%                   'L2' use the supports found by sparse representation
%                   and apply least square regression coefficients to high
%                   resolution dictionary.
% Ouputs
%   -img_hr:           the recovered image, single channel
%
% Written by Jianchao Yang @ IFP UIUC
% April, 2009
% Webpage: http://www.ifp.illinois.edu/~jyang29/
% For any questions, please email me by jyang29@uiuc.edu
%
% Reference
% Jianchao Yang, John Wright, Thomas Huang and Yi Ma. Image superresolution
% as sparse representation of raw image patches. IEEE Computer Society
% Conference on Computer Vision and Pattern Recognition (CVPR), 2008. 
%
patcharea = patchsize^2;
[h_hr, w_hr] = size(img_recon);

hf1 = [-1,0,1];
vf1 = [-1,0,1]';
hf2 = [1,0,-2,0,1];
vf2 = [1,0,-2,0,1]';

grad1 = imfilter(img_recon,hf1,'conv','same','replicate');
grad2 = imfilter(img_recon,vf1,'conv','same','replicate');
grad3 = imfilter(img_recon,hf2,'conv','same','replicate');
grad4 = imfilter(img_recon,vf2,'conv','same','replicate');

gradall(:,:,1) = grad1;
gradall(:,:,2) = grad2;
gradall(:,:,3) = grad3;
gradall(:,:,4) = grad4;

gridx = 1:patchsize-overlap:w_hr-patchsize+1;
if gridx(end) ~= w_hr-patchsize+1
    gridx = [gridx, w_hr-patchsize+1];        %fill the last one
end
gridy = 1:patchsize-overlap:h_hr-patchsize+1;
if gridy(end) ~= h_hr-patchsize+1
    gridy = [gridy, h_hr-patchsize+1];
end

img_hr = zeros([h_hr, w_hr]);
filledmap = false(h_hr,w_hr);
reconfeature = zeros(h_hr,w_hr);

%the boundary 
for cidx = 1:length(gridx)       %cidx is the index of array, not the coordinate
    sprintf('cidx = %d out of %d\n',cidx, length(gridx));
    for ridx = 1:length(gridy)
        
        c = gridx(cidx);
        c1 = c + patchsize-1;
        r = gridy(ridx);
        r1 = r+ patchsize-1;
        
        %mpatch_size: the patchsize * 2
        patch_intensity = img_recon(r:r1, c:c1);     %mIm: the middle image, 
        patch_intensity_mean = mean2(patch_intensity);
        
        %here, the feature changes, not only the gradient, but also the filled HR intensity, too,
        patch_feature = gradall(r:r1, c:c1, :);
        vector_feature = patch_feature(:);
        
        %consider the overlapped region
        processregion_image = false(h_hr,w_hr);
        processregion_image(r:r1,c:c1) = true;
        overlapregion_image = filledmap & processregion_image;
        nonoverlapregion_image = processregion_image & ~overlapregion_image;
        overlapregion_patch = overlapregion_image(r:r1,c:c1);
        overlapregion_itensity = img_hr(r:r1,c:c1);
        expectedfeature_patch = overlapregion_itensity - patch_intensity_mean;
        expectedfeature_overlap_linearize = expectedfeature_patch(overlapregion_patch);
        nonoverlapregion_patch = true(patchsize) & ~overlapregion_patch;
        %extract the intensity of filled hr
        if nnz(overlapregion_image) == 0
            overlapreconfeature = [];
            Dh_partial = [];
        else
            overlapreconfeature = expectedfeature_overlap_linearize;
            usedpixels = reshape(overlapregion_patch,[patcharea,1]);
            Dh_partial = Dh(usedpixels,:);
        end
        
        %create the new y, new Dl, and new Dh, assuming beta is 1, the same as described in paper
        y_concatenated = cat(1,vector_feature,overlapreconfeature);
        Dl_concatenated = cat(1,Dl,Dh_partial);
        Dh_concatenated = cat(1,Dh,Dh_partial);
        %norm_y = sqrt(sum(mpatchfea.^2));
        norm_concatenated = sqrt(sum(y_concatenated.^2));
        if norm_concatenated > 1,
            y_input = y_concatenated./norm_concatenated;
        else
            y_input = y_concatenated;
        end;
        w = SolveLasso(Dl_concatenated, y_input, size(Dl_concatenated, 2), 'lasso', [], lambda);

        if isempty(w),
            w = zeros(size(Dl, 2), 1);
        end

        if norm_concatenated > 1,
            reconfeature_hr_concatenated = Dh_concatenated*w*norm_concatenated;
        else
            reconfeature_hr_concatenated = Dh*w;      %this is the reconstructed
        end
        reconfeature_hr = reconfeature_hr_concatenated(1:patcharea);
        
        patchdiff_hr = reshape(reconfeature_hr, [patchsize, patchsize]);
        reconfeature(r:r1, c:c1) = patchdiff_hr;
        reconintensity_hr = patchdiff_hr + patch_intensity_mean;
        
        img_hr(nonoverlapregion_image) = reconintensity_hr(nonoverlapregion_patch);
        filledmap(r:r1, c:c1) = 1;
    end
end

fprintf('done!\n');

