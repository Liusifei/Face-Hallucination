%Chih-Yuan Yang
%10/02/12
%
%07/20/14 F33 should be replaced by F33a
%function [mask_lr mask_hr] = F33_ComputeMask_Eyebrows(landmarks_hr)
    %points 18:27 are eyebrows
    
    mask_hr = zeros(480,640);
    drawpair = [18 19;    %left
                 19 20;
                 20 21;
                 21 22;
                 22 23;    %middle
                 23 24;    %right
                 24 25;
                 25 26;
                 26 27;];
    eyebrowsrange = 18:27;
    eyesrange = 37:48;
    for k=1:size(drawpair,1);
        i = drawpair(k,1);
        j = drawpair(k,2);
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
    
    %fill the lower part
    left_coor = min(landmarks_hr(eyebrowsrange,1));
    right_coor = max(landmarks_hr(eyebrowsrange,1));

    left_idx = round(left_coor);
    right_idx = round(right_coor);
    rmax = round(min(landmarks_hr(eyesrange,2)));
    for ch = left_idx:right_idx
        rmin = find(mask_hr(:,ch),1,'first');
        mask_hr(rmin+1:rmax,ch) = 1;
    end

    %blur the boundary
    mask_hr = imfilter(mask_hr,fspecial('gaussian',11,1.6));

    mask_lr = F19a_GenerateLRImage_GaussianKernel(mask_hr,4,1.6);
end
