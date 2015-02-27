%Chih-Yuan Yang
%10/07/12
%Sepearte internal function as external
function hrpatch = F39_ExtractAllHrPatches(patchsize_lr,zooming,hrpatchextractdata,allHRexampleimages)
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
        fprintf('extracting image %d in function F39\n',ii);
        exampleimage_hr = im2double(allHRexampleimages(:,:,ii));
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
        end        
    end
end
