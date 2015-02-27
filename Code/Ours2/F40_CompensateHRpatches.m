%Chih-Yuan Yang
%10/07/12
function hrpatch_compensate = F40_CompensateHRpatches(hrpatch, img_y, zooming, hrpatchextractdata,lrexampleimages)
    %in:
    %hrpatchextractdata: (h_lr-patchsize_lr+1) x (w_lr-patchsize_lr+1) x numberofHcandidate x 3      %ii,r_lr_src,c_lr_src

    hrpatch_compensate = zeros(size(hrpatch));
    patchsize_hr = size(hrpatch,1);
    patchsize_lr = patchsize_hr / zooming;
    [h_lr_active w_lr_active numberofHcandidate ~] = size(hrpatchextractdata);
    for rl = 1:h_lr_active
        rl1 = rl + patchsize_lr -1;
        for cl = 1:w_lr_active
            cl1 = cl + patchsize_lr -1;
            patch_lr = img_y(rl:rl1,cl:cl1);
            for k=1:numberofHcandidate
                patch_hr = hrpatch(:,:,rl,cl,k);
                ii = hrpatchextractdata(rl,cl,k,1);
                sr = hrpatchextractdata(rl,cl,k,2);
                sc = hrpatchextractdata(rl,cl,k,3);
                sr1 = sr+patchsize_lr-1;
                sc1 = sc+patchsize_lr-1;
                patch_lr_found = lrexampleimages(sr:sr1,sc:sc1,ii);
                diff_lr = patch_lr - patch_lr_found;
                diff_hr = imresize(diff_lr,zooming,'bilinear'); 
                patch_hr_compensated = patch_hr + diff_hr;
                hrpatch_compensate(:,:,rl,cl,k) = patch_hr_compensated;
            end
        end
    end
end
