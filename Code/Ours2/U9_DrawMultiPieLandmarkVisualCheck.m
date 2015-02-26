%Chih-Yuan Yang
%10/01/12
function hfig = U9_DrawMultiPieLandmarkVisualCheck(image,landmark,bshowtext)
    %show image
    hfig = figure;
    imshow(image);
    axis off image
    hold on
    
    %show landmark
    plot(landmark(:,1),landmark(:,2),'w.','MarkerSize',30);     %why the color changes after hfig returns?
    
    %show text
    if bshowtext
        setsize = size(landmark,1);
        for i=1:setsize;
            text(landmark(i,1),landmark(i,2), sprintf('%d',i));
        end
    end
end