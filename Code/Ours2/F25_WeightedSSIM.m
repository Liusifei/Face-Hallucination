function weightedssim = F25_WeightedSSIM(img_gt, img_test)
    [~, ssimmap] = ssim(img_gt,img_test);
    SRSSDmap = F15_ComputeSRSSD(img_gt);
    SRSSDmap_trim = SRSSDmap(6:end-5,6:end-5);
    product = SRSSDmap_trim .*ssimmap;
    weightedssim = sum(product(:))/sum(SRSSDmap_trim(:));
end