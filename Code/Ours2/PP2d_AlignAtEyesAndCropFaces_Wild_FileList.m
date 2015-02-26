%Chih-Yuan Yang
%08/25/13
%PP2b: for wild, the format of landmark has to change because there is no hand-made landmarks
%PP2d: similar to PP2b, but use a filelist, a file of eye center
clear
%load image
folder_eyecenter = 'LocationOfTwoEyesForAlignment';
fn_eyecenter = 'Upfrontal.mat';
folder_image_raw = 'D:\Documents\Research\Datasets\Face\PubFig\FullImage';
str_ext_raw = '.jpg';
folder_landmark_raw = fullfile('Landmarks','Detected','PubFig_Readable');
folder_filelist = 'FileList';
fn_filelist = 'PubFig_Foundable_7115.txt';
folder_landmark_detected = fullfile('Landmarks','Detected','PubFig_Readable');
folder_image_save_cropped = fullfile('Source','PubFig2_2Foundable','GroundTruth');
folder_image_save_raw = fullfile('Source','PubFig2_2Foundable','Raw');        %for debugging
folder_landmark_save = fullfile('Landmarks','Detected','PubFig_Aligned');
idx_start = 1;
idx_end = 'all';


U22_makeifnotexist(folder_landmark_save);
U22_makeifnotexist(folder_image_save_cropped);
U22_makeifnotexist(folder_image_save_raw);
arr_filelist = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_files = length(arr_filelist);

%load the location of the two eyes
loaddata = load(fullfile(folder_eyecenter,fn_eyecenter));
lefteye = loaddata.lefteye;
righteye = loaddata.righteye;
base_points_image = zeros(2,2);                   %base_points_image are the aligned points
base_points_image(1,:) = [lefteye.x lefteye.y];
base_points_image(2,:) = [righteye.x righteye.y];
eyecenter.x = (lefteye.x + righteye.x)/2;
eyecenter.y = (lefteye.y + righteye.y)/2;

left = round(eyecenter.x)-120;
right = round(eyecenter.x)+119;
top = round(eyecenter.y)-160;
bottom = round(eyecenter.y)+159;

eyecenter_mean_cartisian = F42_ConvertImageCoorToCartesianCoor( base_points_image, [480,640]);

clear eyecenter   %the old eyecenter
if isa(idx_end,'char')
    if strcmp(idx_end,'all')
        idx_end = num_files;
    end
end
for idx_file = idx_start:idx_end
    fn_read = arr_filelist{idx_file};
    fn_short = fn_read(1:end-7);     %in this case, there is no extension in the filelist
    fn_landmark_detected = [fn_short '_mi.mat'];       %this is detected landmarks
    loaddata = load(fullfile(folder_landmark_detected,fn_landmark_detected));
    %there may be multiple faces in a file. See how many bs are.
    num_face = length(loaddata.bs);
    %read image
    fn_image = sprintf('%s%s',fn_short,str_ext_raw);
    img_raw = imread(fullfile(folder_image_raw,fn_image));
    fn_save = sprintf('%s.png',fn_short);
    imwrite(img_raw,fullfile(folder_image_save_raw,fn_save));
    
    for idx_face = 1:num_face
        landmarks_detected = loaddata.bs(idx_face);
        %prevent the non-upfrontal faces, they do not match upfrontal examples
        pose = loaddata.posemap(loaddata.bs(idx_face).c);
        if pose ~= 0
            continue
        end
        landmarks = F4_ConvertBStoMultiPieLandmarks(landmarks_detected);
        eyecenter(1,:) = mean(landmarks(37:42,:));
        eyecenter(2,:) = mean(landmarks(43:48,:));
        input_points = eyecenter;       %change the name easy to understand
        tform = cp2tform(input_points, base_points_image,'nonreflective similarity');
        XData = [1 640];
        YData = [1 480];
        
        %bcropimage
        [img_aligned] = imtransform(img_raw,tform,'XData',XData,'YData',YData);

        %crop the face region
        img_crop = img_aligned(top:bottom,left:right,:);
        if num_face > 1
            fn_save = sprintf('%s_%d.png',fn_short,idx_face);
        else
            fn_save = sprintf('%s.png',fn_short);
        end
        imwrite(img_crop,fullfile(folder_image_save_cropped,fn_save));
            
        %align landmark coordinate
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
        pts = landmarks_aligned_offset;
        if num_face > 1
            fn_save = sprintf('%s_%d_lm.mat',fn_short,idx_face);
        else
            fn_save = sprintf('%s_lm.mat',fn_short);
        end
        save(fullfile(folder_landmark_save,fn_save),'pts');
    end
end
