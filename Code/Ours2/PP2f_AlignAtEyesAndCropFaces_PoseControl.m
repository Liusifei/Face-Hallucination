%Chih-Yuan Yang
%09/08/13
%PP2b: for wild, the format of landmark has to change because there is no hand-made landmarks
%PP2d: similar to PP2b, but use a filelist, a file of eye center
%PP2e: only crop the ones with poses as 0. neglect all other poses.
%PP2f: My goal should be to generate the LR image for upsampling. In 
%the previous PP2, the HR ground truth images are available, but for JANUS
%the HR ground truth are unavailabe. So I have to crop the raw image, and
%downsize them to the LR images. Thus, the scaling factor for each image
%has to be computed by the detected landmarks in the x4 image.
%already.  Si
clear
%load image
%setting JANUS
folder_eyecenter = 'LocationOfTwoEyesForAlignment';
fn_eyecenter = 'Upfrontal.mat';
folder_image_raw = fullfile('Source','JANUSProposal','Raw');
str_ext_raw = '.jpg';
folder_filelist = 'FileList';
fn_filelist = 'JANUSSelected.txt';
str_ext_filelist = '.jpg';
folder_landmark_detected = fullfile('Landmarks','Detected','JANUSProposal_x4');
folder_image_save_cropped = fullfile('Source','JANUSProposal','input');
folder_landmark_save = fullfile('Landmarks','Detected','JANUS_Aligned');
idx_start = 1;
idx_end = 'all';

U22_makeifnotexist(folder_landmark_save);
U22_makeifnotexist(folder_image_save_cropped);
arr_filelist = U5d_ReadFileNameList_Index_Comment(fullfile(folder_filelist,fn_filelist));
num_files = length(arr_filelist);

%the eyecenter is respect to a 640x480 image
%I may need to change it. wait.
loaddata = load(fullfile(folder_eyecenter,fn_eyecenter));
lefteye = loaddata.lefteye;
righteye = loaddata.righteye;
base_points_image = zeros(2,2);                   %base_points_image are the aligned points
%this is another change, the new base_point_image will be much narrower
lefteye_LR.x = lefteye.x / 4;
lefteye_LR.y = lefteye.y / 4;
righteye_LR.x = righteye.x / 4;
righteye_LR.y = righteye.y / 4;
base_points_image(1,:) = [lefteye_LR.x lefteye_LR.y];
base_points_image(2,:) = [righteye_LR.x righteye_LR.y];
eyecenter_LR.x = (lefteye_LR.x + righteye_LR.x)/2;
eyecenter_LR.y = (lefteye_LR.y + righteye_LR.y)/2;

%this is anther change. If we want a LR face, the size here is 80*60
% left = round(eyecenter.x)-120;
% right = round(eyecenter.x)+119;
% top = round(eyecenter.y)-160;
% bottom = round(eyecenter.y)+159;
left = round(eyecenter_LR.x)-30;
right = round(eyecenter_LR.x)+29;
top = round(eyecenter_LR.y)-40;
bottom = round(eyecenter_LR.y)+39;

%this needs to change, too, the new expected image size is not [480,640]
%try [120,160];
%eyecenter_mean_cartisian = F42_ConvertImageCoorToCartesianCoor( base_points_image, [480,640]);
eyecenter_mean_cartisian = F42_ConvertImageCoorToCartesianCoor( base_points_image, [120,160]);

clear eyecenter   %the old eyecenter
if isa(idx_end,'char')
    if strcmp(idx_end,'all')
        idx_end = num_files;
    end
end
num_char_filelist_ext = length(str_ext_filelist);
for idx_file = idx_start:idx_end
    fn_read = arr_filelist{idx_file};
    fn_short = fn_read(1:end-num_char_filelist_ext);     %in this case, there is no extension in the filelist
    fn_landmark_detected = [fn_short '_mi.mat'];       %this is detected landmarks
    loaddata = load(fullfile(folder_landmark_detected,fn_landmark_detected));
    %there may be multiple faces in a file. See how many bs are.
    num_face = length(loaddata.bs);
    %read image
    fn_image = sprintf('%s%s',fn_short,str_ext_raw);
    img_raw = imread(fullfile(folder_image_raw,fn_image));
%     fn_save = sprintf('%s.png',fn_short);
%     imwrite(img_raw,fullfile(folder_image_save_raw,fn_save));
    
    for idx_face = 1:num_face
        %the landmarks are of the x4 image
        landmarks_detected = loaddata.bs(idx_face);
        %prevent the non-upfrontal faces, they do not match upfrontal examples
        pose = loaddata.posemap(loaddata.bs(idx_face).c);
        if pose ~= 0
            continue
        end
        landmarks = F4_ConvertBStoMultiPieLandmarks(landmarks_detected);
        %to handle the x4 landmarks, here the landmarks has to be divdied
        %by 4
        eyecenter(1,:) = mean(landmarks(37:42,:)) /4;
        eyecenter(2,:) = mean(landmarks(43:48,:)) /4;
        input_points = eyecenter;       %change the name easy to understand
        tform = cp2tform(input_points, base_points_image,'nonreflective similarity');
%        [h_raw, w_raw, d_raw] = size(img_raw);
        %the XData and YData is the resolution of the generated image
        %change here, try 160,120
%         XData = [1 640];     %maybe this is the problem, the MultiPIE raw is 640x480, but PubFig and JANUS are not
%         YData = [1 480];
        XData = [1 160];     %maybe this is the problem, the MultiPIE raw is 640x480, but PubFig and JANUS are not
        YData = [1 120];
        
        
        %bcropimage
        img_aligned = imtransform(img_raw,tform,'XData',XData,'YData',YData,'XYScale',1);
        %I found the problem, the generated img_aligned is smaller than
        %640x480, so that the cropped images are misaligned
        %I don't know why it happens. How to solve it?
        %when an option ['XYScale', 1] is added, the img_aligned will be
        %large enough
        
        %crop the face region
%         if top < 1 || left < 1 || bottom > h || right > w
%             continue
%         end
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
