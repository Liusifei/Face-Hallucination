%08/17/13
%Chih-Yuan Yang
%PP2c: Generate aligned ground truth images by aligning to the two eyes and cropped

clear
%load image
fn_eyelocation = 'Upfrontal.mat';
folder_eyelocation = 'LocationOfTwoEyesForAlignment';

%case Upfrontal3_1 test
% folder_filelist =  fullfile('Source','FileList');
% fn_filelist = 'TestImage342UpfrontalHighContrast.txt';
% folder_image_raw = fullfile('Source','Upfrontal3_1HighContrast','Raw');
% folder_landmark_raw = fullfile('Landmarks','Raw','Upfrontal');
% folder_image_save = fullfile('Source','Upfrontal3_1HighContrast','GroundTruth');

%case Upfrontal3_1 training
folder_filelist =  'FileList';
fn_filelist = 'TrainingImage2184Upfrontal3_1HighContrast.txt';
folder_image_raw = fullfile('Examples','Upfrontal3_1HighContrast','Raw');
folder_landmark_raw = fullfile('Landmarks','Raw','Upfrontal');
folder_image_save = fullfile('Examples','Upfrontal3_1HighContrast','High');

%folder_landmark_save = fullfile('Examples','Upfrontal3','Landmarks');
U22_makeifnotexist(folder_image_save);
%U22_makeifnotexist(folder_landmark_save);


bcropimage = true;
balignlandmarks = false;

%load eye locations
loaddata = load(fullfile(folder_eyelocation,fn_eyelocation),'lefteye','righteye');
lefteye = loaddata.lefteye;
righteye = loaddata.righteye;
eyecenter.x = (lefteye.x + righteye.x)/2;
eyecenter.y = (lefteye.y + righteye.y)/2;

%align all images to the two points by affim transform
%use cp2tform
base_points_image = zeros(2,2);                   %base_points_image are the aligned points
base_points_image(1,:) = [lefteye.x lefteye.y];
base_points_image(2,:) = [righteye.x righteye.y];

%set the cropped region
left = round(eyecenter.x)-120;
right = round(eyecenter.x)+119;
top = round(eyecenter.y)-160;
bottom = round(eyecenter.y)+159;

eyecenter_mean_cartisian = F42_ConvertImageCoorToCartesianCoor( base_points_image, [480,640]);

arr_filename = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_files = length(arr_filename);
clear eyecenter   %the old eyecenter
for idx_file=1:num_files
    fn_raw = arr_filename{idx_file};
    fn_short = fn_raw(1:end-4);
    fn_until_illumination = fn_short(1:end-3);
    %load landmarks of image_crop for alignement
    fn_landmark = [fn_until_illumination '_05_lm.mat'];       %we only have 051_05 landmarks, but they should be the same as 051_13
    loaddata = load(fullfile(folder_landmark_raw,fn_landmark));
    landmarks = loaddata.pts;
    eyecenter(1,:) = mean(landmarks(37:42,:));
    eyecenter(2,:) = mean(landmarks(43:48,:));

    input_points = eyecenter;       %change the name easy to understand
    tform = cp2tform(input_points, base_points_image,'nonreflective similarity');
    XData = [1 640];
    YData = [1 480];
        
    if bcropimage
        img_read = imread(fullfile(folder_image_raw,fn_raw));
        [img_aligned] = imtransform(img_read,tform,'XData',XData,'YData',YData);

        %crop the face region
        img_crop = img_aligned(top:bottom,left:right,:);
        fn_save = sprintf('%s.png',fn_short);
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
        fn_save = sprintf('%s_align_offset.mat',fn_image_short);
        save(fullfile(folder_landmark_save,fn_save),'landmarks_aligned_offset');
    end
end


%draw some images to confirm the correctness
%if bshownewlandmarks
%    for idx_file=1:num_files
%        fn_image = filelist(idx_file).name;
%        fn_image_short = fn_image(1:end-4);
%        fn_load = sprintf('%s_aligned.png',fn_image_short);
%        img_load = imread(fullfile(alignedimagefolder,fn_load));
%        imshow(img_load);
%        hold on
%        for j=1:68
%            plot(new_landmark_points_image(:,1,idx_file),new_landmark_points_image(:,2,idx_file),'r.','markersize',15);
%        end
%    end
%end 
    
%since the left eye coordinate is x:296.16 y:195.14 and the right eye coordinate is x:368.25 y:195.13
%the crop region I choose is r:35~354 c:212~451
%the size is 320*240 and the centroid is at the center of the two eyes
%if bcropimage
%    for idx_file=1:num_files
%        %load the landmark
%        fn_image = filelist(idx_file).name;
%        fn_image_short = fn_image(1:end-4);
%        fn_read = sprintf('%s_aligned.png',fn_image_short);
%        img_read = imread(fullfile(alignedimagefolder,fn_read));
%        img_crop = img_read(35:354,212:451,:);
%        fn_save = sprintf('%s_crop.png',fn_image_short);
%        imwrite(img_crop,fullfile(croppedimagefolder,fn_save));
%    end
%end
