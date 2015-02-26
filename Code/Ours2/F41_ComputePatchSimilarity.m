%Chih-Yuan Yang
%10/12/12
%For nnmex() in terms of discriptor mode
function l2norm = F41_ComputePatchSimilarity(A,B,xy)
    [h w d] = size(A);
    retrieveddescriptor = zeros(h,w,d);
    for r=1:h
        for c=1:w
            x = xy(r,c,1);
            y = xy(r,c,2);
            r_source = y+1;
            c_source = x+1;
            retrieveddescriptor(r,c,:) = B(r_source,c_source,:);
        end
    end
    diff = A-retrieveddescriptor;
    l2norm = sqrt(sum(diff.^2,3));
end
