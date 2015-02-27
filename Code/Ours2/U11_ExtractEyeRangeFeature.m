%Chih-Yuan Yang
%08/31/12
function eyerangefeature = U11_ExtractEyeRangeFeature(eyerange)
    [h w] = size(eyerange);
    %the feature: gradient
    %check type, int8 can not compute feature
    if isa(eyerange,'double')
        eyerange_double = eyerange;
    else
        eyerange_double = double(eyerange);
    end
    dx = eyerange_double(:,2:end) - eyerange_double(:,1:end-1);
    dy = eyerange_double(2:end,:) - eyerange_double(1:end-1,:);
    eyerangefeature = cat(1,reshape(dx,[h*(w-1) 1]), reshape(dy,[(h-1)*w 1]));
end
