%Chih-Yuan Yang
%10/03/12
%for wild face
function landmark_shift = F36_ShiftLandmark(landmark,coorshiftx,coorshifty)
    landmark_shift = zeros(68,2);
    landmark_shift(:,1) = landmark(:,1) - coorshiftx;
    landmark_shift(:,2) = landmark(:,2) - coorshifty;    
end
