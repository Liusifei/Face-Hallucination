%Chih-Yuan Yang
%11/09/12
%Separate from F27a
function SqrtData = F45_SimilarityEvaluation(Img_in)
    [h w] = size(Img_in);
    SqrtData = zeros(h,w,16);
    
    f3x3 = ones(3);
    for i = 1:16
        [DiffOp N] = IF2_RetGradientKernel16(i);
        if N == 1
            Diff = imfilter(Img_in,DiffOp{1},'symmetric');
        else
            Diff1 = imfilter(Img_in,DiffOp{1},'symmetric');
            Diff2 = imfilter(Img_in,DiffOp{2},'symmetric');
            Diff = (Diff1+Diff2)/2;
        end
        Sqr = Diff.^2;
        Sum = imfilter(Sqr,f3x3,'replicate');
        Mean = Sum/9;
        SqrtData(:,:,i) = sqrt(Mean);
    end
end
function [DiffOp N] = IF2_RetGradientKernel16(dir)
    DiffOp = cell(2,1);
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
    switch dir
        case 1
            N = 1;
            DiffOp{1} = f{1};
            DiffOp{2} = [];
        case 2
            N = 2;
            DiffOp{1} = f{1};
            DiffOp{2} = f{2};
        case 3
            N = 1;            
            DiffOp{1} = f{2};
            DiffOp{2} = [];
        case 4
            N = 2;
            DiffOp{1} = f{2};
            DiffOp{2} = f{3};
        case 5
            N = 1;
            DiffOp{1} = f{3};
            DiffOp{2} = [];
        case 6
            N = 2;
            DiffOp{1} = f{3};
            DiffOp{2} = f{4};
        case 7
            N = 1;
            DiffOp{1} = f{4};
            DiffOp{2} = [];
        case 8
            N = 2;
            DiffOp{1} = f{4};
            DiffOp{2} = f{5};
        case 9
            N = 1;
            DiffOp{1} = f{5};
            DiffOp{2} = [];
        case 10
            N = 2;
            DiffOp{1} = f{5};
            DiffOp{2} = f{6};
        case 11
            DiffOp{1} = f{6};
            DiffOp{2} = [];
            N = 1;
        case 12
            N = 2;
            DiffOp{1} = f{6};
            DiffOp{2} = f{7};
        case 13
            N = 1;
            DiffOp{1} = f{7};
            DiffOp{2} = [];
        case 14
            N = 2;
            DiffOp{1} = f{7};
            DiffOp{2} = f{8};
        case 15
            DiffOp{1} = f{8};
            DiffOp{2} = [];
            N = 1;
        case 16
            N = 2;
            DiffOp{1} = f{8};
            DiffOp{2} = f{1};
    end
end
function [Kernel N] = IF3_GetMoveKernel16(dir)
    Kernel = cell(2,1);
    f{1} = [0  0 0;
            0  0 1;
            0  0 0];
    f{2} = [0  0 1;
            0  0 0;
            0  0 0];
    f{3} = [0  1 0;
            0  0 0;
            0  0 0];
    f{4} = [1  0 0;
            0  0 0;
            0  0 0];
    f{5} = [0  0 0;
            1  0 0;
            0  0 0];
    f{6} = [0  0 0;
            0  0 0;
            1  0 0];
    f{7} = [0  0 0;
            0  0 0;
            0  1 0];
    f{8} = [0  0 0;
            0  0 0;
            0  0 1];
    switch dir
        case 1
            N = 1;
            Kernel{1} = f{1};
            Kernel{2} = [];
        case 2
            N = 2;
            Kernel{1} = f{1};
            Kernel{2} = f{2};
        case 3
            N = 1;            
            Kernel{1} = f{2};
            Kernel{2} = [];
        case 4
            N = 2;
            Kernel{1} = f{2};
            Kernel{2} = f{3};
        case 5
            N = 1;
            Kernel{1} = f{3};
            Kernel{2} = [];
        case 6
            N = 2;
            Kernel{1} = f{3};
            Kernel{2} = f{4};
        case 7
            N = 1;
            Kernel{1} = f{4};
            Kernel{2} = [];
        case 8
            N = 2;
            Kernel{1} = f{4};
            Kernel{2} = f{5};
        case 9
            N = 1;
            Kernel{1} = f{5};
            Kernel{2} = [];
        case 10
            N = 2;
            Kernel{1} = f{5};
            Kernel{2} = f{6};
        case 11
            Kernel{1} = f{6};
            Kernel{2} = [];
            N = 1;
        case 12
            N = 2;
            Kernel{1} = f{6};
            Kernel{2} = f{7};
        case 13
            N = 1;
            Kernel{1} = f{7};
            Kernel{2} = [];
        case 14
            N = 2;
            Kernel{1} = f{7};
            Kernel{2} = f{8};
        case 15
            Kernel{1} = f{8};
            Kernel{2} = [];
            N = 1;
        case 16
            N = 2;
            Kernel{1} = f{8};
            Kernel{2} = f{1};
    end
end
