%09/29/12
%Chih-Yuan Yang
%This file has to be executed on Linux
function [bs posemap]= F2_ReturnLandmarks(im, modelname)

    % load and visualize model
    % Pre-trained model with 146 parts. Works best for faces larger than 80*80
    %load face_p146_small.mat

    % % Pre-trained model with 99 parts. Works best for faces larger than 150*150
    % load face_p99.mat

    % % Pre-trained model with 1050 parts. Give best performance on localization, but very slow
    % load multipie_independent.mat
     
    switch modelname
        case 'p146'
            load face_p146_small.mat
        case 'p99'
            load face_p99.mat
        case 'mi'
            load multipie_independent.mat
        otherwise
            error('no such a model');
    end

    % 5 levels for each octave
    model.interval = 5;
    % set up the threshold
    model.thresh = min(-0.65, model.thresh);

    % define the mapping from view-specific mixture id to viewpoint
    if length(model.components)==13 
        posemap = 90:-15:-90;
    elseif length(model.components)==18
        posemap = [90:-15:15 0 0 0 0 0 0 -15:-15:-90];
    else
        error('Can not recognize this model');
    end

    bs = detect(im, model, model.thresh);           %this function only can be executed on Linux
    bs = clipboxes(im, bs);     %this function removes the boxes exceeding the boundary
    bs = nms_face(bs,0.3);      %non-maximum suppression
end