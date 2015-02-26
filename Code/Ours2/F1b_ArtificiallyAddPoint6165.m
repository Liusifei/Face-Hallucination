%Chih-Yuan Yang
%03/21/14
%I solve the problem of unavailable points of IntraFace outputs by copying two nearest points.
function landmark_out = F1b_ArtificiallyAddPoint6165(landmark_in)
    landmark_out = landmark_in;
    landmark_out(61,:) = landmark_in(49,:);
    landmark_out(65,:) = landmark_in(55,:);
end

