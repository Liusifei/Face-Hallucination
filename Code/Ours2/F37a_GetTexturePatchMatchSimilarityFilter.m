%Chih-Yuan Yang
%10/05/12
%Use patchmatch to retrieve a texture background
function [gradients_texture img_texture img_texture_backprojection] = F37a_GetTexturePatchMatchSimilarityFilter(img_y, ...
    hrexampleimages, lrexampleimages)

    %parameter
    numberofHcandidate = 10;
    
    %start
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
    patchsize_lr = 5;
    nn_iters = 5;
    %A =F38_ExtractFeatureFromAnImage(img_y);
    A = repmat(img_y,[1 1 3]);
    testnumber = exampleimagenumber;
    xyandl2norm = zeros(h_lr,w_lr,3,testnumber,'int32');
    disp('patchmatching');
    parfor i=1:testnumber;
        %run patchmatch
        B = repmat(lrexampleimages(:,:,i),[1 1 3]);
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
                    
    hrpatch = IF1_ExtractAllHrPatches(img_y, patchsize_lr,zooming, hrpatchextractdata,hrexampleimages,lrexampleimages);

    mostsimilarinputpatchrecord = IF2_SearchForSelfSimilarPatchesL2Norm(img_y,patchsize_lr);
    
    hrpatch_filtered = IF3_SimilarityFilter(hrpatch,hrpatchsimilarity,mostsimilarinputpatchrecord);
    
    img_texture = IF4_BuildHRimagefromHRPatches(hrpatch_filtered,zooming);
    iternum = 1000;
    Tolf = 0.0001;
    breport = false;
    disp('backprojection for img_texture');
    img_texture_backprojection = F11d_BackProjection_GaussianKernel(img_y, img_texture, Gau_sigma, iternum,breport,Tolf);
    
    %extract the graident
    gradients_texture = F14_Img2Grad(img_texture_backprojection);
end
function scanresult = IF2_SearchForSelfSimilarPatchesL2Norm(img_y,patchsize_lr)
    %out:
    %scanresult: 3 x numberofFcandidate x (h_lr-patchsize+1) x (w_lr-patchsize+1)
    patcharea = patchsize_lr^2;
    [lh lw] = size(img_y);
    %Find self similar patches
    numberofFcandidate = 10;
    scanresult = zeros(3,numberofFcandidate,lh-patchsize_lr+1,lw-patchsize_lr+1);       %scan results: r,c, similarity
    totalpatchnumber = (lh-patchsize_lr+1)*(lw-patchsize_lr+1);
    featurematrix = zeros(patcharea,totalpatchnumber);
    rec = zeros(2,totalpatchnumber);
    idx = 0;
    for rl=1:lh-patchsize_lr+1
        rl1 = rl+patchsize_lr-1;
        for cl=1:lw-patchsize_lr+1
            cl1 = cl+patchsize_lr-1;
            idx = idx + 1;
            rec(:,idx) = [rl;cl];
            featurematrix(:,idx) = reshape(img_y(rl:rl1,cl:cl1),patcharea,1);
        end
    end
    
    %search
    idx = 0;
    for rl=1:lh-patchsize_lr+1
        for cl=1:lw-patchsize_lr+1
            idx = idx + 1;
            fprintf('idx %d totalpatchnumber %d\n',idx,totalpatchnumber);
            queryfeature = featurematrix(:,idx);
            diff = featurematrix - repmat(queryfeature,1,totalpatchnumber);
            sqr = sum(diff.^2);
            [ssqr ix] = sort(sqr);
            saveidx = 0;
            for j=1:numberofFcandidate+1            %add one to prevent find itself
                indexinsort = ix(j);
                sr = rec(1,indexinsort);
                sc = rec(2,indexinsort);
                %explanation: it is possible that there are 11 lr patches with the same appearance
                %and the input one is sorted at item indexed more than 11 so that sr and cl are insufficient
                %to prevenet the problem
                if sr ~= rl || sc ~= cl
                    saveidx = saveidx + 1;
                    if saveidx <= numberofFcandidate
                        l2norm = sqrt(ssqr(j));
                        similarity = exp(-l2norm/25);
                        scanresult(1:3,saveidx,rl,cl) = [sr;sc;similarity];
                    end
                end
            end
        end
    end
end
function hrpatch_filtered = IF3_SimilarityFilter(hrpatch,hrpatchsimilarity,mostsimilarinputpatches)
    %totalpatchnumber
    %hrpatch: patchsize_hr x patchsize_hr x (h_lr-patchsize_lr+1) x (w_lr-patchsize_lr+1) x numberofHcandidate
    %hrpatchsimilarity: (h_lr-patchsize_lr+1) x (w_lr-patchsize_lr+1) x numberofHcandidate
    %mostsimilarinputpatches: 3 x numberofFcandidate x (h_lr-patchsize_lr+1) x (w_lr-patchsize_lr+1)
    %out
    %hrpatch_filtered: patchsize_hr x patchsize_hr x (h_lr-patchsize_lr+1) x (w_lr-patchsize_lr+1)
    zooming = 4;
    patchsize_hr = size(hrpatch,1);
    patchsize_lr = patchsize_hr /zooming;
    h_lr = size(hrpatch,3) + patchsize_lr -1;
    w_lr = size(hrpatch,4) + patchsize_lr -1;
    numberofHcandidate = size(hrpatch,5);
    numberofFcandidate = size(mostsimilarinputpatches,2);
    
    %allocate for out
    hrpatch_filtered = zeros(patchsize_hr,patchsize_hr,h_lr-patchsize_lr+1,w_lr-patchsize_lr+1);
    
    for rl= 1:h_lr-patchsize_lr+1
        fprintf('rl:%d total:%d\n',rl,h_lr-patchsize_lr+1);
        for cl = 1:w_lr-patchsize_lr+1
            %load candidates
            H = zeros(patchsize_hr,patchsize_hr,numberofHcandidate);
            similarityHtolrpatch = zeros(numberofHcandidate,1);
            for j=1:numberofHcandidate
                H(:,:,j) = hrpatch(:,:,rl,cl,j);     %H
                similarityHtolrpatch(j) = hrpatchsimilarity(rl,cl,j);
            end
            
            %self similar patch instance number
            similarityFtolrpatch = reshape( mostsimilarinputpatches(3,:,rl,cl) , [numberofFcandidate , 1]);
            
            %load all of the two step patches
            R = zeros(patchsize_hr,patchsize_hr,numberofFcandidate,numberofHcandidate);
            RSimbasedonF = zeros(numberofFcandidate,numberofHcandidate);
            for i=1:numberofFcandidate
                sr = mostsimilarinputpatches(1,i,rl,cl);
                sc = mostsimilarinputpatches(2,i,rl,cl);
                %hr candidate number
                for j=1:numberofHcandidate
                    R(:,:,i,j) = hrpatch(:,:,sr,sc,j);
                    RSimbasedonF(i,j) = hrpatchsimilarity(sr,sc,j);
                end
            end
                
            %here is a question, how to define the similarity between H and R?
            %L2norm?
            hscore = zeros(numberofHcandidate,1);
            for i=1:numberofHcandidate
                theH = H(:,:,i);
                for j=1:numberofFcandidate
                    for k=1:numberofHcandidate
                        theR = R(:,:,j,k);
                        similarityRbasedonF = RSimbasedonF(j,k);
                        %similarity between H and R
                        diff = theH - theR;
                        L2N = norm(diff(:));
                        similarityRtoH = exp(- L2N/25);        %the 25 is a parameter, need to be tuned totalpatchnumber the future
                        hscore(i) = hscore(i) + similarityHtolrpatch(i) * similarityRbasedonF * similarityRtoH * similarityFtolrpatch(j);
                    end
                end
            end
            [~, idx] = max(hscore);
            hrpatch_filtered(:,:,rl,cl) = hrpatch(:,:,rl,cl,idx(1));
        end
    end
end
function hrpatch = IF1_ExtractAllHrPatches(img_y, patchsize_lr,zooming,hrpatchextractdata,allHRexampleimages,allLRexampleimages)
    %question: if the hrpatch does not need compensate, the input paramters img_y and allLRexampleimages can be ignore
    %in:
    %hrpatchextractdata: (h_lr-patchsize_lr+1) x (w_lr-patchsize_lr+1) x numberofHcandidate * 3
    %the last 3 dim: ii, r_lr_src, c_lr_src
    disp('extracting HR patches');
    patchsize_hr = patchsize_lr * zooming;
    [h_lr_active, w_lr_active, numberofHcandidate, ~] = size(hrpatchextractdata);
    hrpatch = zeros(patchsize_hr,patchsize_hr,h_lr_active,w_lr_active,numberofHcandidate);
    
    %analyize which images need to be loaded
    alliiset = hrpatchextractdata(:,:,:,1);
    alliiset_uni = unique(alliiset(:));

    for i = 1:length(alliiset_uni)
        ii = alliiset_uni(i);
        fprintf('extracting image %d\n',ii);
        exampleimage_hr = im2double(allHRexampleimages(:,:,ii));
        exampleimage_lr = allLRexampleimages(:,:,ii);
        match_4D = alliiset == ii;
        match_3D = reshape(match_4D,h_lr_active,w_lr_active,numberofHcandidate);        %remove the last dimension
        [rlset clandkset] = find(match_3D);
        setsize = length(rlset);
        for j = 1:setsize
            rl = rlset(j);
            clandklinearindex = clandkset(j);
            %the relationship clandklindearidx = x_lr_active * (k-1) + cl
            k = floor( (clandklinearindex-1)/w_lr_active) +1;        %the relationship: possum = (pos3-1) * d2 + pos2,   pos2 totalpatchnumber (1,d2)
            cl = clandklinearindex - (k-1)*w_lr_active;

            sr = hrpatchextractdata(rl,cl,k,2);
            sc = hrpatchextractdata(rl,cl,k,3);
            
            srh = (sr-1)*zooming+1;
            srh1 = srh + patchsize_hr -1;
            sch = (sc-1)*zooming+1;
            sch1 = sch + patchsize_hr-1;

            %compensate the HR patch to match the LR query patch
            hrp = exampleimage_hr(srh:srh1,sch:sch1);           %HR patch 
            %lrq = img_y(rl:rl+patchsize_lr-1,cl:cl+patchsize_lr-1);     %LR query patch
            %lrr = exampleimage_lr(sr:sr+patchsize_lr-1,sc:sc+patchsize_lr-1);       %LR retrieved patch
            %the imresize make the process very slow
            %chrp = hrp + imresize(lrq - lrr,zooming,'bilinear');     %compensate HR patch
            %hrpatch(:,:,rl,cl,k) = chrp;
            hrpatch(:,:,rl,cl,k) = hrp;
            
            if 0
            bVisuallyCheck = false;
            if bVisuallyCheck
                if ~exist('hfig','var')
                    hfig = figure;
                else
                    figure(hfig);
                end
                subplot(1,4,1);
                imshow(hrp/255);
                title('hrp');
                subplot(1,4,2);
                imshow(lrr/255);
                title('lrr');
                subplot(1,4,3);
                imshow(lrq/255);
                title('lrq');
                subplot(1,4,4);
                imshow(chrp/255);
                title('chrp');
                keyboard
            end
            end
        end        
    end
end
function img_texture = IF4_BuildHRimagefromHRPatches(hrpatch,zooming)
    %reconstruct the high-resolution image
    patchsize_hr = size(hrpatch,1);
    patchsize_lr = patchsize_hr/zooming;
    h_lr = size(hrpatch,3) + patchsize_lr - 1;
    w_lr = size(hrpatch,4) + patchsize_lr - 1;
    h_expected = h_lr * zooming;
    w_expected = w_lr * zooming;
    img_texture = zeros(h_expected,w_expected);
    %most cases
    rpixelshift = 2;        %this should be modified according to patchsize_lr
    cpixelshift = 2;
    for rl = 2:h_lr - patchsize_lr
        rh = (rl-1+rpixelshift)*zooming+1;
        rh1 = rh+zooming-1;
        for cl = 2:w_lr - patchsize_lr
            ch = (cl-1+cpixelshift)*zooming+1;
            ch1 = ch+zooming-1;
            usedhrpatch = hrpatch(:,:,rl,cl);
            img_texture(rh:rh1,ch:ch1) = usedhrpatch(9:12,9:12);
        end
    end
    
    %left
    cl = 1;
    ch = 1;
    ch1 = ch+3*zooming-1;
    for rl=2:h_lr-patchsize_lr
        rh = (rl-1+rpixelshift)*zooming+1;
        rh1 = rh+zooming-1;
        usedhrpatch = hrpatch(:,:,rl,cl);
        chsource = 1;
        ch1source = chsource+3*zooming-1;
        rhsource = 9;
        rh1source = rhsource+zooming-1;
        img_texture(rh:rh1,ch:ch1) = usedhrpatch(rhsource:rh1source,chsource:ch1source);
    end
    
    %right
    cl = w_lr - patchsize_lr+1;
    ch = w_expected - 3*zooming+1;
    ch1 = w_expected;
    for rl=2:h_lr-patchsize_lr
        rh = (rl-1+rpixelshift)*zooming+1;
        rh1 = rh+zooming-1;
        usedhrpatch = hrpatch(:,:,rl,cl);
        chsource = 9;
        ch1source = chsource+3*zooming-1;
        rhsource = 9;
        rh1source = rhsource+zooming-1;
        img_texture(rh:rh1,ch:ch1) = usedhrpatch(rhsource:rh1source,chsource:ch1source);
    end
    
    %top
    rl = 1;
    rh = 1;
    rh1 = rh+3*zooming-1;
    for cl=2:w_lr-patchsize_lr
        ch = (cl-1+cpixelshift)*zooming+1;
        ch1 = ch+zooming-1;
        usedhrpatch = hrpatch(:,:,rl,cl);
        chsource = 9;
        ch1source = chsource+zooming-1;
        rhsource = 1;
        rh1source = rhsource+3*zooming-1;
        img_texture(rh:rh1,ch:ch1) = usedhrpatch(rhsource:rh1source,chsource:ch1source);
    end
    
    %bottom
    rl = h_lr-patchsize_lr+1;
    rh = h_expected - 3*zooming+1;
    rh1 = h_expected;
    for cl=2:w_lr-patchsize_lr
        ch = (cl-1+cpixelshift)*zooming+1;
        ch1 = ch+zooming-1;
        usedhrpatch = hrpatch(:,:,rl,cl);
        chsource = 9;
        ch1source = chsource+zooming-1;
        rhsource = 9;
        rh1source = rhsource+3*zooming-1;
        img_texture(rh:rh1,ch:ch1) = usedhrpatch(rhsource:rh1source,chsource:ch1source);
    end
    
    %left-top corner
    rl=1;
    cl=1;
    rh = 1;
    rh1 = rh+3*zooming-1;
    ch = 1;
    ch1 = ch+3*zooming-1;
    usedhrpatch = hrpatch(:,:,rl,cl);
    chsource = 1;
    ch1source = chsource+3*zooming-1;
    rhsource = 1;
    rh1source = rhsource+3*zooming-1;
    img_texture(rh:rh1,ch:ch1) = usedhrpatch(rhsource:rh1source,chsource:ch1source);
    
    %right-top corner
    rl=1;
    cl=w_lr-patchsize_lr+1;
    rh = (rl-1)*zooming+1;
    rh1 = rh+3*zooming-1;
    ch = (cl-1+cpixelshift)*zooming+1;
    ch1 = ch+3*zooming-1;
    usedhrpatch = hrpatch(:,:,rl,cl);
    chsource = 9;
    ch1source = chsource+3*zooming-1;
    rhsource = 1;
    rh1source = rhsource+3*zooming-1;
    img_texture(rh:rh1,ch:ch1) = usedhrpatch(rhsource:rh1source,chsource:ch1source);
    
    %left-bottom corner
    rl=h_lr-patchsize_lr+1;
    cl=1;
    rh = (rl-1+rpixelshift)*zooming+1;
    rh1 = rh+3*zooming-1;
    ch = (cl-1)*zooming+1;
    ch1 = ch+3*zooming-1;
    usedhrpatch = hrpatch(:,:,rl,cl);
    chsource = 1;
    ch1source = chsource+3*zooming-1;
    rhsource = 9;
    rh1source = rhsource+3*zooming-1;
    img_texture(rh:rh1,ch:ch1) = usedhrpatch(rhsource:rh1source,chsource:ch1source);
    
    %left-bottom corner
    rl=h_lr-patchsize_lr+1;
    cl=w_lr-patchsize_lr+1;
    rh = (rl-1+rpixelshift)*zooming+1;
    rh1 = rh+3*zooming-1;
    ch = (cl-1+cpixelshift)*zooming+1;
    ch1 = ch+3*zooming-1;
    usedhrpatch = hrpatch(:,:,rl,cl);
    chsource = 9;
    ch1source = chsource+3*zooming-1;
    rhsource = 9;
    rh1source = rhsource+3*zooming-1;
    img_texture(rh:rh1,ch:ch1) = usedhrpatch(rhsource:rh1source,chsource:ch1source);
end
