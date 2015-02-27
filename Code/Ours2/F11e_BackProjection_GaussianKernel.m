%Chih-Yuan Yang
%07/20/14 
%F11c: controlled by iternum
%F11d: controled by TolF
%F11e: I replace the IF5 internal function by F26 since they are identical. 
%      I update the code to support the scaling factor of 3. I replace the F19a
%      by F19c since F19c is simpler and does not require F20.
function img_bp = F11e_BackProjection_GaussianKernel(img_lr, img_hr, Gau_sigma, iternum,bReport,TolF)
    [h_hr] = size(img_hr,1);
    [h_lr] = size(img_lr,1);
    zooming = h_hr/h_lr;
    for i=1:iternum
        img_lr_gen = F19c_GenerateLRImage_GaussianKernel(img_hr,zooming,Gau_sigma);
        diff_lr = img_lr - img_lr_gen;
        RMSE_diff_lr = sqrt(mean2(diff_lr.^2));
        diff_hr = F26_UpsampleAndBlur(diff_lr,zooming, Gau_sigma);
        %diff_hr = imresize(diff_lr,zooming,'bilinear');
        img_hr = img_hr + diff_hr;
        img_lr_new = F19c_GenerateLRImage_GaussianKernel(img_hr,zooming,Gau_sigma);
        diff_lr_new = img_lr - img_lr_new;       
        RMSE_diff_lr_afteronebackprojection = sqrt(mean2(diff_lr_new.^2));
        if bReport
            fprintf('backproject iteration=%d, RMSE_before=%0.6f, RMSE_after=%0.6f\n', ...
            i,RMSE_diff_lr,RMSE_diff_lr_afteronebackprojection);        
        end
        if RMSE_diff_lr_afteronebackprojection < TolF
            disp('RMSE_diff_lr_afteronebackprojection < TolF');
            break;
        end
    end
    img_bp = img_hr;
end
