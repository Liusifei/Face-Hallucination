%Chih-Yuan Yang
%08/31/12
function [alignedexampleimage alignedlandmarks] = U12_AlignExampleImageByTestEyes(exampleimage,landmarks,eyecenter,testeyecenter)
    [h w exampleimagenumber] = size(exampleimage);
    alignedexampleimage = zeros(h, w, exampleimagenumber,'uint8');
    alignedlandmarks = zeros(68,2,exampleimagenumber);
    parfor i=1:exampleimagenumber
        %show the message if not matlatpool
        %if mod(i,100) == 0
        %    fprintf('aligning images and landmarks i=%d\n',i);
        %end
        [alignedimage_this alignedlandmark_this] = U10_ConvertImageAndLandmarksByTwoPoints(exampleimage(:,:,i),landmarks(:,:,i),eyecenter(:,:,i),testeyecenter);
        alignedexampleimage(:,:,i) = alignedimage_this;
        alignedlandmarks(:,:,i) = alignedlandmark_this;
    end
end
