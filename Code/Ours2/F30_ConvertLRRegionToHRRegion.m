%Chih-Yuan Yang
%09/29/12
%Change name from U18 to F30
function region_hr = F30_ConvertLRRegionToHRRegion(region_lr, zooming)
    region_hr.left_idx = (region_lr.left_idx-1) * zooming + 1;
    region_hr.top_idx = (region_lr.top_idx-1) * zooming + 1;
    region_hr.right_idx = region_lr.right_idx * zooming;
    region_hr.bottom_idx = region_lr.bottom_idx * zooming;
    region_hr.width = region_hr.right_idx - region_hr.left_idx + 1;
    region_hr.height = region_hr.bottom_idx - region_hr.top_idx + 1;    
end
