%Chih-Yuan Yang
%09/15/12
%Change from F18 to F18, two points only, no optimization
function alignedexampleimage = F18a_AlignExampleImageByTwoPoints(exampleimage,inputpoints,basepoints)
    [h w d] = size(exampleimage);
    tform = cp2tform(inputpoints, basepoints,'nonreflective similarity');
    %generated the transform images
    XData = [1 w];
    YData = [1 h];
    alignedexampleimage = imtransform(exampleimage,tform,'XData',XData,'YData',YData);
end
