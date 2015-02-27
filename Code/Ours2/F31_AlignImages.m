%Chih-Yuan Yang
%09/29/12
%as title
function alignedimages = F30_AlignImages(rawexampleimage, inputpoints, basepoints)
    %the rawexampleimage should be double
    if ~isa(rawexampleimage,'uint8')
        error('wrong class');
    end
    exampleimagenumber = size(rawexampleimage,3);
    %find the transform matrix by solving an optimization problem
    alignedimages = zeros(480,640,exampleimagenumber,'uint8');     %set as uint8 to reduce memory demand
    parfor i=1:exampleimagenumber
        alignedimages(:,:,i) = F18_AlignExampleImageByLandmarkSet(rawexampleimage(:,:,i),inputpoints(:,:,i),basepoints);
    end
end
