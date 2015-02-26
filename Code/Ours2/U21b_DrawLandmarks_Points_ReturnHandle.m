%Chih-Yuan Yang
%09/15/12
%Sometimes the format of landmarks are coordinates rather than boxes
%U21b 03/19/14 update the fucntion, the bdrawpose does not work
function hfig = U21b_DrawLandmarks_Points_ReturnHandle(im, points, str_pose,bshownumbers,bdrawpose,bvisible)
    if bvisible
        hfig = figure;
    else
        hfig = figure('Visible','off');
    end
    imshow(im);
    hold on;
    axis image;
    axis off;

    setnumber = size(points,1);
    if bdrawpose
        tx = (min(points(:,1)) + max(points(:,1)))/2;       %tx means half face width
        ty = min(points(:,2)) - tx;        
        text(tx,ty, str_pose,'fontsize',18,'color','c');
    end
    for i=1:setnumber
        x = points(i,1);
        y = points(i,2);
        
        plot(x,y,'r.','markersize',9);
        if bshownumbers
            text(x,y, num2str(i), 'fontsize',9,'color','k');
        end
    end
    drawnow;
end
