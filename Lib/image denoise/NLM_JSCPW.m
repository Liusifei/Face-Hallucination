function [DenoisedImg,t] = NLM_JSCPW(NoisyImg,PatchSizeHalf,SearchSizeHalf,Sigma,BlockSizeHalf,BLambdaSqRatio)
% FUNCTION Non-Local Means with James Stein Type Center Pixel Weights
% =========================================================================
% INPUT: 
%       NoisyImg = 2D grayscale image
%       PatchSizeHalf = half of local square patch size (e.g. 3)
%       SearchSizeHalf = half of search window size (e.g. 15)
%       BlockSizeHalf = half of block window to estimate shrinkage para (e.g. 15)
%       Sigma = True or estimated image noise standard deviation
%       BLambdaSqRatio = tempature parameter in NLM (optional; default = 0.5)
% OUTPUT:
%       DenoisedImg = a structure containing denoised images
%             .zero = the zero CPW result
%             .one  = the unitary CPW result (classic solution)
%             .max  = the max CPW result
%             .heur = the heuristic CPW result
%            .stein = the stein CPW result
%            .LJS   = the local James Stein result
% =========================================================================
% DEMO CODE: 
% % Demo 1: Gray Images
% close all  
% CleanImg = im2double(imread('cameraman.tif'));
% Sigma = 20/255;PatchSizeHalf = 2; SearchSizeHalf = 15;BlockSizeHalf = 7;BLambdaSqRatio = .5;
% NoisyImg = CleanImg+randn(size(CleanImg))*Sigma;
% DenoisedImg = NLM_JSCPW(NoisyImg,PatchSizeHalf,SearchSizeHalf,Sigma,BlockSizeHalf,BLambdaSqRatio);
% PSNR = @(x) -10*log10(mean((x(:)-CleanImg(:)).^2));
% figure,
% subplot(241),imshow(CleanImg,[0,1]),title('Clean'),
% subplot(242),imshow(NoisyImg,[0,1]),title('Noisy'),
% xlabel(num2str(PSNR(NoisyImg)));
% subplot(243),imshow(DenoisedImg.zero,[0,1]),title('CPW0'),
% xlabel(num2str(PSNR(DenoisedImg.zero)));
% subplot(244),imshow(DenoisedImg.one,[0,1]),title('CPW1'),
% xlabel(num2str(PSNR(DenoisedImg.one)));
% subplot(245),imshow(DenoisedImg.max,[0,1]),title('CPWmax'),
% xlabel(num2str(PSNR(DenoisedImg.max)));
% subplot(246),imshow(DenoisedImg.heur,[0,1]),title('CPWheur'),
% xlabel(num2str(PSNR(DenoisedImg.heur)));
% subplot(247),imshow(DenoisedImg.stein,[0,1]),title('CPWstein'),
% xlabel(num2str(PSNR(DenoisedImg.stein)));
% subplot(248),imshow(DenoisedImg.LJS,[0,1]),title('CPWJamesStein'),
% xlabel(num2str(PSNR(DenoisedImg.LJS)));
% % Demo 2: Color Images
% CleanImg = im2double(imread('peppers.png'));
% Sigma = 50/255;PatchSizeHalf = 2; SearchSizeHalf = 15;BlockSizeHalf = 7;BLambdaSqRatio = .5;
% NoisyImg = CleanImg+randn(size(CleanImg))*Sigma;
% DenoisedImg = NLM_JSCPW(NoisyImg,PatchSizeHalf,SearchSizeHalf,Sigma,BlockSizeHalf,BLambdaSqRatio);
% PSNR = @(x) -10*log10(mean((x(:)-CleanImg(:)).^2));
% figure,
% subplot(241),imshow(CleanImg,[0,1]),title('Clean'),
% subplot(242),imshow(NoisyImg,[0,1]),title('Noisy'),
% xlabel(num2str(PSNR(NoisyImg)));
% subplot(243),imshow(DenoisedImg.zero,[0,1]),title('CPW0'),
% xlabel(num2str(PSNR(DenoisedImg.zero)));
% subplot(244),imshow(DenoisedImg.one,[0,1]),title('CPW1'),
% xlabel(num2str(PSNR(DenoisedImg.one)));
% subplot(245),imshow(DenoisedImg.max,[0,1]),title('CPWmax'),
% xlabel(num2str(PSNR(DenoisedImg.max)));
% subplot(246),imshow(DenoisedImg.heur,[0,1]),title('CPWheur'),
% xlabel(num2str(PSNR(DenoisedImg.heur)));
% subplot(247),imshow(DenoisedImg.stein,[0,1]),title('CPWstein'),
% xlabel(num2str(PSNR(DenoisedImg.stein)));
% subplot(248),imshow(DenoisedImg.LJS,[0,1]),title('CPWJamesStein'),
% xlabel(num2str(PSNR(DenoisedImg.LJS)));
% % Demo 3: Performance Comparison (Figure 1 in Paper) 
% % Please expect 5+ mins to plot these figures
% CleanImg = im2double(imread('cameraman.tif'));
% sigmaList = [10,20,40,60];
% patchList = [1,2,3];
% blambdaList = [10:10:200]./100;
% dNames = fieldnames(DenoisedImg);
% PSNR = @(x) -10*log10(mean((x(:)-CleanImg(:)).^2));
% for i = 1:4
%     Sigma = sigmaList(i)/255;
%     NoisyImg = CleanImg+randn(size(CleanImg))*Sigma;
%     for p = patchList
%         for r = 1:20
%             DenoisedImg = NLM_JSCPW(NoisyImg,p,SearchSizeHalf,Sigma,BlockSizeHalf,blambdaList(r));
%             for k = 1:numel(dNames)
%                 sPSNRScore(r,k,p) = PSNR(DenoisedImg.(dNames{k}));
%             end
%         end
%     end
%     PSNRScore{i} = sPSNRScore;
%     figure,
%     for p = patchList
%         subplot(3,1,p),plot(blambdaList,sPSNRScore(:,:,p)),axis square,legend(dNames,3);
%         title(['Noise Level \sigma = ' num2str(round(Sigma*255))])
%     end
% end
% =========================================================================
% PAPER INFO:
%       Yue Wu, Brian Tracey, Premkumar Natarajan, and Joseph P. Noonan, 
%       "James-Stein Type Center Pixel Weights for Non-Local Means Image Denoising"
%       IEEE Signal Processing Letters, 2013.
% PLEASE CITE THIS PAPER, IF YOU USE THIS CODE FOR ACADEMIC PURPOSES
% =========================================================================
% This code is free of academic use. For all inquiries, please contact:
%       Yue WU
%       ECE Dept., TUFTS Univ.
%       ywu03@ece.tufts.edu
% =========================================================================
% Last Update 02/03/2013
% =========================================================================
%% 1. Parameter Check
if nargin<4
    error('Insufficient No. of Inputs');
else
    if ~exist('BlockSizeHalf','var')
        BlockSizeHalf = (SearchSizeHalf-1)/2;
    end
end
if ~exist('BLambdaSqRatio','var')
    BLambdaSqRatio = .5;
end
% Denoising for RGB images
if size(NoisyImg,3) == 3
    dNames = {'zero','one','max','heur','stein','LJS'};
    for i = 1:3
        tDenoisedImg = NLM_JSCPW(NoisyImg(:,:,i),PatchSizeHalf,SearchSizeHalf,Sigma,BlockSizeHalf,BLambdaSqRatio);
        for j = 1:numel(dNames)
            DenoisedImg.(dNames{j})(:,:,i) = tDenoisedImg.(dNames{j});
        end
    end
    return
end
%% 2. Non-Local Mean Denoising
tic
[Height,Width] = size(NoisyImg);
u = zeros(Height,Width); 
M = u;
W = M;
PaddedComplete = padarray(NoisyImg,[Height,Width],'symmetric','both');
BLambdaSq = Sigma^2*(PatchSizeHalf*2+1)^2*BLambdaSqRatio;
% Main loop
PatchSizeFull = PatchSizeHalf*2+1;        
imgL = padarray(NoisyImg,[PatchSizeHalf,PatchSizeHalf],'symmetric','both');
for dx = -SearchSizeHalf:SearchSizeHalf
    for dy = -SearchSizeHalf:SearchSizeHalf
        if dx ~=0 || dy~=0
            % Compute the Integral Image            
            imgK = PaddedComplete((Height+1+dx-PatchSizeHalf):(Height+Height+dx+PatchSizeHalf),(Width+1+dy-PatchSizeHalf):(Width+dy+Width+PatchSizeHalf));
            diff = (imgL-imgK).^2;
            II = cumsum(cumsum(diff,1),2);
            SqDist = [0,zeros(1,Width-1);zeros(Height-1,1),II(1:end-PatchSizeFull,1:end-PatchSizeFull)]...
                +II(PatchSizeFull:end,PatchSizeFull:end)...
                -[zeros(1,Width);II(1:end-PatchSizeFull,PatchSizeFull:end)]...
                -[zeros(Height,1),II(PatchSizeFull:end,1:end-PatchSizeFull)];
            w = exp(-SqDist/(2*BLambdaSq));
            v = imgK(PatchSizeHalf+1:end-PatchSizeHalf,PatchSizeHalf+1:end-PatchSizeHalf);
            % Compute and accumalate denoised pixels
            u = u+w.*v;
            M = max(M,w);
            W = W+w;
        end
    end
end
W = W+eps;
yl = NoisyImg;
zl = u./W;
DenoisedImg.zero = zl;
t(1) = toc;
%% 3. NLM with CPWs
Dfun = @(p) zl.*(1-p)+yl.*p;
cpw2shrink = @(v) v./(v+W);
% 3.1 Unitary CPW
p =  cpw2shrink(1);
DenoisedImg.one = Dfun(p);
% 3.2 max CPW
p = cpw2shrink(M);
DenoisedImg.max = Dfun(p);
% 3.3 stein CPW
v = exp(-2*Sigma^2*(PatchSizeFull)^2/(2*BLambdaSq));
p = cpw2shrink(v);
DenoisedImg.stein = Dfun(p);
% 3.4 heuristic CPW
tD = DenoisedImg.max;
tD(M<10^-6) = yl(M<10^-6);
DenoisedImg.heur = tD;
% 3.5 JamesStein CPW
tic
B = BlockSizeHalf*2+1;
MSE = (zl-yl).^2;
SE = imfilter(MSE,ones(B),'symmetric','same');
p = max(1-Sigma^2./(SE/(B^2-2)),0);
DenoisedImg.LJS = Dfun(p);
%% 4. Time Complexity
t(2) = toc;
display(['Time for NLM ' num2str(t(1)) ' sec; Time for JamesStein CPW ' num2str(t(2)) ' sec']);
return