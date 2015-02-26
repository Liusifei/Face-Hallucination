%Chih-Yuan yang
%10/24/12
%remove a bug where the upsampled image size in not always 3x, but should be controlled by zooming
%remove a bug where the boundary can not be well filled in Jianchao's original code
%note: the format of the first argument lIm is double but the range is 0~255
%F3a: dymanically change the dictionary so that the overlapped region can be taken into consideration
%F3b: Jianchao does not mention how to handle the overlap, the average look 
function [img_hr, ww] = F3b_L1SR(lIm, zooming, patch_size, overlap, Dh, Dl, lambda, regres)
% Use sparse representation as the prior for image super-resolution
% Usage
%       [img_hr] = L1SR(lIm, zooming, patch_size, overlap, Dh, Dl, lambda)
% 
% Inputs
%   -lIm:           low resolution input image, single channel, e.g.
%   illuminance
%   -zooming:       zooming factor, e.g. 3
%   -patch_size:    patch size for the low resolution image
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

[lhg, lwd] = size(lIm);
hhg = lhg*zooming;
hwd = lwd*zooming;

mIm = imresize(lIm, 2,'bicubic');
[mhg, mwd] = size(mIm);
patchsize_hr = patch_size*zooming;
patcharea_hr = patchsize_hr^2;
mpatch_size = patch_size*2;

% extract gradient feature from lIm
hf1 = [-1,0,1];
vf1 = [-1,0,1]';
hf2 = [1,0,-2,0,1];
vf2 = [1,0,-2,0,1]';

lImG11 = conv2(mIm,hf1,'same');
lImG12 = conv2(mIm,vf1,'same');
lImG21 = conv2(mIm,hf2,'same');
lImG22 = conv2(mIm,vf2,'same');

lImfea(:,:,1) = lImG11;
lImfea(:,:,2) = lImG12;
lImfea(:,:,3) = lImG21;
lImfea(:,:,4) = lImG22;

%it is very wierd why the index start from 2, change it to one
lgridx = 1:patch_size-overlap:lwd-patch_size+1;
if lgridx(end) ~= lwd-patch_size+1
    lgridx = [lgridx, lwd-patch_size+1];        %fill the last one
end
lgridy = 1:patch_size-overlap:lhg-patch_size+1;
if lgridy(end) ~= lhg-patch_size+1
    lgridy = [lgridy, lhg-patch_size+1];
end

%the index of extract features from middle resolution
mgridx = (lgridx - 1)*2 + 1;    %the horizonal sample coordinate of the x2 interpolated image
mgridy = (lgridy - 1)*2 + 1;    %the vertical

% using linear programming to find sparse solution
bimg_hr = imresize(lIm, zooming, 'bicubic');
img_hr = zeros([hhg, hwd]);
%nrml_mat = zeros([hhg, hwd]);
h_hr = hhg;
w_hr = hwd;
filledmap = false(h_hr,w_hr);
reconfeature = zeros(h_hr,w_hr);
nrml_mat = zeros(h_hr,w_hr);

hgridx = (lgridx-1)*zooming + 1;        %the destination in HR
hgridy = (lgridy-1)*zooming + 1;

disp('Processing the patches sequentially...');
count = 0;

% loop to recover each patch
for cidx = 1:length(mgridx)       %cidx is the index of array, not the coordinate
    for ridx = 1:length(mgridy)
        
        %the index in LR is disregarded because it is irrelevant to feature extraction
        c_mr = mgridx(cidx);     %cidx is the coordinate of the index in middle resolution
        r_mr = mgridy(ridx);
        
        c_hr = hgridx(cidx);
        r_hr = hgridy(ridx);
        
        count = count + 1;
        if ~mod(count, 100),
            fprintf('.\n');
        else
            fprintf('.');
        end;
        
        %mpatch_size: the patchsize * 2
        mpatch = mIm(r_mr:r_mr+mpatch_size-1, c_mr:c_mr+mpatch_size-1);     %mIm: the middle image, 
        mmean = mean(mpatch(:));
        
        %here, the feature changes, not only the gradient, but also the filled HR intensity, too,
        mpatchfea = lImfea(r_mr:r_mr+mpatch_size-1, c_mr:c_mr+mpatch_size-1, :);
        mpatchfea = mpatchfea(:);
        
        %consider the overlapped region
        processregion_image = false(h_hr,w_hr);
        processregion_image(r_hr:r_hr+patchsize_hr-1,c_hr:c_hr+patchsize_hr-1) = true;
        overlapregion_image = filledmap & processregion_image;
        nonoverlapregion_image = processregion_image & ~overlapregion_image;
        overlapregion_patch = overlapregion_image(r_hr:r_hr+patchsize_hr-1,c_hr:c_hr+patchsize_hr-1);
        overlapregion_itensity = img_hr(r_hr:r_hr+patchsize_hr-1,c_hr:c_hr+patchsize_hr-1);
        expectedfeature_patch = overlapregion_itensity - mmean;
        expectedfeature_overlap_linearize = expectedfeature_patch(overlapregion_patch);
        nonoverlapregion_patch = true(patchsize_hr) & ~overlapregion_patch;
        %extract the intensity of filled hr
        if nnz(overlapregion_image) == 0
            overlapreconfeature = [];
            Dh_partial = [];
        else
            overlapreconfeature = expectedfeature_overlap_linearize;
            usedpixels = reshape(overlapregion_patch,[patcharea_hr,1]);
            Dh_partial = Dh(usedpixels,:);
        end
        
        %create the new y, new Dl, and new Dh, assuming beta is 1, the same as described in paper
        y_concatenated = cat(1,mpatchfea,overlapreconfeature);
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
        end;

        if norm_concatenated > 1,
            reconfeature_hr_concatenated = Dh_concatenated*w*norm_concatenated;
        else
            reconfeature_hr_concatenated = Dh*w;      %this is the reconstructed
        end
        reconfeature_hr = reconfeature_hr_concatenated(1:patcharea_hr);
        
        patchdiff_hr = reshape(reconfeature_hr, [patchsize_hr, patchsize_hr]);
        reconfeature(r_hr:r_hr+patchsize_hr-1, c_hr:c_hr+patchsize_hr-1) = patchdiff_hr;
        reconintensity_hr = patchdiff_hr + mmean;
        
        %try not overlap
        %img_hr(r_hr:r_hr+patchsize_hr-1, c_hr:c_hr+patchsize_hr-1)...
        %    = img_hr(r_hr:r_hr+patchsize_hr-1, c_hr:c_hr+patchsize_hr-1) + reconintensity_hr;
        img_hr(nonoverlapregion_image) = reconintensity_hr(nonoverlapregion_patch);
        nrml_mat(nonoverlapregion_image) = nrml_mat(nonoverlapregion_image) + 1;
        %nrml_mat(r_hr:r_hr+patchsize_hr-1, c_hr:c_hr+patchsize_hr-1)...
        %    = nrml_mat(r_hr:r_hr+patchsize_hr-1, c_hr:c_hr+patchsize_hr-1) + 1;
        filledmap(r_hr:r_hr+patchsize_hr-1, c_hr:c_hr+patchsize_hr-1) = 1;
        
    end
end

fprintf('done!\n');

nrml_mat(nrml_mat < 1) = 1;
img_hr = img_hr./nrml_mat;


