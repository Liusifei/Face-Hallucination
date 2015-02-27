%Chih-Yuan Yang
%03/20/14 Convert the landmark format from intraface to multipie
% Landmarks of Multi-PIE: 68 points; 
% 1-17: cheeks and jaw, 
% 18-22: left eyebrow, 
% 23-27: right eyebrow, 
% 28-31: bridge of a nose, top to center
% 32-36: wing of a nose, left to right
% 37-42: left eye,
% 43-48: right eye, 
% 49-68 (20 pts): mouth, 49-55 (7 pts): upper bound of a upper lip, 56-61 (5 pts): lower bound of a lower lip, 
%                        61-65 (5 pts): lower bound of a upper lip, 66-68 (3 pts): upper bound of a lower lip
% Landmarks of IntraFace: 49 points;
% 1-5: left eyebrow, from left to right
% 6-10: right eyebrow, from left to right
% 11-14: bridge of a nose, top to center
% 15-19: wing of a nose, left to right
% 20-24: left eye, starts from 9 o’clock, clockwise
% 26-31: right eye, starts from 9 o’clock, clockwise
% 32-49 (18 pts): mouth, 32-38 (7pts): upper bound of a upper lip, 39-43 (5 pts): lower bound of a lower lip, 
%                        44-46 (3 pts): lower bound of a upper lip, 47-49 (3 pts): upper bound of a lower lip

function landmark_multipie = F1a_ConvertLandmark_Intraface_to_MultiPie(landmark_intraface)
    landmark_multipie = zeros(68,2);
    %left eyebrow
    landmark_multipie(18:22,:) = landmark_intraface(1:5,:);
    %right eyebrow
    landmark_multipie(23:27,:) = landmark_intraface(6:10,:);
    %bridge of a nose
    landmark_multipie(28:31,:) = landmark_intraface(11:14,:);
    %wing of a nose
    landmark_multipie(32:36,:) = landmark_intraface(15:19,:);
    %left eye
    landmark_multipie(37:42,:) = landmark_intraface(20:25,:);
    %right eye
    landmark_multipie(43:48,:) = landmark_intraface(26:31,:);
    %outer bounary of a mouth
    landmark_multipie(49:60,:) = landmark_intraface(32:43,:);
    %lower bound of a upper lip
    landmark_multipie(62:64,:) = landmark_intraface(44:46,:);
    %upper bound of a lower lip
    landmark_multipie(66:68,:) = landmark_intraface(47:49,:);
end