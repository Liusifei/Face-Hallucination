%11/10/12
%Chih-Yuan Yang
%Align all faces by two eyes. This preprocessing is required by Liu07 and Ma10, but not our algorithm
%This is necessary for training images to find good examples.
%PP2b: for wild, the format of landmark has to change because there is no hand-made landmarks
clear
%load image
folder_eyecenter = fullfile('Examples','Upfrontal2','Training');   %folder of images to compute the position of eyes
folder_landmark_raw = fullfile('Examples','MetaData','AllLandmarks_Upfrontal');
folder_imagecrop = fullfile('RawSource','Wild');       %folder of images to crop
fileext_imagecrop = '.jpg';
folder_landmark_imagecrop = fullfile('RawSource','Wild');
folder_image_save = fullfile('Source','Wild2','GroundTruth');
folder_landmark_save = fullfile('Source','Wild2','DetectedLandmarks');
fileidx_start = 4;
fileidx_end = 4;


U22_makeifnotexist(folder_image_save);
U22_makeifnotexist(folder_landmark_save);
filelist_eyecenter = dir(fullfile(folder_eyecenter,'*.png'));
filenumber = length(filelist_eyecenter);

bcropimage = true;
balignlandmarks = true;

%compute means of two eyes among all training image
eyecenter_training = zeros(2,2,filenumber);  %right eye x, right eye y, left eye x, left eye y    
%record all landmarks for alignment
rawlandmarks_image = zeros(68,2,filenumber);
%only right eye and left eye are used
for i=1:filenumber
    %load the landmark
    fn_image = filelist_eyecenter(i).name;
    fn_image_short = fn_image(1:end-4);
    fn_landmark = [fn_image_short '_lm.mat'];
    loaddata = load(fullfile(folder_landmark_raw,fn_landmark));
    landmarks = loaddata.pts;
    rawlandmarks_image(:,:,i) = loaddata.pts;
    %find the location of center of eyes
    %the landmark numbers are 37 to 42 (the subject's right eye)
    %43 to 48 (the subject's left eye)
    eyecenter_training(1,:,i) = mean(landmarks(37:42,:));        %left eye
    eyecenter_training(2,:,i) = mean(landmarks(43:48,:));        %right eye
end
%compute the average of the three points as aligned position
eyecentermean = mean(eyecenter_training,3);
lefteye.x = eyecentermean(1,1);      %the left eye is the eye on the image
lefteye.y = eyecentermean(1,2);
righteye.x = eyecentermean(2,1);
righteye.y = eyecentermean(2,2);
%The two eyes are not horizontal
%rotate the right eye as high as the left eye
eyeslopeangle = atan(-(righteye.y-lefteye.y)/(righteye.x-lefteye.x));
eyedist = sqrt((righteye.y-lefteye.y)^2+(righteye.x-lefteye.x)^2);
newrighteye.x = lefteye.x + eyedist;
newrighteye.y = lefteye.y;
neweyecenter.x = (lefteye.x + newrighteye.x)/2;
neweyecenter.y = (lefteye.y + newrighteye.y)/2;

%align all images to the two points by affim transform
%use cp2tform
base_points_image = zeros(2,2);                   %base_points_image are the aligned points
base_points_image(1,:) = [lefteye.x lefteye.y];
base_points_image(2,:) = [newrighteye.x newrighteye.y];

left = round(neweyecenter.x)-120;
right = round(neweyecenter.x)+119;
top = round(neweyecenter.y)-160;
bottom = round(neweyecenter.y)+159;

eyecenter_mean_cartisian = F42_ConvertImageCoorToCartesianCoor( base_points_image, [480,640]);


filelist_imagecrop = dir(fullfile(folder_imagecrop,['*' fileext_imagecrop]));
filenumber = length(filelist_imagecrop);
clear eyecenter   %the old eyecenter
for i=fileidx_start:fileidx_end
    fn_image = filelist_imagecrop(i).name;
    fn_image_short = fn_image(1:end-4);
    %load landmarks of image_crop for alignement
    %fn_landmark = [fn_image_short '_lm.mat'];
    fn_landmark = [fn_image_short '_mi.mat'];       %this is detected landmarks
    loaddata = load(fullfile(folder_landmark_imagecrop,fn_landmark));
    landmarks_detected = loaddata.bs;
    landmarks = F4_ConvertBStoMultiPieLandmarks(landmarks_detected);
    eyecenter(1,:) = mean(landmarks(37:42,:));
    eyecenter(2,:) = mean(landmarks(43:48,:));

    input_points = eyecenter;       %change the name easy to understand
    tform = cp2tform(input_points, base_points_image,'nonreflective similarity');
    XData = [1 640];
    YData = [1 480];
        
    if bcropimage
        img_read = imread(fullfile(folder_imagecrop,fn_image));
        [img_aligned] = imtransform(img_read,tform,'XData',XData,'YData',YData);

        %crop the face region
        img_crop = img_aligned(top:bottom,left:right,:);
        fn_save = sprintf('%s.png',fn_image_short);
        imwrite(img_crop,fullfile(folder_image_save,fn_save));    
    end
    
    %compute the aligned landmark coordinate
    if balignlandmarks
        landmarks_raw = landmarks;
        %Convert image coordinate to cartisian coordinate
        eyecenter_cartisian = F42_ConvertImageCoorToCartesianCoor( eyecenter, [480,640]);
        landmarks_raw_cartisian = F42_ConvertImageCoorToCartesianCoor( landmarks_raw, [480,640]);
        
        landmarks_aligned_cartisian = zeros(size(landmarks_raw_cartisian));
        transformmatrix = F44_ComputeTransformMatrix(eyecenter_cartisian, eyecenter_mean_cartisian);
        for j=1:68
            landmark_points_cartisian = landmarks_raw_cartisian(j,:);
            input_data = [landmark_points_cartisian 1]';
            output_data = transformmatrix * input_data;
            landmarks_aligned_cartisian(j,:) = output_data(1:2)';
        end
        %the base_points_cartisian need to be saved for test case.
        landmarks_aligned_image = F43_ConvertCartesianCoorToImageCoor(landmarks_aligned_cartisian,[480 640]);
        %since the image are cropped, the landmarks of the cropped image need to an offset
        landmarks_aligned_offset = landmarks_aligned_image - repmat( [left-1 top-1],[68,1]);   %format: x,y
        fn_save = sprintf('%s_lm.mat',fn_image_short);
        pts = landmarks_aligned_offset;
        save(fullfile(folder_landmark_save,fn_save),'pts');
    end
end


%draw some images to confirm the correctness
%if bshownewlandmarks
%    for i=1:filenumber
%        fn_image = filelist(i).name;
%        fn_image_short = fn_image(1:end-4);
%        fn_load = sprintf('%s_aligned.png',fn_image_short);
%        img_load = imread(fullfile(alignedimagefolder,fn_load));
%        imshow(img_load);
%        hold on
%        for j=1:68
%            plot(new_landmark_points_image(:,1,i),new_landmark_points_image(:,2,i),'r.','markersize',15);
%        end
%    end
%end 
    
%since the left eye coordinate is x:296.16 y:195.14 and the right eye coordinate is x:368.25 y:195.13
%the crop region I choose is r:35~354 c:212~451
%the size is 320*240 and the centroid is at the center of the two eyes
%if bcropimage
%    for i=1:filenumber
%        %load the landmark
%        fn_image = filelist(i).name;
%        fn_image_short = fn_image(1:end-4);
%        fn_read = sprintf('%s_aligned.png',fn_image_short);
%        img_read = imread(fullfile(alignedimagefolder,fn_read));
%        img_crop = img_read(35:354,212:451,:);
%        fn_save = sprintf('%s_crop.png',fn_image_short);
%        imwrite(img_crop,fullfile(croppedimagefolder,fn_save));
%    end
%end
