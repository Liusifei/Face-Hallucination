%Chih-Yuan Yang
%2/3/15
%Use patchmatch to retrieve a texture background
%F37h: This file is updated from F37f to support the scaling factor of 3.
%F37i: Now I run the code on Linux machines where the parfor is unstable. Thus I change the parfor to for
function [gradients_texture, img_texture, img_texture_backprojection] = F37i_GetTexturePatchMatch_SingleFor(img_y, ...
    hrexampleimages, lrexampleimages, landmarks_test, rawexamplelandmarks)

    %parameter
    numberofHcandidate = 10;
    
    %start
    [h_lr, w_lr, exampleimagenumber] = size(lrexampleimages);
    [h_hr, w_hr, ~] = size(hrexampleimages);
    scalingfactor = floor(h_hr/h_lr);
    if scalingfactor == 4
        Gau_sigma = 1.6;
    elseif scalingfactor == 3
        Gau_sigma = 1.2;
    end
    alignedexampleimage_hr = zeros(h_hr,w_hr,exampleimagenumber,'uint8');     %set as uint8 to reduce memory demand
    alignedexampleimage_lr = zeros(h_lr,w_lr,exampleimagenumber);
    disp('align images');
    set = 28:48;  %eyes and nose
    basepoints = landmarks_test(set,:);
    inputpoints = rawexamplelandmarks(set,:,:);
    
    for k=1:exampleimagenumber
        alignedexampleimage_hr(:,:,k) = F18_AlignExampleImageByLandmarkSet(hrexampleimages(:,:,k),inputpoints(:,:,k),basepoints);
        %F19 automatically convert uint8 input to double
        alignedexampleimage_lr(:,:,k) = F19c_GenerateLRImage_GaussianKernel(alignedexampleimage_hr(:,:,k),scalingfactor,Gau_sigma);
    end
    
    cores = 2;    % Use more cores for more speed

    if cores==1
      algo = 'cpu';
    else
      algo = 'cputiled';
    end
    patchsize_lr = 5;
    nn_iters = 5;

    A = repmat(img_y,[1 1 3]);
    testnumber = exampleimagenumber;
    xyandl2norm = zeros(h_lr,w_lr,3,testnumber,'int32');
    disp('patchmatching');
    for i=1:testnumber;
        %run patchmatch
        B = repmat(alignedexampleimage_lr(:,:,i),[1 1 3]);
        xyandl2norm(:,:,:,i) = nnmex(A, B, algo, patchsize_lr, nn_iters, [], [], [], [], cores);       %the return totalpatchnumber int32
    end
    l2norm_double = double(xyandl2norm(:,:,3,:));
    [sortedl2norm, ix] = sort(l2norm_double,4);
    hrpatchextractdata = zeros(h_lr-patchsize_lr+1,w_lr-patchsize_lr+1,numberofHcandidate,3);      %ii,r_lr_src,c_lr_src
    %here
    hrpatchsimilarity = zeros(h_lr-patchsize_lr+1,w_lr-patchsize_lr+1,numberofHcandidate);
    parameter_l2normtosimilarity = 625;
    for rl = 1:h_lr-patchsize_lr+1
        for cl = 1:w_lr-patchsize_lr+1
            for k=1:numberofHcandidate
                knnidx = ix(rl,cl,1,k);
                x = xyandl2norm(rl,cl,1,knnidx);      %start from 0
                y = xyandl2norm(rl,cl,2,knnidx);
                clsource = x+1;
                rlsource = y+1;
                hrpatchextractdata(rl,cl,k,:) = reshape([knnidx rlsource clsource],[1 1 1 3]);
                hrpatchsimilarity(rl,cl,k) = exp(-sortedl2norm(rl,cl,1,knnidx)/parameter_l2normtosimilarity);
            end
        end
    end
                    
    hrpatch = F39_ExtractAllHrPatches(patchsize_lr,scalingfactor, hrpatchextractdata,alignedexampleimage_hr);
    hrpatch = F40_CompensateHRpatches(hrpatch, img_y, scalingfactor, hrpatchextractdata,alignedexampleimage_lr);

    %mostsimilarinputpatchrecord = IF2_SearchForSelfSimilarPatchesL2Norm(img_y,patchsize_lr);
    
    %hrpatch_filtered = IF3_SimilarityFilter(hrpatch,hrpatchsimilarity,mostsimilarinputpatchrecord);
    
    %img_texture = IF4_BuildHRimagefromHRPatches(hrpatch_filtered,scalingfactor);
    img_texture = IF4_BuildHRimagefromHRPatches(hrpatch,scalingfactor);
    iternum = 1000;
    Tolf = 0.0001;
    breport = false;
    disp('backprojection for img_texture');
    img_texture_backprojection = F11e_BackProjection_GaussianKernel(img_y, img_texture, Gau_sigma, iternum,breport,Tolf);
    
    %extract the graident
    gradients_texture = F14_Img2Grad(img_texture_backprojection);
end
function img_texture = IF4_BuildHRimagefromHRPatches(hrpatch,scalingfactor)
    %reconstruct the high-resolution image
    patchsize_hr = size(hrpatch,1);
    patchsize_lr = patchsize_hr/scalingfactor;
    h_lr = size(hrpatch,3) + patchsize_lr - 1;
    w_lr = size(hrpatch,4) + patchsize_lr - 1;
    h_expected = h_lr * scalingfactor;
    w_expected = w_lr * scalingfactor;
    img_texture = zeros(h_expected,w_expected);
    
    if scalingfactor == 4
        transfer_region_r = 9:12;     %This is the region of the central 4x4 pixels of a 20x20 patch
        transfer_region_c = 9:12;
    elseif scalingfactor == 3
        transfer_region_r = 7:9;     %This is the region of the central 3x3 pixels of a 15x15 patch        
        transfer_region_c = 7:9;
    end
    % Central region.
    rpixelshift = 2;        %this should be modified according to patchsize_lr
    cpixelshift = 2;
    for rl = 2:h_lr - patchsize_lr
        rh_begin_idx = (rl-1+rpixelshift)*scalingfactor+1;
        rh_end_idx = rh_begin_idx+scalingfactor-1;
        for cl = 2:w_lr - patchsize_lr
            ch_begin_idx = (cl-1+cpixelshift)*scalingfactor+1;
            ch_end_idx = ch_begin_idx+scalingfactor-1;
            usedhrpatch = hrpatch(:,:,rl,cl);
            img_texture(rh_begin_idx:rh_end_idx,ch_begin_idx:ch_end_idx) = usedhrpatch(transfer_region_r,transfer_region_c);
        end
    end
    
    %left
    if scalingfactor == 4
        transfer_region_r = 9:12;     %This is a region of the left 4x12 pixels of a 20x20 patch
        transfer_region_c = 1:12;
    elseif scalingfactor == 3
        transfer_region_r = 7:9;     %This is a region of the left 3x9 pixels of a 15x15 patch        
        transfer_region_c = 1:9;
    end
    cl = 1;
    ch = 1;
    ch1 = ch+3*scalingfactor-1;
    for rl=2:h_lr-patchsize_lr
        rh = (rl-1+rpixelshift)*scalingfactor+1;
        rh1 = rh+scalingfactor-1;
        usedhrpatch = hrpatch(:,:,rl,cl);
        img_texture(rh:rh1,ch:ch1) = usedhrpatch(transfer_region_r,transfer_region_c);
    end
    
    %right
    if scalingfactor == 4
        transfer_region_r = 9:12;     %This is a region of the right 4x12 pixels of a 20x20 patch
        transfer_region_c = 9:20;
    elseif scalingfactor == 3
        transfer_region_r = 7:9;     %This is a region of the right 3x9 pixels of a 15x15 patch        
        transfer_region_c = 7:15;
    end
    cl = w_lr - patchsize_lr+1;
    ch = w_expected - 3*scalingfactor+1;
    ch1 = w_expected;
    for rl=2:h_lr-patchsize_lr
        rh = (rl-1+rpixelshift)*scalingfactor+1;
        rh1 = rh+scalingfactor-1;
        usedhrpatch = hrpatch(:,:,rl,cl);
        img_texture(rh:rh1,ch:ch1) = usedhrpatch(transfer_region_r,transfer_region_c);
    end
    
    %top
    if scalingfactor == 4
        transfer_region_r = 1:12;     %This is a region of the top 12x4 pixels of a 20x20 patch
        transfer_region_c = 9:12;
    elseif scalingfactor == 3
        transfer_region_r = 1:9;     %This is a region of the top 9x3 pixels of a 15x15 patch        
        transfer_region_c = 7:9;
    end
    rl = 1;
    rh = 1;
    rh1 = rh+3*scalingfactor-1;
    for cl=2:w_lr-patchsize_lr
        ch = (cl-1+cpixelshift)*scalingfactor+1;
        ch1 = ch+scalingfactor-1;
        usedhrpatch = hrpatch(:,:,rl,cl);
        img_texture(rh:rh1,ch:ch1) = usedhrpatch(transfer_region_r,transfer_region_c);
    end
    
    %bottom
    if scalingfactor == 4
        transfer_region_r = 9:20;     %This is a region of the bottom 12x4 pixels of a 20x20 patch
        transfer_region_c = 9:12;
    elseif scalingfactor == 3
        transfer_region_r = 7:15;     %This is a region of the bottom 9x3 pixels of a 15x15 patch        
        transfer_region_c = 7:9;
    end
    rl = h_lr-patchsize_lr+1;
    rh = h_expected - 3*scalingfactor+1;
    rh1 = h_expected;
    for cl=2:w_lr-patchsize_lr
        ch = (cl-1+cpixelshift)*scalingfactor+1;
        ch1 = ch+scalingfactor-1;
        usedhrpatch = hrpatch(:,:,rl,cl);
        img_texture(rh:rh1,ch:ch1) = usedhrpatch(transfer_region_r,transfer_region_c);
    end
    
    %left-top corner
    if scalingfactor == 4
        transfer_region_r = 1:12;     %This is a region of the left-top 12x12 pixels of a 20x20 patch
        transfer_region_c = 1:12;
    elseif scalingfactor == 3
        transfer_region_r = 1:9;     %This is a region of the left-top 9x9 pixels of a 15x15 patch        
        transfer_region_c = 1:9;
    end
    rl=1;
    cl=1;
    rh = 1;
    rh1 = rh+3*scalingfactor-1;
    ch = 1;
    ch1 = ch+3*scalingfactor-1;
    usedhrpatch = hrpatch(:,:,rl,cl);
    img_texture(rh:rh1,ch:ch1) = usedhrpatch(transfer_region_r,transfer_region_c);
    
    %right-top corner
    if scalingfactor == 4
        transfer_region_r = 1:12;     %This is a region of the right-top 12x12 pixels of a 20x20 patch
        transfer_region_c = 9:20;
    elseif scalingfactor == 3
        transfer_region_r = 1:9;     %This is a region of the right-top 9x9 pixels of a 15x15 patch        
        transfer_region_c = 7:15;
    end
    rl=1;
    cl=w_lr-patchsize_lr+1;
    rh = (rl-1)*scalingfactor+1;
    rh1 = rh+3*scalingfactor-1;
    ch = (cl-1+cpixelshift)*scalingfactor+1;
    ch1 = ch+3*scalingfactor-1;
    usedhrpatch = hrpatch(:,:,rl,cl);
    img_texture(rh:rh1,ch:ch1) = usedhrpatch(transfer_region_r,transfer_region_c);
    
    %left-bottom corner
    if scalingfactor == 4
        transfer_region_r = 9:20;     %This is a region of the left-bottom 12x12 pixels of a 20x20 patch
        transfer_region_c = 1:12;
    elseif scalingfactor == 3
        transfer_region_r = 7:15;     %This is a region of the left-bottom 9x9 pixels of a 15x15 patch        
        transfer_region_c = 1:9;
    end
    rl=h_lr-patchsize_lr+1;
    cl=1;
    rh = (rl-1+rpixelshift)*scalingfactor+1;
    rh1 = rh+3*scalingfactor-1;
    ch = (cl-1)*scalingfactor+1;
    ch1 = ch+3*scalingfactor-1;
    usedhrpatch = hrpatch(:,:,rl,cl);
    img_texture(rh:rh1,ch:ch1) = usedhrpatch(transfer_region_r,transfer_region_c);
    
    %right-bottom corner
    if scalingfactor == 4
        transfer_region_r = 9:20;     %This is a region of the right-bottom 12x12 pixels of a 20x20 patch
        transfer_region_c = 9:20;
    elseif scalingfactor == 3
        transfer_region_r = 7:15;     %This is a region of the left-bottom 9x9 pixels of a 15x15 patch        
        transfer_region_c = 7:15;
    end
    rl=h_lr-patchsize_lr+1;
    cl=w_lr-patchsize_lr+1;
    rh = (rl-1+rpixelshift)*scalingfactor+1;
    rh1 = rh+3*scalingfactor-1;
    ch = (cl-1+cpixelshift)*scalingfactor+1;
    ch1 = ch+3*scalingfactor-1;
    usedhrpatch = hrpatch(:,:,rl,cl);
    img_texture(rh:rh1,ch:ch1) = usedhrpatch(transfer_region_r,transfer_region_c);
end
