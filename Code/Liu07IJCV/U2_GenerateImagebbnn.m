%date of last edit: 08/10/12, rename Zooming to zooming
function U2_GenerateImagebbnn(img_y, para)
    s = para.zooming;
    imb255 = imresize(img_y,s) * 255;
    imgnn= imresize(img_y,s,'nearest');
    imwrite(imb255/255,fullfile(para.tuningfolder,[para.SaveName '_bb.png']));
    imwrite(imgnn,fullfile(para.tuningfolder,[para.SaveName '_nn.png']));
    
    imgbb = imresize(img_y,s);
    imgbb(imgbb > 1) = 1;
    imgbb(imgbb < 0) = 0;
    img_out_yiq = imgbb;
    img_out_yiq(:,:,2:3) = para.IQLayer_upsampled;
    img_out_rgb = YIQ2RGB(img_out_yiq);
    fn = sprintf('%s_bbcolor.png',para.SaveName);
    imwrite(img_out_rgb, fullfile(para.tuningfolder, fn));

    img_out_yiq = imgnn;
    img_out_yiq(:,:,2:3) = para.IQLayer_upsampled;
    img_out_rgb = YIQ2RGB(img_out_yiq);
    fn = sprintf('%s_nncolor.png',para.SaveName);
    imwrite(img_out_rgb, fullfile(para.tuningfolder, fn));
end