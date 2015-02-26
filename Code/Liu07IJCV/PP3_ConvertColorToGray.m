%08/22/12
%Chih-Yuan Yang
%Align all faces by three points: the center of eyes and the top of noses
%for computing PCA

clear
%load image
para.trainingfacescolor = fullfile('Examples','TrainingFaces_Color');
para.trainingfacesgray = fullfile('Examples','TrainingFaces_Gray');
para.testfacescolor = fullfile('Examples','TestFaces_Color');
para.testfacesgray = fullfile('Examples','TestFaces_Gray');
filelist = dir(fullfile(para.trainingfacescolor,'*.png'));
filenumber = length(filelist);

para.bconverttrainingfolder = true;
para.bconverttestfolder = false;
if para.bconverttrainingfolder
    for i=1:filenumber
        %load the landmark
        fn_image = filelist(i).name;
        fn_image_short = fn_image(1:end-4);
        fn_image_pure = fn_image(1:end-9);
        img_read = imread(fullfile(para.trainingfacescolor,fn_image));
        img_gray = rgb2gray(img_read);
        fn_image_save = sprintf('%s.png',fn_image_pure);
        imwrite( img_gray, fullfile(para.trainingfacesgray,fn_image_save));
    end
end

if para.bconverttestfolder;
    filelist = dir(fullfile(para.testfacescolor,'*.png'));
    filenumber = length(filelist);
    for i=1:filenumber
        %load the landmark
        fn_image = filelist(i).name;
        fn_image_short = fn_image(1:end-4);
        fn_image_pure = fn_image(1:end-9);
        img_read = imread(fullfile(para.testfacescolor,fn_image));
        img_gray = rgb2gray(img_read);
        fn_image_save = sprintf('%s.png',fn_image_pure);
        imwrite( img_gray, fullfile(para.testfacesgray,fn_image_save));
    end
end
