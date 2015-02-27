%Chih-Yuan Yang
%10/04/12
%16d: only run patch selection because the edge part has been separated
function [gradients_texture img_texture img_texture_backproject] = F16d_ACCV12TextureGradientNotIntensity(img_y, zooming, Gau_sigma ,sfall,srecall,allHRexampleimages,allLRexampleimages)
    if zooming == 4
        para.Gau_sigma = 1.6;
    elseif zooming == 3
        para.Gau_sigma = 1.2;
    end
    
    [h_lr w_lr] = size(img_y);
    para.lh = h_lr;
    para.lw = w_lr;
    para.NumberOfHCandidate = 10;
    para.SimilarityFunctionSettingNumber = 1;
    %load all data set to save loading time
    [scanr scanra] = SearchExternalPatches(img_y,para,sfall,srecall);
    para.zooming = zooming;
    para.ps = 5;
    para.Gau_sigma = Gau_sigma;
    hrpatch = F8_ExtractAllHrPatches(img_y, para, scanr,allHRexampleimages,allLRexampleimages);
    [scanr_self scanra_self] = F22_SearchForSelfSimilarPatchesL2Norm(img_y,para);
    para.ehrfKernelWidth = 1.0;
    para.bEnablemhrf = true;
    [img_texture weightmap_texture] = F11_FilterOutImproperHrPatches(img_y,hrpatch,para,scanr_self,scanra_self,scanr,scanra);
    %apply backprojection on img_texture only
    iternum = 100;
    breport = true;
    disp('backprojection for img_texture in ACCV12');
    img_texture_backproject = F11c_BackProjection_GaussianKernel(img_y, img_texture, Gau_sigma, iternum,breport);
    
    %extract the graident
    gradients_texture = Img2Grad(img_texture_backproject);
    
end
function [scanr scanra] = SearchExternalPatches(img_y,para,sfall,srecall)
    %how to search parallelly to speed up?
    ps = 5;         %patch size
    [lh lw] = size(img_y);
    hrpatchnumber = 10;
    %featurefolder = para.featurefolder;
    sh = GetShGeneral(ps);
    scanr = zeros(6,hrpatchnumber,lh-ps+1,lw-ps+1);       %scan results, mm, quan, ii, sr, sc, similairty
    smallvalue = -1;
    scanr(6,:,:,:) = smallvalue;
    scanra = zeros(lh-ps+1,lw-ps+1);       %scan results active
    %scanrsimmax = smallvalue * ones(lh-ps+1,lw-ps+1);               %del this line?
    quanarray = [1 2 4 8 16 32];
    B = [256 128 64 32 16 8];
    imlyi = im2uint8(img_y);
    for qidx=1:6
        quan = quanarray(qidx);
        b = B(qidx);
        
        cur_initial = floor(size(sfall{1},2)/2);     %accelerate the loop by using an initial position
        for rl=1:lh-ps+1
            fprintf('look for lut rl:%d quan:%d\n',rl,quan);
            for cl = 1:lw-ps+1
                patch = imlyi(rl:rl+ps-1,cl:cl+ps-1);
                fq = patch(sh);
                if qidx == 1
                    fquan = fq;
                else
                    fquan = fq - mod(fq,quan) + quan/2;
                end

                [iila mma] = LookForLookUpTable9_External(fquan,sfall{qidx},cur_initial,para);      %index in lookuptable
                in = length(iila);      %always return 20 instance
                for i=1:in
                    ii = srecall{qidx}(1,iila(i));           
                    sr = srecall{qidx}(2,iila(i));
                    sc = srecall{qidx}(3,iila(i));
                    %check whether the patch is in the scanr already
                    bSamePatch = false;
                    for j=1:scanra(rl,cl)
                        if ii == scanr(3,j,rl,cl) && sr == scanr(4,j,rl,cl) && sc == scanr(5,j,rl,cl)
                            bSamePatch = true;
                            break
                        end
                    end

                    if bSamePatch == false
                        similarity = bmm2similarity(b,mma(i),para.SimilarityFunctionSettingNumber);
                        if scanra(rl,cl) < hrpatchnumber
                            ix = scanra(rl,cl) + 1;
                            %to do: update scanr by similarity
                            %need to double it, otherwise, the int6 will kill similarity
                            scanr(:,ix,rl,cl) = cat(1,mma(i),quan,double(ii),double(sr),double(sc),similarity);
                            scanra(rl,cl) = ix;
                        else
                            [minval ix] = min(scanr(6,:,rl,cl));
                            if scanr(6,ix,rl,cl) < similarity
                                %update
                                scanr(:,ix,rl,cl) = cat(1,mma(i),quan,double(ii),double(sr),double(sc),similarity);                                
                            end
                        end
                    end
                end
            end
        end
    end
end
function [iila mma] = LookForLookUpTable9_External(fq,lut,cur_initial,para)
    hrpatchnumber = para.NumberOfHCandidate;   %default 10
    fl = length(fq);        %feature length
    head = 1;
    tail = size(lut,2);
    lutsize = size(lut,2);
    if exist('cur_initial','var')
        if cur_initial > lutsize
            cur = lutsize;
        else
            cur = cur_initial;
        end
    else
        cur = round(lutsize/2);
    end
    cur_rec1 = cur;
    %initial comparison
    fqsmaller = -1;
    fqlarger = 1;
    fqsame = 0;
    cr = 0;         %compare results
    mm = 0;
    mmiil = 0;
    %search for the largest mm
    while 1
        for c=1:fl
            if fq(c) < lut(c,cur)
                cr = fqsmaller;
                break
            elseif fq(c) > lut(c,cur)
                cr = fqlarger;
                 break;      %c moves to next
            else   %equal
                cr = fqsame;
                if mm < c
                    mm = c;
                    mmiil = cur;
                end 
            end
        end
        
        if cr == fqsmaller
            next = floor((cur + head)/2);
            tail = cur;             %adjust the range of head and tail
        elseif cr == fqlarger;
            next = ceil((cur + tail)/2);       %the round function has to be floor, because fq is larger than cur
                                                %otherwise the fully 255 patches will never match
            head = cur;             %adjust the range of head and tail
        end
        
        if mm == 25     %it happens, the initial one match the fq, therefore, there is no next defined.
            break
        end
        if cur == next  || cur_rec1 == next   %the next might oscilate
            break;
        else
            cur_rec1 = cur;
            cur = next;
        end
        %fprintf('cur %d\n',cur);
    end

    if mm == 0  
        iila = [];
        mma = [];
        return
    end
    %post-process to find the repeated partial vectors
    %search for previous
    idx = 1;
    iila = zeros(hrpatchnumber,1);
    mma = zeros(hrpatchnumber,1);
    iila(idx) = mmiil;
    mma(idx) = mm;
    bprecontinue = true;
    bproccontinue = true;
    
    presh = 0;     %previous shift
    procsh = 0;  %proceeding shift
    while 1
        presh = presh -1;
        iilpre = mmiil + presh;
        if iilpre <1
            bprecontinue = false;
            premm = 0;
        end
        procsh = procsh +1;
        iilproc = mmiil + procsh;
        if iilproc > lutsize
            bproccontinue = false;
            procmm = 0;
        end
        
        if bprecontinue 
            diff = lut(:,iilpre) ~= fq;
            if nnz(diff) == 0
                premm = 25;
            else
                premm = find(diff,1,'first') -1;
            end
        end

        if bproccontinue
            diff = lut(:,iilproc) ~= fq;
            if nnz(diff) == 0
                procmm = 25;
            else
                procmm = find(diff,1,'first') -1;
            end
        end
        
        if premm == 0 && procmm == 0
            break
        end
        if premm > procmm
            %add pre item
            idx = idx + 1;
            iila(idx) = iilpre;
            mma(idx) = premm;
            %pause the proc
            bprecontinue = true;
        elseif premm < procmm
            %add proc item
            idx = idx + 1;
            iila(idx) = iilproc;
            mma(idx) = procmm;
            %pause the pre
            bproccontinue = true;
        else  %premm == procmm
            %add both item
            idx = idx + 1;
            iila(idx) = iilpre;
            mma(idx) = premm;
            
            if idx == hrpatchnumber
                break
            end
            idx = idx + 1;
            iila(idx) = iilproc;
            mma(idx) = procmm;         
            bproccontinue = true;
            bprecontinue = true;
        end
        if idx == hrpatchnumber
            break
        end
    end

    if idx < hrpatchnumber
        iila = iila(1:idx);
        mma = mma(1:idx);
    end
end
function s = bmm2similarity(b,mm,SimilarityFunctionSettingNumber)
    if SimilarityFunctionSettingNumber == 1
        if mm >= 9
            Smm = 0.9 + 0.1*(mm-9)/16;
        else
            Smm = 0.5 * mm/9;
        end

        Sb = 0.5+0.5*(log2(b)-3)/5;
        s = Sb * Smm;
    elseif SimilarityFunctionSettingNumber == 2
        Smm = mm/25;
        Sb = (log2(b)-2)/6;
        s = Sb * Smm;
    end
end
function hrpatch = F8_ExtractAllHrPatches(img_y, para, scanr,allHRexampleimages,allLRexampleimages)
    disp('extracting HR patches');
    %how to search parallelly to speed up?
    psh = para.ps * para.zooming;
    ps = para.ps;
    lh = para.lh;
    lw = para.lw;
    s = para.zooming;
    hrpatchnumber = para.NumberOfHCandidate;
    hrpatch = zeros(psh,psh,lh-ps+1,lw-ps+1,hrpatchnumber);
    allimages = allHRexampleimages;
    
    %analyize which images need to be loaded
    alliiset = scanr(3,:,:,:);
    alliiset_uni = unique(alliiset(:));     %allmost all images are used, from 1 to 1500
    if alliiset_uni(1) ~= 0
        alliiset_uni_pure = alliiset_uni;
    else
        alliiset_uni_pure = alliiset_uni(2:end);
    end

    for i = 1:length(alliiset_uni_pure)
        ii = alliiset_uni_pure(i);
        fprintf('extracting image %d\n',ii);
        exampleimage_hr = im2double(allimages(:,:,ii));
        exampleimage_lr = allLRexampleimages(:,:,ii);
        %exampleimage_lr = U3_GenerateLRImage_BlurSubSample(exampleimage_hr,para.zooming,para.Gau_sigma);
        match_4D = alliiset == ii;
        match_3D = reshape(match_4D,hrpatchnumber,lh-ps+1,lw-ps+1);        %remove the first dimension
        [d1 d2 d3] = size(match_3D);       %second dimention length
        [idxset posset] = find(match_3D);
        setin = length(idxset);
        for j = 1:setin
            idx = idxset(j);
            possum = posset(j);
            pos3 = floor( (possum-1)/d2) +1;        %the relationship: possum = (pos3-1) * d2 + pos2,   pos2 in (1,d2)
            pos2 = possum - (pos3-1)*d2;

            rl = pos2;
            cl = pos3;
            
            sr = scanr(4,idx,rl,cl);
            sc = scanr(5,idx,rl,cl);
            
            srh = (sr-1)*s+1;
            srh1 = srh + psh -1;
            sch = (sc-1)*s+1;
            sch1 = sch + psh-1;

            %to do: compensate the HR patch to match the LR query patch
            hrp = exampleimage_hr(srh:srh1,sch:sch1);           %HR patch 
            lrq = img_y(rl:rl+ps-1,cl:cl+ps-1);     %LR query patch
            lrr = exampleimage_lr(sr:sr+ps-1,sc:sc+ps-1);       %LR retrieved patch
            chrp = hrp + imresize(lrq - lrr,s,'bilinear');     %compensate HR patch
            hrpatch(:,:,rl,cl,idx) = chrp;
            
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
function [img_texture Reliablemap] = F11_FilterOutImproperHrPatches(img_y,hrpatch,para,scanr_self,scanra_self,scanr,scanra)
    %filter out improper hr patches using similarity among lr patches
    %load the self-similar data
    s = para.zooming;
    lh = para.lh;
    lw = para.lw;
    ps = para.ps;
    psh = s * para.ps;
    patcharea = para.ps^2;


    SSnumberUpperbound = 10;
    
    %do I still need these variables?
    cqarray = zeros(32,1)/0;
    for qidx = 1:6
        quan = 2^(qidx-1);
        cqvalue = 0.9^(qidx-1);
        cqarray(quan) = cqvalue;
    end
    
    hh = lh * s;
    hw = lw * s;
    hrres_nomi = zeros(hh,hw);
    hrres_deno = zeros(hh,hw);
    maskmatrix = false(psh,psh,patcharea);
    Reliablemap = zeros(hh,hw);
    
    pshs = psh * psh;    
    for i=1:patcharea
        [sh_notsued masklow maskhigh] = GetShGeneral(ps,i,true,s);  %ps, mm, bhigh, s
        maskmatrix(:,:,i) = maskhigh;
    end
    mhr = zeros(5*s);
    r1 = 2*s+1;
    r2 = 3*s;
    c1 = 2*s+1;
    c2 = 3*s;
    mhr(r1:r2,c1:c2) = 1;      %the central part
    sigma = para.ehrfKernelWidth;
    kernel = F20_Sigma2Kernel(sigma);
    if para.bEnablemhrf
        mhrf = imfilter(mhr,kernel,'replicate');
    else
        mhrf = mhr;
    end

    noHmap = scanra == 0;
    noHmapToFill = noHmap;
    NHOOD = [0 1 0;
             1 1 1;
             0 1 0];
    se = strel('arbitrary',NHOOD);
    noHmapneighbor = and( imdilate(noHmap,se) ,~noHmap);
    %if the noHmapsever is 0, it is fine
    
    imb = imresize(img_y,s);        %use it as the reference if no F is available
    
    rsa = [0 -1 0 1];
    csa = [1 0 -1 0];
    for rl= 1:lh-ps+1   %75
        fprintf('rl:%d total:%d\n',rl,lh-ps+1);
        rh = (rl-1)*s+1;
        rh1 = rh+psh-1;
        for cl = 1:lw-ps+1   %128
            ch = (cl-1)*s+1;
            ch1 = ch+psh-1;
            
            %load candidates
            hin = para.NumberOfHCandidate;
            H = zeros(psh,psh,hin);
            HSim = zeros(hin,1);
            for j=1:hin
                H(:,:,j) = hrpatch(:,:,rl,cl,j);     %H
                HSim(j) = scanr(6,j,rl,cl);
            end
            
            %compute the number of reference patches
            sspin = min(SSnumberUpperbound,scanra_self(rl,cl)); 
            %self similar patch instance number
            F = zeros(ps,ps,sspin);
            FSimPure = zeros(1,sspin);
            rin = 0;
            for i=1:sspin
                sr = scanr_self(3,i,rl,cl);
                sc = scanr_self(4,i,rl,cl);
                %hr candidate number
                rin = rin + para.NumberOfHCandidate;
                F(:,:,i) = img_y(sr:sr+ps-1,sc:sc+ps-1);
                FSimPure(i) = scanr_self(5,i,rl,cl);
            end
            
            %load all of the two step patches
            R = zeros(psh,psh,rin);
            mms = zeros(rin,1);
            mmr = zeros(rin,1);
            qs = zeros(rin,1);
            qr = zeros(rin,1);
            FSimBaseR = zeros(rin,1);      
            RSim = zeros(rin,1);
            idx = 0;
            if sspin > 0
                for i=1:sspin    %sspin is the Fin
                    sr = scanr_self(3,i,rl,cl);
                    sc = scanr_self(4,i,rl,cl);
                    %hr candidate number
                    hrcanin = para.NumberOfHCandidate;
                    for j=1:hrcanin
                        idx = idx + 1;
                        R(:,:,idx) = hrpatch(:,:,sr,sc,j);
                        mms(idx) = scanr_self(1,i,rl,cl);
                        qs(idx) = scanr_self(2,i,rl,cl);
                        mmr(idx) = scanr(1,j,sr,sc);
                        qr(idx) = scanr(2,j,sr,sc);
                        FSimBaseR(idx) = FSimPure(i);
                        RSim(idx) = scanr(6,j,sr,sc);
                    end
                end
            else
                idx = 1;
                rin = 1;   %use bicubic 
                R(:,:,idx) = imb(rh:rh1,ch:ch1);
                FSimBaseR(idx) = 1;FSimPure(i);
            end

            %here is a question, how to define the similarity between H and R?
            %L2norm?
            hscore = zeros(hin,1);
            for i=1:hin
                theH = H(:,:,i);
                for j=1:rin
                    theR = R(:,:,j);
                    spf = FSimBaseR(j);
                    %similarity between H and R
                    diff = theH - theR;
                    L2N = norm(diff(:));
                    shr = exp(- L2N/pshs);
                    hscore(i) = hscore(i) + shr*spf;
                end
            end
            [maxscore idx] = max(hscore);
            %take this as the example
            Reliablemap(rh:rh1,ch:ch1) = Reliablemap(rh:rh1,ch:ch1) + HSim(idx)*mhrf;
            
            if hin > 0      %some patches can't find H
                hrres_nomi(rh:rh1,ch:ch1) = hrres_nomi(rh:rh1,ch:ch1) + H(:,:,idx).*mhrf;
                hrres_deno(rh:rh1,ch:ch1) = hrres_deno(rh:rh1,ch:ch1) + mhrf;                
            end
            %if any of its neighbor belongs to noHmap, copy additional region to hrres
            %if the pixel belongs to noHmapneighbor, then expand the copy regions
            if noHmapneighbor(rl,cl) == true
                mhrfspecial = zeros(5*s);
                mhrfspecial(r1:r2,c1:c2) = 1;
                for i=1:4
                    rs = rsa(i);
                    cs = csa(i);
                    checkr = rl+rs;
                    checkc = cl+cs;
                    if checkr > 0 && checkr < lh-ps+1 && checkc >0 && checkc <lw-ps+1 && noHmapToFill(checkr,checkc)
                        %recompute the mhrf and disable the noHmapToFill
                        noHmapToFill(checkr,checkc) = false;
                        switch i
                            case 1
                                mhrfspecial(r1:r2,c1+s:c2+s) = 1;
                            case 2
                                mhrfspecial(r1-s:r2-s,c1:c2) = 1;
                            case 3
                                mhrfspecial(r1:r2,c1-s:c2-s) = 1;
                            case 4
                                mhrfspecial(r1+s:r2+s,c1:c2) = 1;
                        end
                    end
                end
                mhrfspeical = imfilter(mhrfspecial,kernel,'replicate');

                hrres_nomi(rh:rh1,ch:ch1) = hrres_nomi(rh:rh1,ch:ch1) + H(:,:,idx).*mhrfspeical;
                hrres_deno(rh:rh1,ch:ch1) = hrres_deno(rh:rh1,ch:ch1) + mhrfspeical;                
            end
        end
    end
    hrres = hrres_nomi ./hrres_deno;
    exception = isnan(hrres);
    hrres_filtered = hrres;
    hrres_filtered(exception) = 0;
    img_texture = (hrres_filtered .* (1-exception) + imb .*exception);
end
function [scanr_self scanra_self] = F22_SearchForSelfSimilarPatchesL2Norm(img_y,para)
    ps = para.ps;
    patcharea = ps^2;
    [lh lw] = size(img_y);
    %Find self similar patches
    Fpatchnumber = 10;
    scanr_self = zeros(5,Fpatchnumber,lh-ps+1,lw-ps+1);       %scan results: mm, quan, r,c, similarity
    scanra_self = Fpatchnumber * ones(lh-ps+1,lw-ps+1);       %scan results active
    in = (lh-ps+1)*(lw-ps+1);
    fs = zeros(patcharea,in);
    rec = zeros(2,in);
    idx = 0;
    for rl=1:lh-ps+1
        for cl=1:lw-ps+1
            idx = idx + 1;
            rec(:,idx) = [rl;cl];
            fs(:,idx) = reshape(img_y(rl:rl+ps-1,cl:cl+ps-1),patcharea,1);
        end
    end
    
    %search
    idx = 0;
    for rl=1:lh-ps+1
        for cl=1:lw-ps+1
            idx = idx + 1;
            fprintf('idx %d in %d\n',idx,in);
            qf = fs(:,idx);
            diff = fs - repmat(qf,1,in);
            sqr = sum(diff.^2);
            [ssqr ix] = sort(sqr);
            saveidx = 0;
            for j=1:11
                indexinsort = ix(j);
                sr = rec(1,indexinsort);
                sc = rec(2,indexinsort);
                if sr ~= rl || sc ~= cl
                    saveidx = saveidx + 1;
                    l2norm = sqrt(ssqr(j));
                    similarity = exp(-l2norm/25);
                    scanr_self(:,saveidx,rl,cl) = cat(1,-1,-1,sr,sc,similarity);
                end
            end
        end
    end
end
%this function may be replaced by IF1a
function Grad = Img2Grad(img)
    [h w] = size(img);
    Grad = zeros(h,w,8);
    DiffOp = RetGradientKernel();
    for i=1:8
        Grad(:,:,i) = imfilter(img,DiffOp{i},'replicate');
    end
end
function f = RetGradientKernel()
    f = cell(8,1);
    f{1} = [0  0 0;
            0 -1 1;
            0  0 0];
    f{2} = [0  0 1;
            0 -1 0;
            0  0 0];
    f{3} = [0  1 0;
            0 -1 0;
            0  0 0];
    f{4} = [1  0 0;
            0 -1 0;
            0  0 0];
    f{5} = [0  0 0;
            1 -1 0;
            0  0 0];
    f{6} = [0  0 0;
            0 -1 0;
            1  0 0];
    f{7} = [0  0 0;
            0 -1 0;
            0  1 0];
    f{8} = [0  0 0;
            0 -1 0;
            0  0 1];
end

