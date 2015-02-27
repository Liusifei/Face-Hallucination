%Chih-Yuan Yang
%10/05/12
%Extract features from an image
function FeatureMatrix = F38_ExtractFeatureFromAnImage(img)
    %Extract the feature of A
    [h_lr, w_lr] = size(img);
    img_ext = zeros(h_lr+4,w_lr+4);
    img_ext(3:end-2,3:end-2) = img;
    img_ext(1:2,:) = repmat(img_ext(3,:),[2,1]);
    img_ext(end-1:end,:) = repmat(img_ext(end-2,:),[2,1]);
    img_ext(:,1:2) = repmat(img_ext(:,3),[1,2]);
    img_ext(:,end-1:end) = repmat(img_ext(:,end-2),[1,2]);
    FeatureMatrix = zeros(h_lr,w_lr,25);
    for cl=1:w_lr
        cl1 = cl+4;
        for rl=1:h_lr
            rl1 = rl+4;
            FeatureMatrix(rl,cl,:) = reshape(img_ext(rl:rl1,cl:cl1),[1 1 25]);
        end
    end

end