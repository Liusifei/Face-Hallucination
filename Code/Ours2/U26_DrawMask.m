%Chih-Yuan Yang
%10/10/12
function U26_DrawMask(img, componentrecord, bsave, fn_save)
    if nargin < 3
        bsave = false;
    end
    codefolder = fileparts(pwd);
    addpath(fullfile(codefolder,'Lib','YIQConverter'));
    [h w] = size(img);
    img = repmat(img,[1 1 3]);   %prepare for color
    img_yiq = RGB2YIQ(img);
    img_y = img_yiq(:,:,1);
    img_iq = img_yiq(:,:,2:3);
    
    color{1} = [1 0 0];  %red
    color{2} = [1 1 0];  %yellow
    color{3} = [0 1 0];  %green
    color{4} = [0 0 1];  %blue
    
    for k=1:4
        rgb_color = reshape(color{k},[1 1 3]);
        yiq_color = RGB2YIQ(rgb_color);
        iq_color = yiq_color(2:3);
        mask = componentrecord(k).mask_lr;
        img_iq = img_iq + repmat(iq_color, [h w 1]) .* repmat(mask, [1 1 2]);
    end
    
    img_yiq = cat(3,img_y,img_iq);
    img_rgb = YIQ2RGB(img_yiq);
    
    if bsave
        imwrite(img_rgb,fn_save);
    else
        figure
        imshow(img_rgb);
    end
end