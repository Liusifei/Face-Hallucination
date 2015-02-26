%Chih-Yuan Yang
%10/22/12
%Blur the mask_hr to prevent discontinue boundary
%07/20/14 F32 should be replaced by F32a
%function [mask_lr, mask_hr] = F32_ComputeMask_Mouth(landmarks_hr)
    %poits 49:68 are mouth
    
    mask_hr = zeros(480,640);
    setrange = 49:68;
    checkpair = [49 50;
                 50 51;
                 51 52;
                 52 53;
                 53 54;
                 54 55;
                 55 56;
                 56 57;
                 57 58;
                 58 59;
                 59 60;
                 60 49];
    for k=1:size(checkpair,1);
        i = checkpair(k,1);
        j = checkpair(k,2);
        %mark the pixel between i and j
        coor1 = landmarks_hr(i,:);
        coor2 = landmarks_hr(j,:);
        x1 = coor1(1);
        c1 = round(x1);
        y1 = coor1(2);
        r1 = round(y1);
        x2 = coor2(1);
        c2 = round(x2);
        y2 = coor2(2);
        r2 = round(y2);
        a = y2-y1;
        b = x1-x2;
        c = (x2-x1)*y1 - (y2-y1)*x1;
        sqra2b2 = sqrt(a^2+b^2);
        rmin = min(r1,r2);
        rmax = max(r1,r2);
        cmin = min(c1,c2);
        cmax = max(c1,c2);
        for rl=rmin:rmax
            for cl=cmin:cmax
                y_test = rl;
                x_test = cl;
                distance = abs(a*x_test+b*y_test +c)/sqra2b2;
                if distance <= sqrt(2)/2
                    mask_hr(rl,cl) = 1;
                end
            end
        end
    end
    %fill the interior
    left_coor = min(landmarks_hr(setrange,1));
    right_coor = max(landmarks_hr(setrange,1));

    left_idx = round(left_coor);
    right_idx = round(right_coor);
    for cl = left_idx:right_idx
        rmin = find(mask_hr(:,cl),1,'first');
        rmax = find(mask_hr(:,cl),1,'last');
        if rmin ~= rmax
            mask_hr(rmin+1:rmax-1,cl) = 1;
        end
    end
    
    %blur the boundary
    mask_hr = imfilter(mask_hr,fspecial('gaussian',11,1.6));
    
    %do not dilate, otherwise the beard will be copied and generate wrong patterns
    %dilate the get the surrounding region
%    radius = 6;
%    approximateN = 0;
%    se = strel('disk',radius,approximateN);
%    mask_hr = imdilate(mask_hr,se);
    
    mask_lr = F19a_GenerateLRImage_GaussianKernel(mask_hr,4,1.6);
end
