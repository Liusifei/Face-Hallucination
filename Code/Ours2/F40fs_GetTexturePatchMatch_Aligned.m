%Chih-Yuan Yang
%01/26/15
%Replace F19a by F19c on line 53.
%
%I want to know how Sifei add her code in this file to improve the output images?
%Use patchmatch to retrieve a texture background
% patchmatch for Lab 3 channels
% using stv
function [gradients_texture, img_color] = F40fs_GetTexturePatchMatch_Aligned(img_y, ...
    hrexampleimages, lrexampleimages, landmarks_test, rawexamplelandmarks)

    %parameter
    numberofHcandidate = 10;
    
%     img_y = TV(img_y,0.05, 20);
    
    %start
    [h_lr, w_lr, ~, ~] = size(lrexampleimages);
    [h_hr, w_hr, cn, exampleimagenumber] = size(hrexampleimages);
    zooming = h_hr/h_lr;
    if zooming == 4
        Gau_sigma = 1.6;
    elseif zooming == 3
        Gau_sigma = 1.2;
    end
    alignedexampleimage_hr = zeros(h_hr, w_hr, cn, exampleimagenumber,'uint8');     %set as uint8 to reduce memory demand
    alignedexampleimage_lr = zeros(h_lr, w_lr, cn, exampleimagenumber);
    disp('align images');
    set = 28:48;  %eyes and nose
    basepoints = landmarks_test(set,:);
    inputpoints = rawexamplelandmarks(set,:,:);
    
    parfor k=1:exampleimagenumber
        alignedexampleimage_hr(:,:,:,k) = F18_AlignExampleImageByLandmarkSet(hrexampleimages(:,:,:,k),inputpoints(:,:,k),basepoints);
        %F19 automatically convert uint8 input to double
        %alignedexampleimage_lr(:,:,:,k) = F19a_GenerateLRImage_GaussianKernel(alignedexampleimage_hr(:,:,:,k),zooming,Gau_sigma);
        alignedexampleimage_lr(:,:,:,k) = F19c_GenerateLRImage_GaussianKernel(alignedexampleimage_hr(:,:,:,k),zooming,Gau_sigma);
    end
    
    cores = 2;    % Use more cores for more speed

    if cores==1
      algo = 'cpu';
    else
      algo = 'cputiled';
    end
    patchsize_lr = 5;
    nn_iters = 5;

%     A = repmat(img_y,[1 1 3]);
    testnumber = exampleimagenumber;
    xyandl2norm = zeros(h_lr,w_lr,3,testnumber,'int32');
    disp('patchmatching');
    parfor i=1:testnumber;
        %run patchmatch
        B = reshape(alignedexampleimage_lr(:,:,:,i),[h_lr, w_lr, 3]);
        xyandl2norm(:,:,:,i) = nnmex(img_y, B, algo, patchsize_lr, nn_iters, [], [], [], [], cores);       %the return totalpatchnumber int32
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
                    
    hrpatch = F40_ExtractAllHrPatches(patchsize_lr,zooming, hrpatchextractdata,alignedexampleimage_hr);
    img_texture = IF4s_BuildHRimagefromHRPatches(hrpatch,zooming);
    %extract the graident
    %The T1_ImprovePatchMatch is the code Sifei adds.
    img_texture(:,:,1) = T1_ImprovePatchMatch(img_texture(:,:,1),img_y(:,:,1));
    gradients_texture = F14_Img2Grad(img_texture(:,:,1));
    img_color = img_texture(:,:,2:3);
end

