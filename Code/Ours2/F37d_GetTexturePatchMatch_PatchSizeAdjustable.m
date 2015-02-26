%Chih-Yuan Yang
%10/05/12
%Use patchmatch to retrieve a texture background
function [gradients_texture, img_texture, img_texture_backprojection] = ...
    F37d_GetTexturePatchMatch_PatchSizeAdjustable(img_y, ...
    hrexampleimages, lrexampleimages, patchsize)
    [h_lr, w_lr, exampleimagenumber] = size(lrexampleimages);
    [h_hr, w_hr, ~] = size(hrexampleimages);
    zooming = h_hr/h_lr;
    if zooming == 4
        Gau_sigma = 1.6;
    elseif zooming == 3
        Gau_sigma = 1.2;
    end
    
    cores = 2;    % Use more cores for more speed

    if cores==1
      algo = 'cpu';
    else
      algo = 'cputiled';
    end
    nn_iters = 5;
    %A =F38_ExtractFeatureFromAnImage(img_y);
    A = repmat(img_y,[1 1 3]);
    testnumber = exampleimagenumber;
    xyandl2norm = zeros(h_lr,w_lr,3,testnumber,'int32');
    disp('patchmatching');
    parfor i=1:testnumber;
        %run patchmatch
        %fprintf('Patch match running image %d\n',i);
        %B = F38_ExtractFeatureFromAnImage( lrexampleimages(:,:,i));
        B = repmat(lrexampleimages(:,:,i),[1 1 3]);
        xyandl2norm(:,:,:,i) = nnmex(A, B, algo, patchsize, nn_iters, [], [], [], [], cores);       %the return in int32
    end
    l2norm = xyandl2norm(:,:,3,:);
    [~, ix] = sort(l2norm,4);
    
    %reconstruct the high-resolution image
    h_expected = h_lr * zooming;
    w_expected = w_lr * zooming;
    img_texture = zeros(h_expected,w_expected,'uint8');
    %most cases
    rpixelshift = 2;
    cpixelshift = 2;
    for rl = 2:h_lr - patchsize
        rh = (rl-1+rpixelshift)*zooming+1;
        rh1 = rh+zooming-1;
        for cl = 2:w_lr - patchsize
            ch = (cl-1+cpixelshift)*zooming+1;
            ch1 = ch+zooming-1;
            onennidx = ix(rl,cl,1,1);
            x = xyandl2norm(rl,cl,1,onennidx);      %start from 0
            y = xyandl2norm(rl,cl,2,onennidx);
            clsource = x+1;
            rlsource = y+1;
            chsource = (clsource-1+cpixelshift)*zooming+1;
            ch1source = chsource+zooming-1;
            rhsource = (rlsource-1+rpixelshift)*zooming+1;
            rh1source = rhsource+zooming-1;
            img_texture(rh:rh1,ch:ch1) = hrexampleimages(rhsource:rh1source,chsource:ch1source,onennidx);
        end
    end
    
    %left
    cl = 1;
    ch = 1;
    ch1 = ch+3*zooming-1;
    for rl=2:h_lr-patchsize
        rh = (rl-1+rpixelshift)*zooming+1;
        rh1 = rh+zooming-1;
        onennidx = ix(rl,cl,1,1);
        x = xyandl2norm(rl,cl,1,onennidx);      %start from 0
        y = xyandl2norm(rl,cl,2,onennidx);
        clsource = x+1;
        rlsource = y+1;
        chsource = (clsource-1)*zooming+1;
        ch1source = chsource+3*zooming-1;
        rhsource = (rlsource-1+rpixelshift)*zooming+1;
        rh1source = rhsource+zooming-1;
        img_texture(rh:rh1,ch:ch1) = hrexampleimages(rhsource:rh1source,chsource:ch1source,onennidx);
    end
    
    %right
    cl = w_lr - patchsize+1;
    ch = w_expected - 3*zooming+1;
    ch1 = w_expected;
    for rl=2:h_lr-patchsize
        rh = (rl-1+rpixelshift)*zooming+1;
        rh1 = rh+zooming-1;
        onennidx = ix(rl,cl,1,1);
        x = xyandl2norm(rl,cl,1,onennidx);      %start from 0
        y = xyandl2norm(rl,cl,2,onennidx);
        clsource = x+1;
        rlsource = y+1;
        chsource = (clsource-1+cpixelshift)*zooming+1;
        ch1source = chsource+3*zooming-1;
        rhsource = (rlsource-1+rpixelshift)*zooming+1;
        rh1source = rhsource+zooming-1;
        img_texture(rh:rh1,ch:ch1) = hrexampleimages(rhsource:rh1source,chsource:ch1source,onennidx);
    end
    
    %top
    rl = 1;
    rh = 1;
    rh1 = rh+3*zooming-1;
    for cl=2:w_lr-patchsize
        ch = (cl-1+cpixelshift)*zooming+1;
        ch1 = ch+zooming-1;
        onennidx = ix(rl,cl,1,1);
        x = xyandl2norm(rl,cl,1,onennidx);      %start from 0
        y = xyandl2norm(rl,cl,2,onennidx);
        clsource = x+1;
        rlsource = y+1;
        chsource = (clsource-1+cpixelshift)*zooming+1;
        ch1source = chsource+zooming-1;
        rhsource = (rlsource-1)*zooming+1;
        rh1source = rhsource+3*zooming-1;
        img_texture(rh:rh1,ch:ch1) = hrexampleimages(rhsource:rh1source,chsource:ch1source,onennidx);
    end
    
    %bottom
    rl = h_lr-patchsize+1;
    rh = h_expected - 3*zooming+1;
    rh1 = h_expected;
    for cl=2:w_lr-patchsize
        ch = (cl-1+cpixelshift)*zooming+1;
        ch1 = ch+zooming-1;
        onennidx = ix(rl,cl,1,1);
        x = xyandl2norm(rl,cl,1,onennidx);      %start from 0
        y = xyandl2norm(rl,cl,2,onennidx);
        clsource = x+1;
        rlsource = y+1;
        chsource = (clsource-1+cpixelshift)*zooming+1;
        ch1source = chsource+zooming-1;
        rhsource = (rlsource-1+rpixelshift)*zooming+1;
        rh1source = rhsource+3*zooming-1;
        img_texture(rh:rh1,ch:ch1) = hrexampleimages(rhsource:rh1source,chsource:ch1source,onennidx);
    end
    
    %left-top corner
    rl=1;
    cl=1;
    rh = 1;
    rh1 = rh+3*zooming-1;
    ch = 1;
    ch1 = ch+3*zooming-1;
    onennidx = ix(rl,cl,1,1);
    x = xyandl2norm(rl,cl,1,onennidx);      %start from 0
    y = xyandl2norm(rl,cl,2,onennidx);
    clsource = x+1;
    rlsource = y+1;
    chsource = (clsource-1)*zooming+1;
    ch1source = chsource+3*zooming-1;
    rhsource = (rlsource-1)*zooming+1;
    rh1source = rhsource+3*zooming-1;
    img_texture(rh:rh1,ch:ch1) = hrexampleimages(rhsource:rh1source,chsource:ch1source,onennidx);
    
    %right-top corner
    rl=1;
    cl=w_lr-patchsize+1;
    rh = (rl-1)*zooming+1;
    rh1 = rh+3*zooming-1;
    ch = (cl-1+cpixelshift)*zooming+1;
    ch1 = ch+3*zooming-1;
    onennidx = ix(rl,cl,1,1);
    x = xyandl2norm(rl,cl,1,onennidx);      %start from 0
    y = xyandl2norm(rl,cl,2,onennidx);
    clsource = x+1;
    rlsource = y+1;
    chsource = (clsource-1+cpixelshift)*zooming+1;
    ch1source = chsource+3*zooming-1;
    rhsource = (rlsource-1)*zooming+1;
    rh1source = rhsource+3*zooming-1;
    img_texture(rh:rh1,ch:ch1) = hrexampleimages(rhsource:rh1source,chsource:ch1source,onennidx);

    %left-bottom corner
    rl=h_lr-patchsize+1;
    cl=1;
    rh = (rl-1+rpixelshift)*zooming+1;
    rh1 = rh+3*zooming-1;
    ch = (cl-1)*zooming+1;
    ch1 = ch+3*zooming-1;
    onennidx = ix(rl,cl,1,1);
    x = xyandl2norm(rl,cl,1,onennidx);      %start from 0
    y = xyandl2norm(rl,cl,2,onennidx);
    clsource = x+1;
    rlsource = y+1;
    chsource = (clsource-1)*zooming+1;
    ch1source = chsource+3*zooming-1;
    rhsource = (rlsource-1+rpixelshift)*zooming+1;
    rh1source = rhsource+3*zooming-1;
    img_texture(rh:rh1,ch:ch1) = hrexampleimages(rhsource:rh1source,chsource:ch1source,onennidx);
    
    %left-bottom corner
    rl=h_lr-patchsize+1;
    cl=w_lr-patchsize+1;
    rh = (rl-1+rpixelshift)*zooming+1;
    rh1 = rh+3*zooming-1;
    ch = (cl-1+cpixelshift)*zooming+1;
    ch1 = ch+3*zooming-1;
    onennidx = ix(rl,cl,1,1);
    x = xyandl2norm(rl,cl,1,onennidx);      %start from 0
    y = xyandl2norm(rl,cl,2,onennidx);
    clsource = x+1;
    rlsource = y+1;
    chsource = (clsource-1+cpixelshift)*zooming+1;
    ch1source = chsource+3*zooming-1;
    rhsource = (rlsource-1+rpixelshift)*zooming+1;
    rh1source = rhsource+3*zooming-1;
    img_texture(rh:rh1,ch:ch1) = hrexampleimages(rhsource:rh1source,chsource:ch1source,onennidx);
    
    img_texture = im2double(img_texture);
    iternum = 1000;
    Tolf = 0.0001;
    breport = false;
    disp('backprojection for img_texture');
    img_texture_backprojection = F11d_BackProjection_GaussianKernel(img_y, img_texture, Gau_sigma, iternum,breport,Tolf);
    
    %extract the graident
    gradients_texture = F14_Img2Grad(img_texture_backprojection);
end