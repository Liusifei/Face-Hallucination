%Chih-Yun Yang
%10/23/12
%Called by PP2_GenerateAlignImageAndAlignedLandmarks
function pts_cartisian = F42_ConvertImageCoorToCartesianCoor(pts_image, imagesize)
    h = imagesize(1);
    w = imagesize(2);       %not used
    [pointperimage, dimperpts, imagenumber] = size(pts_image);
    pts_cartisian = zeros(pointperimage, dimperpts, imagenumber);
    for ii = 1:imagenumber
        for ptsidx =1:pointperimage
            pts_cartisian(ptsidx,1,ii) = pts_image(ptsidx,1,ii);
            pts_cartisian(ptsidx,2,ii) = h - pts_image(ptsidx,2,ii);
        end
    end
end