%09/19/12
%Chih-Yuan Yang
%add report
function img_bp = F11_BackProjection(img_lr, img_hr, Gau_sigma, iternum,bReport)
    [h_hr] = size(img_hr,1);
    [h_lr] = size(img_lr,1);
    zooming = h_hr/h_lr;
    for i=1:iternum
        img_lr_gen = F19_GenerateLRImage_BlurSubSample(img_hr,zooming,Gau_sigma);
        diff_lr = img_lr - img_lr_gen;
        term_diff_lr_SSD = sum(sum(diff_lr.^2));
        diff_hr = imresize(diff_lr,zooming,'bilinear');
        img_hr = img_hr + diff_hr;
        img_lr_new = F19_GenerateLRImage_BlurSubSample(img_hr,zooming,Gau_sigma);
        diff_lr_new = img_lr - img_lr_new;       
        term_diff_lr_SSD_afteronebackprojection = sum(sum(diff_lr_new.^2));
        if bReport
            fprintf('backproject iteration=%d, term_before=%0.1f, term_after=%0.1f\n', ...
            i,term_diff_lr_SSD,term_diff_lr_SSD_afteronebackprojection);        
        end        
    end
    img_bp = img_hr;
end