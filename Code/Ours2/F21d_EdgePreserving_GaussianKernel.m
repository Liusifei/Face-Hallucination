%Chih-Yuan Yang
%10/02/12
%F21b: Based on F21a, but change the square kernel to Gaussian, to see whether the square pattern disappear
%F21c: remove the para argument
%F21d: try to use large beta0 and small beta1 to see whether it can save the computational time
function [gradient_expected gradient_actual weightmap_edge img_edge] = F21d_EdgePreserving_GaussianKernel(img_y,zooming,Gau_sigma)
    LowMagSuppression = 0;      %the three parameters should be adjusted later
    DistanceUpperBound = 2.0;
    ContrastEnhenceCoef = 1.0;
    I_s = F27_SmoothnessPreserving(img_y,zooming,Gau_sigma);
    T = F15_ComputeSRSSD(I_s);
    Dissimilarity = EvaluateDissimilarity8(I_s);
    Grad_high_initial = Img2Grad(I_s);
    
    [h w] = size(T);
    StatisticsFolder = fullfile('EdgePriors');
    LoadFileName = sprintf('Statistics_Sc%d_Si%0.1f.mat',zooming,Gau_sigma);
    LoadData = load(fullfile(StatisticsFolder,LoadFileName));
    Statistics = LoadData.Statistics;
    
    RidgeMap = edge(I_s,'canny',[0 0.01],0.05);

    %filter out small ridge and non-maximun ridges
    RidgeMap_filtered = RidgeMap;
    [r_set c_set] = find(RidgeMap);
    SetLength = length(r_set);
    for j=1:SetLength
        r = r_set(j);
        c = c_set(j);
        CenterMagValue = T(r,c);
        if CenterMagValue < LowMagSuppression
            RidgeMap_filtered(r,c) = false;
        end
    end
    

    [r_set c_set] = find(RidgeMap_filtered);
    SetLength = length(r_set);
    [X Y] = meshgrid(1:11,1:11);
    DistPatch = sqrt((X-6).^2 + (Y-6).^2);

    DistMap = inf(h,w);    
    UsedPixel = false(h,w);    
    CenterCoor = zeros(h,w,2);    
    %Compute DistMap and CneterCoor
    [r_set c_set] = find(RidgeMap_filtered);
    for j=1:SetLength
        r = r_set(j);
        r1 = r-5;
        r2 = r+5;
        c = c_set(j);
        c1 = c-5;
        c2 = c+5;
        if r1>=1 && r2<=h && c1>=1 && c2<=w    %discrad boundary?
            MapPatch = DistMap(r1:r2,c1:c2);
            MinPatch = min(MapPatch, DistPatch);
            DistMap(r1:r2,c1:c2) = MinPatch;
            UsedPixel(r1:r2,c1:c2) = true;
            ChangedPixels = MinPatch < MapPatch;
            OriginalCenterCoorPatch = CenterCoor(r1:r2,c1:c2,:);
            NewCoor = cat(3,r*ones(11), c*ones(11));
            NewCenterCoorPatch = OriginalCenterCoorPatch .* repmat(1-ChangedPixels,[1,1,2]) + NewCoor .* repmat(ChangedPixels,[1,1,2]);
            CenterCoor(r1:r2,c1:c2,:) = NewCenterCoorPatch;
        end
    end

    %Convert dist to table index
    TableIndexMap = zeros(h,w);
    b = unique(DistPatch(:));
    for i=1:length(b)
        SetPixels = DistMap == b(i);
        TableIndexMap(SetPixels) = i;
    end

    
    %mapping (T_p, T_r, d) to S_p
    [r_set c_set] = find(UsedPixel);
    SetLength = length(r_set);
    UpdatedPixel = false(h,w);
    S = zeros(h,w);
    for i=1:SetLength
        r = r_set(i);
        c = c_set(i);
        r_Center = CenterCoor(r,c,1);
        c_Center = CenterCoor(r,c,2);
        CurrentMagValue = T(r,c);
        BinIdx_Current = ceil(CurrentMagValue /0.005);
        %Zebra have super strong Mag
        if BinIdx_Current > 100
            BinIdx_Current = 100;
        end
        TableIndex = TableIndexMap(r,c);
        if TableIndex > DistanceUpperBound
            continue
        end
        CenterMagValue = T(r_Center,c_Center);
        %Low Mag Edge suppresion
        if CenterMagValue < LowMagSuppression
            continue
        end
        BinIdx_Center = ceil(CenterMagValue /0.005);
        if BinIdx_Center > 100
            BinIdx_Center = 100;
        end
        %consult the table
        if TableIndex == 1      %1 is the index of b(1) where dist = 0, enhance the contrast of pixel on edge 
            S_p = ContrastEnhenceCoef * Statistics(TableIndex).EstimatedMag(BinIdx_Current,BinIdx_Center);
        else
            S_p = Statistics(TableIndex).EstimatedMag(BinIdx_Current,BinIdx_Center);
        end
        
        if isnan(S_p)
        else
            UpdatedPixel(r,c) = true;
            S(r,c) = S_p;
        end
    end

    %Record the RidgeMapMap, for computing te ProbOfMag
    %the Mag is the consulted Mag
    %here is the problem, when the S is very strong, the affect range of ProbMagOut exceeds 1 pixel
    RidgeMapMagValue = zeros(h,w);
    for i=1:SetLength
        r = r_set(i);
        c = c_set(i);
        r_Center = CenterCoor(r,c,1);
        c_Center = CenterCoor(r,c,2);
        RidgeMapMagValue(r,c) = S(r_Center,c_Center);
    end    
    
    S(~UpdatedPixel) = T(~UpdatedPixel);
    img_in = I_s;
    if min(Dissimilarity(:)) == 0
        d = Dissimilarity + 1e-6;      %avoid 0 case; some images may have d(:,:,1) as 0
    else
        d = Dissimilarity;
    end
    ratio = d ./ repmat(d(:,:,1),[1,1,8]);
    %here is the problem, I need to amplify the gradient directionally   
    Grad_in = Img2Grad(img_in);
    Product = Grad_in .* ratio;
    Sqr = Product.^2;
    Sum = sum(Sqr,3);
    Sqrt = sqrt(Sum);       %the Sqrt might be 0, because Grad_in may be pure 0;
    r1 = S ./Sqrt;
    r1(isnan(r1)) = 0;

    Grad_exp = Grad_high_initial .*( ratio .*(repmat(r1,[1,1,8])));
    %consolidate inconsistatnt gradient
    NewGrad_exp = zeros(h,w,8);
    for k=1:4
        switch k
            case 1
                ShiftOp = [0 -1];
            case 2
                ShiftOp = [1 -1];
            case 3
                ShiftOp = [1 0];
            case 4
                ShiftOp = [1 1];
        end
        k2 =k+4;
        Grad1 = Grad_exp(:,:,k);
        Grad2 = Grad_exp(:,:,k2);
        Grad2Shift = circshift(Grad2,ShiftOp);
        Grad1Abs = abs(Grad1);
        Grad2AbsShift = abs(Grad2Shift);
        Grad1Larger = Grad1Abs > Grad2AbsShift;
        Grad2Larger = Grad2AbsShift > Grad1Abs;
        NewGrad1 = Grad1 .* Grad1Larger + (-Grad2Shift) .* Grad2Larger;
        NewGrad2Shift = Grad2Shift .* Grad2Larger + (-Grad1) .* Grad1Larger;
        NewGrad2 = circshift(NewGrad2Shift,-ShiftOp);
        NewGrad_exp(:,:,k) = NewGrad1;
        NewGrad_exp(:,:,k2) = NewGrad2;
    end
    %current problem is the over-enhanced gradient (NewMagExp too large)
    gradient_expected = NewGrad_exp;
    
    bReport = true;
    updatenumber = 0;
    loopnumber = 1000;
    linesearchstepnumber = 10;
    beta0 = 1;
    beta1 = 0.5^8;
    tolf = 0.001;
    img_edge = F4d_GenerateIntensityFromGradient(img_y,img_in,NewGrad_exp,Gau_sigma,bReport,...
        loopnumber,updatenumber,linesearchstepnumber,beta0,beta1,tolf);
    %img_edge = F4b_GenerateIntensityFromGradient(img_y,img_in,NewGrad_exp,Gau_sigma,bReport);
    gradient_actual = Img2Grad(img_edge);
    %compute the Map of edge weight
    lambda_m = 2;
    m0 = 0;
    ProbMagOut = lambda_m * RidgeMapMagValue + m0;

    lambda_d = 0.25;
    d0 = 0.25;
    ProbDistMap = exp(- (lambda_d * DistMap + d0) );      %this coef should be decied by zooming
    
    Product = ProbMagOut .* ProbDistMap;
    weightmap_edge = min(Product,1);         %the two terms are not sufficient, direction is not taken into considertion
end
function Grad = Img2Grad(img)
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
function Dissimilarity = EvaluateDissimilarity8(Img_in,PatchSize)
    if ~exist('PatchSize','var');
        PatchSize = 3;
    end
    [h w] = size(Img_in);
    Dissimilarity = zeros(h,w,8);
    
    f3x3 = ones(PatchSize)/(PatchSize^2);
    for i = 1:8
        DiffOp = RetGradientKernel8(i);
        Diff = imfilter(Img_in,DiffOp,'symmetric');
        Sqr = Diff.^2;
        Sum = imfilter(Sqr,f3x3,'replicate');
        Dissimilarity(:,:,i) = sqrt(Sum);
    end
end
function DiffOp = RetGradientKernel8(dir)
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
    DiffOp = f{dir};
end
function f = ComputeFunctionValue_Grad(img, Grad_exp)
    Grad = Img2Grad(img);
    Diff = Grad - Grad_exp;
    Sqrt = Diff .^2;
    f = sqrt(sum(Sqrt(:)));
end
