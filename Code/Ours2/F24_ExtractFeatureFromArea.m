%Chih-Yuan Yang
%09/25/12
%Change name, from U16 to F24
function feature = F24_ExtractFeatureFromArea(area)
    [h w] = size(area);
    %the feature: gradient
    %check type, int8 can not compute feature
    if isa(area,'double')
        area_double = area;
    else
        area_double = double(area);
    end
    dx = area_double(:,2:end) - area_double(:,1:end-1);
    dy = area_double(2:end,:) - area_double(1:end-1,:);
    feature = cat(1,reshape(dx,[h*(w-1) 1]), reshape(dy,[(h-1)*w 1]));
end
