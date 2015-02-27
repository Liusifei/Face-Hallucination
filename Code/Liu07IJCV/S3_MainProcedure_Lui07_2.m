%Chih-Yuan Yang, EECS, UC Merced
%Last Modified: 08/22/12
%Implement Liu07 methods
addpath('patchmatch-2.1');
addpath('Bilateral Filtering');
%checking necessary parameters
FieldNames = fieldnames(para);
FieldNumber = length(FieldNames);
ExpectedFieldNumber = 27;
if FieldNumber ~= ExpectedFieldNumber
    fprintf('ExpectedFieldNumber = %d, current FieldNumber = %d,\n',ExpectedFieldNumber,FieldNumber);
    error('wrong field number');
end
for i=1:FieldNumber
    switch FieldNames{i}
        case {'zooming'...
                ,'SaveName'...
                ,'testimagefolder'...
                ,'setting'...
                ,'settingnote'...
                ,'tuning'...
                ,'tuningnote'...
                ,'Legend'...
                ,'DistanceUpperBound'...
                ,'ContrastEnhenceCoef'...
                ,'LowMagSuppression'...
                ,'beta1'...
                ,'iistart'...
                ,'iiend'...
                ,'bDumpInformation'...
                ,'MainFileName'...
                ,'patchsize'...
                ,'bApplyNonLocalSimilarityFilter'...
                ,'bUseExsitingSearchingResult'...
                ,'bEnablemhrf'...
                ,'bApplyLocalGradientDistribution'...
                ,'bLoadExistingTexture_NoLGD'...
                ,'bComputeDiivine'...
                ,'bLoadExistingImgTextureAndImgEdge'...
                ,'ExtDatasetNumber'...
                ,'bTimeTest'...
                ,'SimilarityFunctionSettingNumber'...
                ,'ehrfKernelWidth'...
                ,'NumberOfHCandidate'...
                ,'UseL2NormForSelfSimilarPatchSearch'...
                ,'resultfolder'
                }
        otherwise
            fprintf('%s\n', FieldNames{i});
            error('incorrect parameter');
    end
end

if para.zooming == 4
    para.gau_sigma = 1.6;
elseif para.zooming == 3
    para.gau_sigma = 1.2;
end
addpath(fullfile('Lib','YIQConverter'));
resultfolder = 'Result';
settingfolder = fullfile(resultfolder,sprintf('%s%d',para.SaveName,para.setting));
tuningfolder = fullfile(settingfolder, sprintf('Tuning%d',para.tuning));
para.resultfolder = resultfolder;
para.settingfolder = settingfolder;
para.tuningfolder = tuningfolder;
s = para.zooming;
%feature folder: the folder containing sf and srec
featurefolder = fullfile('TexturePatchDataSet','Feature',sprintf('s%d',s));         %remove it later
%Create the tempfolder
if ~exist(featurefolder,'dir')
    mkdir(featurefolder);
end
if ~isempty(para.settingnote)
    fid = fopen(fullfile(settingfolder, 'SettingNote.txt'),'w');
    fprintf(fid,'%s',para.settingnote);
    fclose(fid);
end

if ~exist(para.tuningfolder,'dir')
    mkdir(para.tuningfolder);
end
if ~isempty(para.tuningnote)
    fid = fopen(fullfile(para.tuningfolder ,'TunningNote.txt'),'w');
    fprintf(fid,'%s',para.tuningnote);
    fclose(fid);
end
%copy parameter setting
if ispc
    cmd = ['copy ' para.MainFileName '.m ' fullfile(para.tuningfolder, [para.MainFileName '_backup.m '])];
elseif isunix
    cmd = ['cp ' para.MainFileName '.m ' fullfile(para.tuningfolder, [para.MainFileName '_backup.m '])];
end
dos(cmd);

%run all images in the folder para.testimagefolder, and save the results in the tuningfolder
filelist = dir(fullfile(para.testimagefolder, '*.png'));
filecount = length(filelist);

%load the offline trained data
savefolder = 'LearnedResult_new';
load(fullfile(savefolder,'CMuLambda.mat'),'CCCterm','mu','lambda','r','B');
% load(fullfile(savefolder,'CMuLambda_old.mat'),'CCCterm','mu','lambda','r','B');

%Compute A mu
if para.zooming == 4
    para.gau_sigma = 1.6;
elseif para.zooming == 3
    para.gau_sigma = 1.2;
end
h = 320;
w = 240;
lh = h/para.zooming;
lw = w/para.zooming;
img_mu = reshape(mu, [h w]);
img_Amu = U3_GenerateLRImage_BlurSubSample(img_mu, para.zooming, para.gau_sigma);
Amu = reshape(img_Amu, [lh*lw 1] );

outputfolder = fullfile(para.tuningfolder,'GeneratedImages');
if ~exist(outputfolder, 'dir')
    mkdir(outputfolder);
end

%load the training local images and middle band images
fn_save = fullfile(savefolder,'MiddleBandAndLocalImage');
load(fn_save,'middlebandimage','localimage','kernelwidth','hsize');
trainingimagenumber = size(middlebandimage,3);
kernel = fspecial('gaussian',hsize,kernelwidth);

%the patch size parameters used by Lui07
ps = 6;
overlappingwidth = 2;
shiftwidth = ps - overlappingwidth;
nIterations = [1,5,10,30,50];
alpha = 0.5;
kn = 20;
itern = 2;
dst = 'sf_results_new/';
if ~exist(dst,'dir')
    mkdir(dst);
end

for fileidx=93:100   %this is the index of test images, irrelavant to training images
    %open specific file
    fn_testfile = filelist(fileidx).name;
    para.SourceFile = fullfile(para.testimagefolder,fn_testfile);
    imd = im2double(imread( para.SourceFile) );     %There is no para.SourceFile
% imd = im2double(imread(fullfile(para.testimagefolder,'148_02_02_051_05_align_crop.png')));
    img_yiq = RGB2YIQ(imd);
    img_y = img_yiq(:,:,1);
    IQLayer = img_yiq(:,:,2:3);
    IQLayer_upsampled = imresize(IQLayer,para.zooming);
    para.IQLayer_upsampled = IQLayer_upsampled;
    
    %compute the (C^t C)^-1 C^t (I_l - A mu) from here
    img_y_array = reshape(img_y, [lh*lw 1]);
    X = CCCterm * (img_y_array - Amu);
    %generate the HR intensity image BX + mu
    vector_generated = double(B)*X + mu;
    img_global = reshape(vector_generated, [h w] );
    %dump the image
    fn_testfile_short = fn_testfile(1:end-4);
%     fn_save = fullfile(outputfolder, sprintf('%s%s',fn_testfile_short ,'_Lui07_Step1.png'));
%     imwrite(img_global,fn_save);
    %         eta = 0.001;
    
    %apply Markov Random Field to reconstruct the local image
    %generate the middleband image
    img_middleband = imfilter(img_global,kernel);
    %find all eta-tolerance patches from training middle band images
    %crop patches
    %         LocalPatches = cell(1,size(middlebandimage,3));
    Samplenum = size(middlebandimage,3);
% Samplenum = 10;
    %     rm = randperm(size(middlebandimage,3));
    %     rm = rm(1:Samplenum);
    
    % config of patchmatch
    cores = 1;    % Use more cores for more speed
    if cores==1
        algo = 'cpu';
    else
        algo = 'cputiled';
    end
    
    for m = 1:size(middlebandimage,3)
%             for m = 1:10
        fprintf('Peocessing the %.4dth/%.4d training image, for %.4dth test image\n',m,Samplenum,fileidx);
        %     for m = 1:3
%         [D_best,ann] = PatchMatch(img_middleband,middlebandimage(:,:,m),itern);
        A = uint8(repmat(img_middleband,[1,1,3])*255);
        CB = uint8(repmat(middlebandimage(:,:,m),[1,1,3])*255);
        ann = nnmex(A, CB, algo, 7, [], [], [], [], [], cores, [], [], [], [], [], itern);

        % Match original output: 3 * 79* 59****************
        if length(size(ann))==4
            D_best = reshape(ann(:,:,3,:),[size(ann,1),size(ann,2),itern]);
            cnn = zeros(size(ann,1),size(ann,2),itern);
            for kk = 1:itern
                x = ann(:,:,1,kk)+1;
                y = ann(:,:,2,kk)+1;
                x(or(x<1,x>240))=240; y(or(y<1,y>320))=320;
                cnn(:,:,kk) = reshape(sub2ind([size(ann,1),size(ann,2)], y(:), x(:)),[size(ann,1),size(ann,2)]);
            end
            ann = DownSMapping(ann, ps, shiftwidth);
            %             ann = cnn(ps/2+1:shiftwidth:size(A,1)-ps/2+1, ps/2+1:shiftwidth:size(A,2)-ps/2+1,:);
            D_best = D_best(ps/2+1:shiftwidth:size(A,1)-ps/2+1, ps/2+1:shiftwidth:size(A,2)-ps/2+1,:);
            ann = MatTransfer(ann);
            D_best = MatTransfer(D_best);
        else
            D_best = reshape(ann(:,:,3),[size(ann,1),size(ann,2)]);
            %             x = ann(:,:,1)+1;
            %             y = ann(:,:,2)+1;
            %             cnn(:,:) = reshape(sub2ind([size(ann,1),size(ann,2)], y(:), x(:)),[size(ann,1),size(ann,2)]);
            %             ann = cnn(ps/2+1:shiftwidth:size(A,1)-ps/2+1, ps/2+1:shiftwidth:size(A,2)-ps/2+1);
            ann = DownSMapping(ann, ps, shiftwidth);
            D_best = D_best(ps/2+1:shiftwidth:size(A,1)-ps/2+1, ps/2+1:shiftwidth:size(A,2)-ps/2+1);
        end

        %**************************************************
        [L_Patches,max_x,max_y] = im2patches(localimage(:,:,m),ps,shiftwidth);
        
        %************Local part check**********************
%         [M_Patches,max_x,max_y] = im2patches(middlebandimage(:,:,m),ps,shiftwidth);
%         Cons_g = Patch_Present(M_Patches, reshape(ann(3,:,:),[max_y,max_x]));
%         Cons_l = Patch_Present(L_Patches, reshape(ann(3,:,:),[max_y,max_x]));
%         Cons_g = Patch_Present(M_Patches, ann);
%         Cons_l = Patch_Present(L_Patches, ann);
        %**************************************************
        
        if m == 1
            if itern > 1
                CO = zeros(itern*Samplenum, size(D_best,2), size(D_best,3));
            else
                CO = zeros(itern*10, size(D_best,1), size(D_best,2));
            end
            Cnn = CO;
            Cind = CO;
        end
        %             for r = 1:max_y
        %                 for c = 1:max_x
        %             LocalPatches(r,c,m) = mat2cell(L_Patches(ann(:,r,c)).vec);
        %                 end
        %             end
        if itern > 1
            CO((m-1)*itern+1:m*itern,:,:) = D_best;
            Cnn((m-1)*itern+1:m*itern,:,:) = ann;
            Cind((m-1)*itern+1:m*itern,:,:) = m * ones(size(ann));
        else
            CO(m,:,:) = D_best;
            Cnn(m,:,:) = ann;
            Cind(m,:,:) = m * ones(size(ann));
        end
    end
    %**************Distribution Check*********************
    %     DrawRandPatch(Cnn);
    %*****************************************************
    
    % rank best k
    [Y,I] = sort(CO,1,'ascend');
    %         CO = Y(1:20,:,:);
    CO = Y(1:kn,:,:);
    CIND = CO; CNN = CO;
    %         Iind = sub2ind([20,size(I,2),size(I,3)],)
    %       generate CH,CV
    %         CH = zeros(20,20,size(ann,2),size(ann,3)-1);
    %         CV = zeros(20,20,size(ann,2)-1,size(ann,3));
    CH = zeros(kn,kn,size(CO,2),size(CO,3)-1);
    CV = zeros(kn,kn,size(CO,2)-1,size(CO,3));
    Candidate_p = zeros(ps^2,kn,max_y,max_x);
    Candidate_g = Candidate_p;
    for m = 1:size(CO,2)
        for n = 1:size(CO,3)
            CIND(:,m,n) = Cind(I(1:kn,m,n),m,n);
            CNN(:,m,n) = Cnn(I(1:kn,m,n),m,n);
            %                 [indx,indy] = ind2sub([m_y,m_x],CNN(:,m,n));
            Candidate_p(:,:,m,n) = GetLocalPatch(localimage,CNN(:,m,n),CIND(:,m,n),shiftwidth,ps,max_y,max_x);
            Candidate_g(:,:,m,n) = GetLocalPatch(middlebandimage,CNN(:,m,n),CIND(:,m,n),shiftwidth,ps,max_y,max_x);
        end
    end
    clear Cind Cnn;
    Rind = sub2ind([ps,ps],repmat(1:6,1,2),kron([5:6]',ones(6,1))');
    Lind = sub2ind([ps,ps],repmat(1:6,1,2),kron([1:2]',ones(6,1))');
    Bind = sub2ind([ps,ps],repmat(5:6,1,6),kron([1:6]',ones(2,1))');
    Tind = sub2ind([ps,ps],repmat(1:2,1,6),kron([1:6]',ones(2,1))');
    for m = 1:size(CO,2)
        for n = 1:size(CO,3)
            %                 p1 = GetLocalPatch(localimage,CNN(:,m,n),CIND(:,m,n),shiftwidth,ps,max_y,max_x);
            p1 = Candidate_p(:,:,m,n);
            g1 = Candidate_g(:,:,m,n);
            if n<size(CO,3)
                %                     p2 = GetLocalPatch(localimage,CNN(:,m,n+1),CIND(:,m,n+1),shiftwidth,ps,max_y,max_x);
                p2 = Candidate_p(:,:,m,n+1);
                %                     CH(kr,kc,m,n)= sum((p1(end-1:end,:)-p2(1:2,:)).^2);
                H = sum((kron(p1(Rind,:),ones(1,kn))-repmat(p2(Lind,:),[1,kn])).^2,1);
                CH(:,:,m,n) = reshape(H,kn,kn);
            end
            if m<size(CO,3)
                %                     p3 = GetLocalPatch(localimage,CNN(:,m+1,n),CIND(:,m+1,n),shiftwidth,ps,max_y,max_x);
                p3 = Candidate_p(:,:,m+1,n);
                %                     CV(kr,kc,m,n)= sum((p1(:,end-1:end)-p3(:,1:2)).^2);
                V = sum((kron(p1(Bind,:),ones(1,kn))-repmat(p3(Tind,:),[1,kn])).^2,1);
                CV(:,:,m,n) = reshape(V,kn,kn);
            end
        end
    end
    
    %         m =  0;n = 0;
    %         for r=1:shiftwidth:h
    %             n = n + 1;
    %             r2 = r+ps-1;
    %             if r2 > h
    %                 r2 = h;
    %             end
    %             for c=1:shiftwidth:w
    %                 m = m + 1;
    %                 c2 = c+ps-1;
    %                 if c2 > w
    %                     c2 = w;
    %                 end
    %                 patch_query = img_middleband(r:r2,c:c2);
    %                 %search for eta-tolerence similar patches, there will be a huge computational load
    %                 tic;
    %                 patchlist = F1_FindEtaTolerancePatches(patch_query,middlebandimage, eta);
    %                 toc;
    %                 % written by SfLiu
    %                 %                 Patch(:,r,c) =  patch_query(:);
    %                 %                 Patch_L(:,:,r,c) = patch_query;
    %                 for kr = 1:length(patchlist)
    %                     CO(kr,n,m) = sum((patch_query(:)-patchlist(kr).vec).^2);
    %                     for kc = 1:length(patchlist)
    %                         CH(kr,kc,n,m) = sum(sum((localimage(r:r2,c:c+1,patchlist(kr).ii)...
    %                             -localimage(r:r2,c2-1+shiftwidth:c2+shiftwidth,patchlist(kc).ii)).^2));
    %                         CV(kr,kc,n,m) = sum(sum((localimage(r:r+1,c:c2,patchlist(kr).ii)...
    %                             -localimage(r+shiftwidth:r+shiftwidth+1,c:c2,patchlist(kc).ii)).^2));
    %                     end
    %                 end
    %                 %                 keyboard;
    %             end
    %         end
    %----------------------------------------------------------------------
    % run belief propagation
    %----------------------------------------------------------------------
    %      [IDX,En]=immaxproduct(CO,CH,CV,nIterations,alpha);
    figure(3);clf;
    for ii = 1:length(nIterations)
        [IDX,En] = immaxproduct(CO,CH*alpha,CV*alpha,nIterations(ii),0.5);
        Patchfull = zeros(ps^2,max_y,max_x);
        g_Patchfull = Patchfull;
        for m = 1:max_y
            for n = 1:max_x
                Patchfull(:,m,n) = Candidate_p(:,IDX(m,n),m,n);
                g_Patchfull(:,m,n) = Candidate_g(:,IDX(m,n),m,n);
            end
        end
        CosLocalIm = LayPatches(Patchfull,ps,shiftwidth,size(img_middleband));
        CosGlobalIm = LayPatches(g_Patchfull,ps,shiftwidth,size(img_middleband));
        subplot(2,length(nIterations),ii)
        imshow(CosGlobalIm,[]);
        subplot(2,length(nIterations),length(nIterations)+ii)
        imshow(img_middleband + CosLocalIm,[]);
    end
    figure(3);
    saveas(gcf,[dst,'SPImage12_',fn_testfile_short,'.fig'],'fig');
    SP_IMG = (img_middleband + CosLocalIm);
    save([dst,'CosLocalIm_',fn_testfile_short,'.mat'],'CosLocalIm');
    SP_IMG = (SP_IMG-min(SP_IMG(:)))/(max(SP_IMG(:))-min(SP_IMG(:)));
    imwrite(SP_IMG,[dst,'SPIMGPre_',fn_testfile_short,'.png']);
    %----------------------------------------------------------------------
    % Step 3, Biliteral Filtering
    %----------------------------------------------------------------------
    SP_IMG = bfilter2(SP_IMG,3,[1.2,0.05]);
    figure(4);
    imshow(SP_IMG);
    imwrite(SP_IMG,[dst,'SPIMG_',fn_testfile_short,'.png']);
    %     saveas(gcf,[dst,'SPImage3_',sprintf('%.4d',fileidx),'.png'],'png');
end
