function F21_RecordScore(fn_txt, fn_testfile, PSNR, SSIM, DIIVINE, para)
    %in the future, assign the name by para
    fn_save = fullfile(para.tuningfolder,fn_txt);
    fid = fopen(fn_save,'a+');
    fprintf(fid,'%s %0.2f %0.4f %0.2f\n',fn_testfile, PSNR, SSIM, DIIVINE);
    fclose(fid);
end