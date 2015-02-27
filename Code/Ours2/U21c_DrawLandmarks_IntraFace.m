%Chih-Yuan Yang
%09/15/12
%Sometimes the format of landmarks are coordinates rather than boxes
%U21b 03/19/14 update the fucntion, the bdrawpose does not work
%U21c 03/19/14 The new file accepts the output of IntraFace
%The format of IntraFace
%   output.pred - predicted landmarks (49 x 2) or [] if no face detected(or not reliable) 
%   output.pose - head pose struct
%     output.pose.angle  1x3 - rotation angle
%     output.pose.rot    3x3 - rotation matrix
%   output.conf - confidence score of the prediction

function hfig = U21c_DrawLandmarks_IntraFace(im, points ,bshownumbers,bdrawpose,bvisible)
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
    end
    for i=1:setnumber
        x = points(i,1);
        y = points(i,2);
        
        plot(x,y,'r.','markersize',9);
        if bshownumbers
            text(double(x),double(y), num2str(i), 'fontsize',9,'color','k');
        end
    end
    drawnow;
end
