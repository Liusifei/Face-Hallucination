%Chih-Yuan Yang
%10/01/12
%Correct error, the mapping from coordinate to index is round rather than floor or ceil
function region = F29_AddPixelIdxFromCoor(region)
    region.left_idx = round(region.left_coor);
    region.top_idx = round(region.top_coor);
    region.right_idx = round(region.right_coor);
    region.bottom_idx = round(region.bottom_coor);
end
