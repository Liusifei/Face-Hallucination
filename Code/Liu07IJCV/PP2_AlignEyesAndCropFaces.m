%08/21/12
%Chih-Yuan Yang
%Align all faces by three points: the center of eyes and the top of noses
%for computing PCA

clear
%load image
para.rawexampleimagefolder = fullfile('Examples','Raw');
para.landmarkfolder = fullfile('Examples','RawLandmarks');
para.alignedimagefolder = fullfile('Examples','Aligned');
para.croppedimagefolder = fullfile('Examples','Cropped');
filelist = dir(fullfile(para.rawexampleimagefolder,'*.png'));
filenumber = length(filelist);

para.bcomputemean = false;
para.balignimage = false;
para.bcropimage = true;

if para.bcomputemean
    alignpoint = zeros(filenumber, 6);  %right eye x, right eye y, left eye x, left eye y, central nostril x, central nostril y
    for i=1:filenumber
        %load the landmark
        fn_image = filelist(i).name;
        fn_image_short = fn_image(1:end-4);
        fn_landmark = [fn_image_short '_lm.mat'];
        loaddata = load(fullfile(para.landmarkfolder,fn_landmark));
        landmarks = loaddata.pts;
        %find the location of center of eyes
        %the landmark numbers are 37 to 42 (the subject's right eye)
        %43 to 48 (the subject's left eye)
        %34 the (the center of two nostrils
        alignpoint(i,1) = mean(landmarks(37:42,1));
        alignpoint(i,2) = mean(landmarks(37:42,2));
        alignpoint(i,3) = mean(landmarks(43:48,1));
        alignpoint(i,4) = mean(landmarks(43:48,2));
        alignpoint(i,5) = mean(landmarks(34,1));
        alignpoint(i,6) = mean(landmarks(34,2));
    end
    %compute the average of the three points as aligned position
    meanalignpoint = mean(alignpoint,1);
    lefteye.x = meanalignpoint(1);      %the left eye is the eye on the image
    lefteye.y = meanalignpoint(2);
    righteye.x = meanalignpoint(3);
    righteye.y = meanalignpoint(4);
    nostril.x = meanalignpoint(5);
    nostril.y = meanalignpoint(6);
    %The two eyes are not horizontal
    %rotate the right eye as high as the left eye
    eyeslopeangle = atan(-(righteye.y-lefteye.y)/(righteye.x-lefteye.x));
    eyedist = sqrt((righteye.y-lefteye.y)^2+(righteye.x-lefteye.x)^2);
    newrighteye.x = lefteye.x + eyedist;
    newrighteye.y = lefteye.y;
    %the expect nostril location? according to the rotation, it should
    %be rorated -eyeslopeangle
    lefteyenostrildist = sqrt((lefteye.y-nostril.y)^2+(lefteye.x-nostril.x)^2);
    nostrilangle = atan(-(nostril.y-lefteye.y)/(nostril.x-lefteye.x));
    updatedangle = nostrilangle - eyeslopeangle;                                 %the angle I use is the traditional cartesian angle
    newnostril.x = lefteye.x + lefteyenostrildist * cos(updatedangle);
    newnostril.y = lefteye.y - lefteyenostrildist * sin(updatedangle);          %because the y axis in image is inversed against cartesian y axis
    %align all images to the three points by affim transform
    %How to do it?
    %use cp2tform
    base_points = zeros(2,2);
    base_points(1,:) = [lefteye.x lefteye.y];
    base_points(2,:) = [newrighteye.x newrighteye.y];
    %base_points(3,:) = [newnostril.x newnostril.y];        %can not use affine transform, only two points (left eye) and
    %right eye can be aligned.
end

if para.balignimage
    for i=1:filenumber
        %load the landmark
        fn_image = filelist(i).name;
        fn_image_short = fn_image(1:end-4);
        fn_save = sprintf('%s_aligned.png',fn_image_short);
        if exist(fullfile(para.alignedimagefolder,fn_save),'file')
            continue;
        end
        img_test = imread(fullfile(para.rawexampleimagefolder,fn_image));
        input_points = zeros(2,2);
        input_points(1,:) = [alignpoint(i,1) alignpoint(i,2)]; 
        input_points(2,:) = [alignpoint(i,3) alignpoint(i,4)]; 
    %    input_points(3,:) = [alignpoint(i,5) alignpoint(i,6)];
        tform = cp2tform(input_points, base_points,'nonreflective similarity');
        XData = [1 640];
        YData = [1 480];
        [img_aligned xdata ydata] = imtransform(img_test,tform,'XData',XData,'YData',YData);
        %all of the images are aligned because all of the output are cropped from the same XData and YData
    %    imshow(img_aligned);
    %    keyboard
        %save the image for furthur use
        imwrite(img_aligned,fullfile(para.alignedimagefolder,fn_save));
    end
end

%since the left eye coordinate is x:296.16 y:195.14 and the right eye coordinate is x:368.25 y:195.13
%the crop region I choose is r:35~354 c:212~451
%the size is 320*240 and the centroid is at the center of the two eyes
if para.bcropimage
    if ~exist(para.croppedimagefolder,'dir')
        mkdir(para.croppedimagefolder)
    end
    for i=1:filenumber
        %load the landmark
        fn_image = filelist(i).name;
        fn_image_short = fn_image(1:end-4);
        fn_read = sprintf('%s_aligned.png',fn_image_short);
        img_read = imread(fullfile(para.alignedimagefolder,fn_read));
        img_crop = img_read(35:354,212:451,:);
        fn_save = sprintf('%s_crop.png',fn_image_short);
        imwrite(img_crop,fullfile(para.croppedimagefolder,fn_save));
    end
end
