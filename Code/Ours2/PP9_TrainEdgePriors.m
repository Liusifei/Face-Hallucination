%10/11/12
%Chih-Yuan Yang
%Import from ACCV12 to solve the background and hair problem
%update some function names (ComputeMag-->ComputeSRSSD, BicubicReplacor-->SmoothnessPreservingFunction)
%find a bug of missing a line idxstart = idxend+1;
function PP9_TrainEdgePriors()
    Setting(1).Gau_sigma = 1.2;
    Setting(1).Zooming = 3;
%    Setting(2).Gau_sigma = 1.6;
%    Setting(2).Zooming = 4;
    Para.SaveFolder = 'EdgePriors';
    Para.TrainingImageFolder = fullfile('Examples','Upfrontal','Training');       %color images
    
    if ~exist(Para.SaveFolder,'dir')
        mkdir(Para.SaveFolder);
    end    
    for i=1:length(Setting)
        Para.Zooming = Setting(i).Zooming;
        Para.Gau_sigma = Setting(i).Gau_sigma;
        Para.RawDataFileName = fullfile(Para.SaveFolder,sprintf('RawData_Sc%d_Si%0.1f.mat',Para.Zooming,Para.Gau_sigma));
        Para.StatisticsFileName = fullfile(Para.SaveFolder,sprintf('Statistics_Sc%d_Si%0.1f.mat',Para.Zooming,Para.Gau_sigma));
        %Extract features
        %ExtractOneSetting(Para);        
        
        %ComputeStatisticsOneSetting(Para);
        DrawOneSetting(Para);
    end
end

%Extract features
function ExtractOneSetting(Para)
    Zooming = Para.Zooming;
    TrainingImageFolder = Para.TrainingImageFolder;
    %FileList = dir(fullfile(TrainingImageFolder,'*.jpg'));
    FileList = dir(fullfile(TrainingImageFolder,'*.png'));
    ListLength = length(FileList);
    preallocatenumber = 120000;   

    for i=1:ListLength
        fprintf('collecting statistics %d out of totoal %d files\n',i,ListLength);
        fn_read = FileList(i).name;
        fn_short = fn_read(1:end-4);
        img_rgb = im2double(imread(fullfile(Para.TrainingImageFolder ,fn_read)));
        img_y_high = rgb2gray(img_rgb);
        [h w] = size(img_y_high);
        img_y_low = F19a_GenerateLRImage_GaussianKernel(img_y_high,Zooming,Para.Gau_sigma);

        MagOriginal = F15_ComputeSRSSD(img_y_high);
        if nnz(isnan(MagOriginal)) > 0
            keyboard
        end

        imgReconstruct = F27_SmoothnessPreserving(img_y_low,Para.Zooming,Para.Gau_sigma);
        %insert code, remove the fake edges

        MagReconstruct = F15_ComputeSRSSD(imgReconstruct);
        %find edge
        %the function has not fully implemented yet
%        EdgeCenter = NonMaximaSuppresion(MagReconstruct);
        EdgeCenter = edge(imgReconstruct,'canny',[0 0.01],0.05);       %here is the problem, how to label non-maxinum depression
        DistMap = inf(h,w);
        UsedPixel = false(h,w);
        CenterCoor = zeros(h,w,2);
        [X Y] = meshgrid(1:7,1:7);
        SX = X -4;
        SY = Y -4;
        DistPatch = sqrt(SX.^2 + SY.^2);
        [r_set c_set] = find(EdgeCenter);
        SetLength = length(r_set);
        %create distmap
        for j=1:SetLength
            r = r_set(j);
            r1 = r-3;
            r2 = r+3;
            c = c_set(j);
            c1 = c-3;
            c2 = c+3;
            if r1>=1 && r2<=h && c1>=1 && c2<=w
                MapPatch = DistMap(r1:r2,c1:c2);
                MinPatch = min(MapPatch, DistPatch);
                DistMap(r1:r2,c1:c2) = MinPatch;
                UsedPixel(r1:r2,c1:c2) = true;
                ChangedPixels = MinPatch < MapPatch;
                OriginalCenterCoorPatch = CenterCoor(r1:r2,c1:c2,:);
                NewCoor = cat(3,r*ones(7), c*ones(7));
                NewCenterCoorPatch = OriginalCenterCoorPatch .* repmat(1-ChangedPixels,[1,1,2]) + NewCoor .* repmat(ChangedPixels,[1,1,2]);
                CenterCoor(r1:r2,c1:c2,:) = NewCenterCoorPatch;
            end
        end

        %collect statistics data
        [r_set c_set] = find(UsedPixel);
        SetLength = length(r_set);
        Count = 0;
        samples = zeros(4,preallocatenumber);   %ReconMag, Dist, OriginalMag, CenterMag
        for j=1:SetLength
            r = r_set(j);
            c = c_set(j);
            Count = Count + 1;
            samples(1,Count) = MagReconstruct(r,c);           %T_p
            samples(2,Count) = DistMap(r,c);                  %d
            samples(3,Count) = MagOriginal(r,c);              %S_p
            Center_r = CenterCoor(r,c,1);
            Center_c = CenterCoor(r,c,2);
            samples(4,Count) = MagReconstruct(Center_r,Center_c);     %T_r
        end
        %save indivisual extracted feature
        samples = samples(:,1:Count);
        savename = sprintf('%s_samples.mat',fn_short);
        samplesavefolder = fullfile(Para.SaveFolder, 'Samples', sprintf('s%d',Para.Zooming));
        if ~exist(samplesavefolder,'dir')
            mkdir(samplesavefolder);
        end
        save(fullfile(samplesavefolder,savename),'samples');
    end
end

function ComputeStatisticsOneSetting(Para)
%All samples are saved in EdgePriors\Samples\s3 or EdgePriors\Samples\s4
%Combine all smaple files to compute statistics
    
    %load all samples
    samplesavefolder = fullfile(Para.SaveFolder, 'Samples', sprintf('s%d',Para.Zooming));
    filelist = dir(fullfile(samplesavefolder,'*_samples.mat'));
    listlength = length(filelist);
    inlist = zeros(listlength,1);       %instance number list
    %compute the total sample number
    for i=1:listlength
        fn = filelist(i).name;
        ffn = fullfile(samplesavefolder, fn);
        info = whos('-file',ffn);        
        for j=1:length(info)
            if strcmp(info(j).name , 'samples');
                inlist(i) = info(j).size(2);
            end
        end
    end
    intotal = sum(inlist); %maximun case

    %merge all files 
    b = [0 1 sqrt(2) 2 sqrt(5) 2*sqrt(2) 3 sqrt(10) sqrt(13) sqrt(18)];     
    %the last one has to be sqrt(18) rather than 3*sqrt(2), otherwise "matchedidx = samples(2,:) == dist" fails due to precision
    DistLength = length(b);

    BinNumber = 100;
    BinMax = 0.5;
    BinMin = 0;
    BinInterval = (BinMax-BinMin)/BinNumber;
    BinCenter = BinMin+BinInterval/2:BinInterval:BinMax-BinInterval/2;
    Statistics(1:DistLength,1) = struct('EstimatedMag',zeros(BinNumber),'StdRecord',zeros(BinNumber),'dist',0); 
    
    for distidx = 1:DistLength
        dist = b(distidx);
        %only extract the required data
        CollectedData = zeros(4,intotal);
        idxstart = 1;
        for i=1:listlength
            fprintf('read file idx %d, total %d, dist %0.1f\n',i,listlength,dist);
            fn = filelist(i).name;
            ffn = fullfile(samplesavefolder, fn);
            loaddata = load(ffn,'samples');
            samples = loaddata.samples;
            matchedidx = samples(2,:) == dist;
            matchednumber = nnz(matchedidx);
            matcheddata = samples(:,matchedidx);
            idxend = idxstart + matchednumber -1;
            CollectedData(:,idxstart:idxend) = matcheddata;
            idxstart = idxend+1;
        end    
        %remove extra data
        CollectedData = CollectedData(:,1:idxend);
    
        %compute statistics
        Statistics(distidx).dist = dist;
        MagReconstruct = CollectedData(1,:);
        MagOriginal = CollectedData(3,:);
        MagEdgeCenter = CollectedData(4,:);  
        
        %put all samples into each cell
        %Now there is a problem. There are too few samples and too many cells.
        %Many cells are empty and statistics can not be computed
        SpSum = zeros(BinNumber);
        SpSqrSum = zeros(BinNumber);
        Count = zeros(BinNumber);
        for i=1:idxend
            if mod(i,1000) == 0
                fprintf('Process sample i %d, total %d\n',i,idxend);
            end
            Tr = MagEdgeCenter(i);
            Tp = MagReconstruct(i);
            Sp = MagOriginal(i);
            %compute the index of bin
            TpBinIdx = Val2BinIdx(Tp);      %first coordinate
            TrBinIdx = Val2BinIdx(Tr);
            SpSum(TpBinIdx,TrBinIdx) = SpSum(TpBinIdx,TrBinIdx) + Sp;
            SpSqrSum(TpBinIdx,TrBinIdx) = SpSqrSum(TpBinIdx,TrBinIdx) + Sp^2;
            Count(TpBinIdx,TrBinIdx) = Count(TpBinIdx,TrBinIdx) + 1;
        end
        Average = SpSum ./ Count;
        Std = sqrt(SpSqrSum./Count - Average.^2);
        %preserve the nan items
        Statistics(distidx).EstimatedMag = Average;
        Statistics(distidx).StdRecord = Std;
    end
        
    save(Para.StatisticsFileName,'Statistics','b','BinNumber','BinMax','BinMin','BinInterval','BinCenter','DistLength','dist');
end

function BinIdx = Val2BinIdx(val)
    %range 0~0.5, BinNumber 100
    %val 0 ~ 0.005 --> index 1
    %valu 0.005 ~ 0.01 --> index 2
    BinIdx = floor(val / 0.005) + 1;
    if BinIdx > 100
        BinIdx = 100;
    end
end

function DrawOneSetting(Para)
    load(Para.StatisticsFileName);
    for i=1:DistLength
        hFig = figure;
        %need to control here, if d=0, plot is a better choice than mesh
        if i==1
            MeanValue = zeros(1,BinNumber);
            StdValue = zeros(1,BinNumber);
            for j=1:BinNumber
                MeanValue(j) = Statistics(i).EstimatedMag(j,j);
                StdValue(j) =  Statistics(i).StdRecord(j,j);
            end
            plot(BinCenter,MeanValue,'ro');
            hold on
            plot(BinCenter,MeanValue-StdValue,'bx');
            plot(BinCenter,MeanValue+StdValue,'bx');
            xlabel('$m_c$','interpreter','latex','FontSize',30);
            ylabel('$m_e$','interpreter','latex','FontSize',30);
            axis equal
        else
            mesh(BinCenter,BinCenter,Statistics(i).EstimatedMag);
            zlabel('$m_e$','interpreter','latex','FontSize',30);
            xlabel('$m_c$','interpreter','latex','FontSize',30,'Position',[0.2 -0.2 0]);
            ylabel('$m_p$','interpreter','latex','FontSize',30,'Position',[-0.1 0.3 0]);
            colorbar
            caxis([0 1.6]);
            zlim([0 1.6]);
            hAxes = gca;
            hAxesPosition = get(hAxes,'Position');
            set(hAxes,'Position',[hAxesPosition(1)+0.01 hAxesPosition(2) hAxesPosition(3) hAxesPosition(4)]);
        end
%        if dist == 0 || dist == 1
%            TitleString = sprintf('$d$ = %d',dist);
%        end
%        title(TitleString,'interpreter','latex');
        dist = b(i);
        SaveFileNameMain = sprintf('Statistics_Sc%d_Si%dp%d_dist%dp%d',...
            Para.Zooming,...
            floor(Para.Gau_sigma),floor(10*(eps+Para.Gau_sigma-floor(Para.Gau_sigma))),...
            floor(dist)          ,floor(10*(eps+dist-floor(dist)))...
            );
%        SaveFileName = sprintf('Statistic_Sc%d_Si%dp%d',Para.Zooming,floor(Para.Gau_sigma),floor(10*(eps+Para.Gau_sigma-floor(Para.Gau_sigma))));
        FullSaveName = fullfile(Para.SaveFolder,[ SaveFileNameMain ,'.fig']);
        saveas(hFig,FullSaveName);
        FullSaveName = fullfile(Para.SaveFolder,[ SaveFileNameMain ,'.png']);
        saveas(hFig,FullSaveName);      %how to control the png size?
        close(hFig);
    end
end