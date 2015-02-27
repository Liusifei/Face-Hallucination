%Chih-Yuan Yang
%10/02/12
%add class control
function Grad = F14_Img2Grad(img)
    if ~isa(img,'double')
        img = im2double(img);
        warning('input type is not double.');
    end
    [h w] = size(img);
    Grad = zeros(h,w,8);
    DiffOp = IF1_RetGradientKernel();
    for i=1:8
        Grad(:,:,i) = imfilter(img,DiffOp{i},'replicate');
    end
end

function f = IF1_RetGradientKernel()
    f = cell(8,1);
    f{1} = [0 -1 1];
    f{2} = [0  0 1;
            0 -1 0;
            0  0 0];
    f{3} = [ 1;
            -1;
             0];
    f{4} = [1  0 0;
            0 -1 0;
            0  0 0];
    f{5} = [1 -1 0];
    f{6} = [0  0 0;
            0 -1 0;
            1  0 0];
    f{7} = [ 0;
            -1;
             1];
    f{8} = [0  0 0;
            0 -1 0;
            0  0 1];
end
