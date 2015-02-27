%Chih-Yuan Yang
%10/27/12
%Seperate this function from F21, because this function is required in training phase
%F27a: save similarity_lr and similarity_hr to draw figures required for the paper
function img_out = F27a_SmoothnessPreserving(img_y,zooming,Gau_sigma)
    img_bb = imresize(img_y,zooming);

    %compute the similarity from low
    Coef = 10;
    PatchSize = 3;
    Sqrt_low = IF1_SimilarityEvaluation(img_y);           %I may need more directions, 16 may be too small
    Similarity_low = exp(-Sqrt_low*Coef);
    [h_high w_high] = size(img_bb);
    ExpectedSimilarity = zeros(h_high,w_high,16);
    %upsamplin the similarity
    for dir=1:16
        ExpectedSimilarity(:,:,dir) = imresize(Similarity_low(:,:,dir),zooming,'bilinear');
    end

    folder_project = fileparts(fileparts(pwd));
    folder_save = fullfile(folder_project,'PaperWriting','CVPR13','manuscript','figs','Illustration','SmoothnessPreservingUpsampling');
    for i=1:16
        fn_save = sprintf('Similarity_lr_%d.png',i);
        hfig = figure;
        imagesc(Similarity_low(:,:,i));
        caxis([0,1]);
        axis off image
        saveas(hfig,fullfile(folder_save,fn_save));
        close
        
        fn_save = sprintf('Similarity_hr_%d.png',i);
        hfig = figure;
        imagesc(ExpectedSimilarity(:,:,i));
        caxis([0,1]);
        axis off image
        saveas(hfig,fullfile(folder_save,fn_save));
        close        
    end
    %refind the Grad_high by Similarity_high
    LoopNumber = 10;
    img = img_bb;
    for loop = 1:LoopNumber
        %refine gradient by ExpectedSimilarity
        ValueSum = zeros(h_high,w_high);
        WeightSum = sum(ExpectedSimilarity,3);      %if thw weight sum is low, it is unsuitable to generate the grad by interpolation
        for dir = 1:16
            [MoveOp N] = IF3_GetMoveKernel16(dir);
            if N == 1
                MovedData = imfilter(img,MoveOp{1},'replicate');
            else  %N ==2
                MovedData1 = imfilter(img,MoveOp{1},'replicate');
                MovedData2 = imfilter(img,MoveOp{2},'replicate');
                MovedData = (MovedData1 + MovedData2)/2;
            end
            Product = MovedData .* ExpectedSimilarity(:,:,dir);
            ValueSum = ValueSum + Product;
        end
        I = ValueSum ./ WeightSum;
        
        %intensity compensate
        diff_lr = F19c_GenerateLRImage_GaussianKernel(I,zooming,Gau_sigma) - img_y;
        diff_hr = F26_UpsampleAndBlur(diff_lr,zooming,Gau_sigma);
        Grad0 = diff_hr;
        Term_LowHigh_in = F28_ComputeSquareSumLowHighDiff(I,img_y,Gau_sigma);
        I_in = I;       %make a copy, restore the value if all beta fails
        bDecrease = false;
        %should I use the strict constraint?
        tau = 0.2;
        for line_search_loop=1:10
            %line search for the beta, fixed 1/32 is not a good choice
            I = I_in - tau * Grad0;
            Term_LowHigh_out = F28_ComputeSquareSumLowHighDiff(I,img_y,Gau_sigma);
            if Term_LowHigh_out < Term_LowHigh_in
                bDecrease = true;
                break;
            else
                tau = tau * 0.5;
            end
        end
        
        if bDecrease == true
            I_best = I;
        else
            break;
        end
        img = I_best;
    end
    img_out = img;
end
function SqrtData = IF1_SimilarityEvaluation(Img_in,PatchSize)
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
