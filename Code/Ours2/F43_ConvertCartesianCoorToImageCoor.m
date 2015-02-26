%Chih-Yuan Yang
%10/29/12

function pts_image = F43_ConvertCartesianCoorToImageCoor(pts_cartisian, imagesize)
    h = imagesize(1);
    w = imagesize(2);       %not used
    [pointperimage, dimperpts, imagenumber] = size(pts_cartisian);
    pts_image = zeros(pointperimage, dimperpts, imagenumber);
    for ii = 1:imagenumber
        for ptsidx =1:pointperimage
            pts_image(ptsidx,1,ii) = pts_cartisian(ptsidx,1,ii);
            pts_image(ptsidx,2,ii) = h - pts_cartisian(ptsidx,2,ii);
        end
    end
end