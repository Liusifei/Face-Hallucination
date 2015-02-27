% Build color image
function img_texture = IF4s_BuildHRimagefromHRPatches(hrpatch,zooming)
    %reconstruct the high-resolution image
    patchsize_hr = size(hrpatch,1);
    patchsize_lr = patchsize_hr/zooming;
    h_lr = size(hrpatch,4) + patchsize_lr - 1;
    w_lr = size(hrpatch,5) + patchsize_lr - 1;
    h_expected = h_lr * zooming;
    w_expected = w_lr * zooming;
    img_texture = zeros(h_expected,w_expected,3);
    %most cases
    rpixelshift = 2;        %this should be modified according to patchsize_lr
    cpixelshift = 2;
    for rl = 2:h_lr - patchsize_lr
        rh = (rl-1+rpixelshift)*zooming+1;
        rh1 = rh+zooming-1;
        for cl = 2:w_lr - patchsize_lr
            ch = (cl-1+cpixelshift)*zooming+1;
            ch1 = ch+zooming-1;
            usedhrpatch = hrpatch(:,:,:,rl,cl);
            img_texture(rh:rh1,ch:ch1,:) = usedhrpatch(9:12,9:12,:);
        end
    end
    
    %left
    cl = 1;
    ch = 1;
    ch1 = ch+3*zooming-1;
    for rl=2:h_lr-patchsize_lr
        rh = (rl-1+rpixelshift)*zooming+1;
        rh1 = rh+zooming-1;
        usedhrpatch = hrpatch(:,:,:,rl,cl);
        chsource = 1;
        ch1source = chsource+3*zooming-1;
        rhsource = 9;
        rh1source = rhsource+zooming-1;
        img_texture(rh:rh1,ch:ch1,:) = usedhrpatch(rhsource:rh1source,chsource:ch1source,:);
    end
    
    %right
    cl = w_lr - patchsize_lr+1;
    ch = w_expected - 3*zooming+1;
    ch1 = w_expected;
    for rl=2:h_lr-patchsize_lr
        rh = (rl-1+rpixelshift)*zooming+1;
        rh1 = rh+zooming-1;
        usedhrpatch = hrpatch(:,:,:,rl,cl);
        chsource = 9;
        ch1source = chsource+3*zooming-1;
        rhsource = 9;
        rh1source = rhsource+zooming-1;
        img_texture(rh:rh1,ch:ch1,:) = usedhrpatch(rhsource:rh1source,chsource:ch1source,:);
    end
    
    %top
    rl = 1;
    rh = 1;
    rh1 = rh+3*zooming-1;
    for cl=2:w_lr-patchsize_lr
        ch = (cl-1+cpixelshift)*zooming+1;
        ch1 = ch+zooming-1;
        usedhrpatch = hrpatch(:,:,:,rl,cl);
        chsource = 9;
        ch1source = chsource+zooming-1;
        rhsource = 1;
        rh1source = rhsource+3*zooming-1;
        img_texture(rh:rh1,ch:ch1,:) = usedhrpatch(rhsource:rh1source,chsource:ch1source,:);
    end
    
    %bottom
    rl = h_lr-patchsize_lr+1;
    rh = h_expected - 3*zooming+1;
    rh1 = h_expected;
    for cl=2:w_lr-patchsize_lr
        ch = (cl-1+cpixelshift)*zooming+1;
        ch1 = ch+zooming-1;
        usedhrpatch = hrpatch(:,:,:,rl,cl);
        chsource = 9;
        ch1source = chsource+zooming-1;
        rhsource = 9;
        rh1source = rhsource+3*zooming-1;
        img_texture(rh:rh1,ch:ch1,:) = usedhrpatch(rhsource:rh1source,chsource:ch1source,:);
    end
    
    %left-top corner
    rl=1;
    cl=1;
    rh = 1;
    rh1 = rh+3*zooming-1;
    ch = 1;
    ch1 = ch+3*zooming-1;
    usedhrpatch = hrpatch(:,:,:,rl,cl);
    chsource = 1;
    ch1source = chsource+3*zooming-1;
    rhsource = 1;
    rh1source = rhsource+3*zooming-1;
    img_texture(rh:rh1,ch:ch1,:) = usedhrpatch(rhsource:rh1source,chsource:ch1source,:);
    
    %right-top corner
    rl=1;
    cl=w_lr-patchsize_lr+1;
    rh = (rl-1)*zooming+1;
    rh1 = rh+3*zooming-1;
    ch = (cl-1+cpixelshift)*zooming+1;
    ch1 = ch+3*zooming-1;
    usedhrpatch = hrpatch(:,:,:,rl,cl);
    chsource = 9;
    ch1source = chsource+3*zooming-1;
    rhsource = 1;
    rh1source = rhsource+3*zooming-1;
    img_texture(rh:rh1,ch:ch1,:) = usedhrpatch(rhsource:rh1source,chsource:ch1source,:);
    
    %left-bottom corner
    rl=h_lr-patchsize_lr+1;
    cl=1;
    rh = (rl-1+rpixelshift)*zooming+1;
    rh1 = rh+3*zooming-1;
    ch = (cl-1)*zooming+1;
    ch1 = ch+3*zooming-1;
    usedhrpatch = hrpatch(:,:,:,rl,cl);
    chsource = 1;
    ch1source = chsource+3*zooming-1;
    rhsource = 9;
    rh1source = rhsource+3*zooming-1;
    img_texture(rh:rh1,ch:ch1,:) = usedhrpatch(rhsource:rh1source,chsource:ch1source,:);
    
    %left-bottom corner
    rl=h_lr-patchsize_lr+1;
    cl=w_lr-patchsize_lr+1;
    rh = (rl-1+rpixelshift)*zooming+1;
    rh1 = rh+3*zooming-1;
    ch = (cl-1+cpixelshift)*zooming+1;
    ch1 = ch+3*zooming-1;
    usedhrpatch = hrpatch(:,:,:,rl,cl);
    chsource = 9;
    ch1source = chsource+3*zooming-1;
    rhsource = 9;
    rh1source = rhsource+3*zooming-1;
    img_texture(rh:rh1,ch:ch1,:) = usedhrpatch(rhsource:rh1source,chsource:ch1source,:);
end
