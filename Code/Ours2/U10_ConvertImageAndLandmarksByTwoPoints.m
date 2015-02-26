function [img_out landmarks_out] = U10_ConvertImageAndLandmarksByTwoPoints(img_in, landmarks_in, inputpoints, basepoints)
    %use tform to transform image
    [h w d] = size(img_in);
    tform = cp2tform(inputpoints, basepoints,'nonreflective similarity');
    %generated the transform images
    XData = [1 w];
    YData = [1 h];
    img_out = imtransform(img_in,tform,'XData',XData,'YData',YData);
    
    %tranform landmarks
    transformedlandmarks_cartesian = zeros(size(landmarks_in));
    inputpoints_cartesian = U5_ConvertImageCoorToCartesianCoor(inputpoints, [h w]);
    basepoints_cartesian = U5_ConvertImageCoorToCartesianCoor(basepoints, [h w]);
    landmarks_cartesian = U5_ConvertImageCoorToCartesianCoor(landmarks_in, [h w]);
    transformmatrix = U13_ComputeTransformMatrix(inputpoints_cartesian, basepoints_cartesian);       %the two coordinates are at image axis
    for j=1:size(landmarks_in,1)
        landmark_points_cartesian = landmarks_cartesian(j,:);
        input_data = [landmark_points_cartesian 1]';
        output_data = transformmatrix * input_data;
        transformedlandmarks_cartesian(j,:) = output_data(1:2)';
    end
    landmarks_out = U7_ConvertCartesianCoorToImageCoor(transformedlandmarks_cartesian, [h w]);  
end