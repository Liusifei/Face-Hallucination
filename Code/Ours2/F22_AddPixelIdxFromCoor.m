function region = F22_AddPixelIdxFromCoor(region)
    region.left_idx = floor(region.left_coor);
    region.top_idx = floor(region.top_coor);
    region.right_idx = ceil(region.right_coor);
    region.bottom_idx = ceil(region.bottom_coor);
end
