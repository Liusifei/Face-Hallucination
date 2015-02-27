%Chih-Yuan Yang
%10/02/12
%07/20/14 F34 should be replaced by F34a
%function [mask_lr mask_hr] = F34_ComputeMask_Eyes(landmarks_hr)
    mask_hr = zeros(480,640);
    groupset{1} = [37 38;    %left
                 38 39;
                 39 40;
                 40 41;
                 41 42;
                 42 37];
    groupset{2} = [43 44;    %right
                 44 45;
                 45 46;
                 46 47;
                 47 48;
                 48 43];
    setrange{1} = 37:42;
    setrange{2} = 43:48;             
    for groupidx = 1:2
        checkpair = groupset{groupidx};
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
            for rh=rmin:rmax
                for ch=cmin:cmax
                    y_test = rh;
                    x_test = ch;
                    distance = abs(a*x_test+b*y_test +c)/sqra2b2;
                    if distance <= sqrt(2)/2
                        mask_hr(rh,ch) = 1;
                    end
                end
            end
        end
        
        %fill the interior
        left_coor = min(landmarks_hr(setrange{groupidx},1));
        right_coor = max(landmarks_hr(setrange{groupidx},1));

        left_idx = round(left_coor);
        right_idx = round(right_coor);
        for ch = left_idx:right_idx
            rmin = find(mask_hr(:,ch),1,'first');
            rmax = find(mask_hr(:,ch),1,'last');
            if rmin ~= rmax
                mask_hr(rmin+1:rmax-1,ch) = 1;
            end
        end
        
    end
    %dilate the get the surrounding region
    radius = 6;
    approximateN = 0;
    se = strel('disk',radius,approximateN);
    mask_hr = imdilate(mask_hr,se);

    %blur the boundary
    mask_hr = imfilter(mask_hr,fspecial('gaussian',11,1.6));
    
    mask_lr = F19a_GenerateLRImage_GaussianKernel(mask_hr,4,1.6);
end
