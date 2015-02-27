%08/22/12
%Compute PCA

function PP5_GenerateLRImage()
    %for test images
    %sourcefolder = fullfile('Examples','TestFaces_Color');
    %dstfolder = fullfile('Source','TestFaces');
    %GenerateLRImagesWholeFolder(sourcefolder,dstfolder);

    %for training images;
    sourcefolder = fullfile('Examples','TrainingFaces_Gray');
    dstfolder = fullfile('Examples','TrainingFaces_LRGray');
    GenerateLRImagesWholeFolder(sourcefolder,dstfolder);
end

function GenerateLRImagesWholeFolder(sourcefolder,dstfolder)
    if ~exist(dstfolder,'dir')
        mkdir(dstfolder);
    end
    filelist = dir(fullfile(sourcefolder,'*.png'));
    filenumber = length(filelist);
    for i=1:filenumber
        fn_image = filelist(i).name;
%        fn_image_short = fn_image(1:end-4);
        img_hr = im2double(imread(fullfile(sourcefolder,fn_image)));
        img_lr = U3_GenerateLRImage_BlurSubSample(img_hr,4,1.6);
%        fn_save = sprintf('%s.png',fn_image);
        imwrite( img_lr, fullfile(dstfolder,fn_image));
    end    
end
