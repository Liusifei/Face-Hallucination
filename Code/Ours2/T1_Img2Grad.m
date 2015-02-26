function Grad = T1_Img2Grad(img)
    [h w] = size(img);
    Grad = zeros(h,w,8);
    DiffOp = RetGradientKernel();
    for i=1:8
        Grad(:,:,i) = imfilter(img,DiffOp{i},'replicate');
    end
end
function f = RetGradientKernel()
    f = cell(8,1);
    f{1} = [0  0 0;
            0 -1 1;
            0  0 0];
    f{2} = [0  0 1;
            0 -1 0;
            0  0 0];
    f{3} = [0  1 0;
            0 -1 0;
            0  0 0];
    f{4} = [1  0 0;
            0 -1 0;
            0  0 0];
    f{5} = [0  0 0;
            1 -1 0;
            0  0 0];
    f{6} = [0  0 0;
            0 -1 0;
            1  0 0];
    f{7} = [0  0 0;
            0 -1 0;
            0  1 0];
    f{8} = [0  0 0;
            0 -1 0;
            0  0 1];
end