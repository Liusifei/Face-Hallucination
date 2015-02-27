for i=1:4
    mask_blackbackground = loaddata.mask_hr_record{i};
    [r_set,c_set] = find(mask_blackbackground);
    r_min = min(r_set);
    r_max = max(r_set);
    c_min = min(c_set);
    c_max = max(c_set);
    mask_whitebackground = 1- mask_blackbackground;
    exemplar_aligned = im2double(loaddata.retrievedhrimagerecord{i});
    if i==2
        mask_exclusive = loaddata.mask_hr_record{3} + loaddata.mask_hr_record{4};
        mask_exclusive(mask_exclusive>1) = 1;
        mask_active = mask_blackbackground - mask_exclusive;
        %refine it
        mask_active(mask_active < 0 ) = 0;
        mask_inactive  = 1 - mask_active;
        image_masked = mask_active .* exemplar_aligned + mask_inactive;
    else
        image_masked = mask_blackbackground .* exemplar_aligned + mask_whitebackground;
    end
    image_masked_crop = image_masked(r_min:r_max,c_min:c_max);
    fn_write = sprintf('image_masked_%d.png',i);
    imwrite(image_masked_crop,fullfile(folder_write,fn_write));
end
