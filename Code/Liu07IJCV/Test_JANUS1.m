%09/15/13
%Chih-Yuan Yang
%Ming-Hsuan need the results of JANUS by Liu07 method, Modify the
%Test_FAce_3_1
clc
clear
close all


folder_code = fileparts(pwd);
folder_ours = fullfile(folder_code,'Ours2');
folder_lib = fullfile(folder_code,'Lib');
addpath(folder_ours);
addpath('patchmatch-2.1');
addpath('Bilateral Filtering');
addpath(fullfile(folder_lib,'YIQConverter'));

scalingfactor = 4;
folder_test = fullfile(folder_ours, 'Source','JANUSProposal','input');
folder_filelist = fullfile(folder_ours,'FileList');
fn_filelist = 'JANUSProposalDone_14.txt';
arr_filename_test = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
folder_save = fullfile('Result','JANUS1');
str_method_appendix = '_Liu07';

idx_file_start = 1;
idx_file_end = 7;%'all';

num_files_test = length(arr_filename_test);
if isa(idx_file_end,'char')
    if strcmp(idx_file_end,'all')
        idx_file_end = num_files_test;
    end
end

gau_sigma = 1.6;

%load the offline trained data
%This folder seems used by Sifei
savefolder = 'LearnedResult_new';
load(fullfile(savefolder,'CMuLambda.mat'),'CCCterm','mu','lambda','r','B');
% load(fullfile(savefolder,'CMuLambda_old.mat'),'CCCterm','mu','lambda','r','B');

h = 320;
w = 240;
lh = h/scalingfactor;
lw = w/scalingfactor;
img_mu = reshape(mu, [h w]);
img_Amu = U3_GenerateLRImage_BlurSubSample(img_mu, scalingfactor, gau_sigma);
Amu = reshape(img_Amu, [lh*lw 1] );

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
if ~exist(folder_save,'dir')
    mkdir(folder_save);
end

for fileidx=idx_file_start:idx_file_end
    %open specific file
    fn_test = arr_filename_test{fileidx};
    fn_short = fn_test(1:end-4);
    fn_save = sprintf('%s%s.png',fn_short,str_method_appendix);
    if exist(fullfile(folder_save,fn_save),'file')
        continue;
    else
        %create an empty file
        fid = fopen(fullfile(folder_save,fn_save),'w+');
        fclose(fid);
    end
    
    imd = im2double(imread( fullfile(folder_test,fn_test)) );
    img_yiq = RGB2YIQ(imd);
    img_y = img_yiq(:,:,1);
    IQLayer = img_yiq(:,:,2:3);
    IQLayer_upsampled = imresize(IQLayer,scalingfactor);
    
    %compute the (C^t C)^-1 C^t (I_l - A mu) from here
    img_y_array = reshape(img_y, [lh*lw 1]);
    X = CCCterm * (img_y_array - Amu);
    %generate the HR intensity image BX + mu
    vector_generated = double(B)*X + mu;
    img_global = reshape(vector_generated, [h w] );
    %dump the image
    fn_save = fullfile(folder_save, sprintf('%s%s',fn_short ,'_Lui07_Step1.png'));
    imwrite(img_global,fn_save);
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
    
    %use 10 image for sanity test
    for m = 1:size(middlebandimage,3)
        fprintf('Peocessing the %.4dth/%.4d training image, for %.4dth test image\n',m,Samplenum,fileidx);
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
            ann = DownSMapping(ann, ps, shiftwidth);
            D_best = D_best(ps/2+1:shiftwidth:size(A,1)-ps/2+1, ps/2+1:shiftwidth:size(A,2)-ps/2+1);
        end
        L_Patches = im2patches(localimage(:,:,m),ps,shiftwidth);
        
        %************Local part check**********************
        [M_Patches,max_x,max_y] = im2patches(middlebandimage(:,:,m),ps,shiftwidth);
                        Cons_g = Patch_Present(M_Patches, reshape(ann(1,:,:),[max_y,max_x]));
                        Cons_l = Patch_Present(L_Patches, reshape(ann(1,:,:),[max_y,max_x]));
        
        if m == 1
            if itern > 1
                CO = zeros(itern*Samplenum, size(D_best,2), size(D_best,3));
            else
                CO = zeros(itern*10, size(D_best,1), size(D_best,2));
            end
            Cnn = CO;
            Cind = CO;
        end
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
    saveas(gcf,fullfile(folder_save,['SPImage12_',fn_short,'.fig']));
    SP_IMG = (img_middleband + CosLocalIm);
    save(fullfile(folder_save,['CosLocalIm_',fn_short,'.mat']),'CosLocalIm');
    SP_IMG = (SP_IMG-min(SP_IMG(:)))/(max(SP_IMG(:))-min(SP_IMG(:)));
    imwrite(SP_IMG,fullfile(folder_save,['SPIMGPre_',fn_short,'.png']));
    %----------------------------------------------------------------------
    % Step 3, Biliteral Filtering
    %----------------------------------------------------------------------
    SP_IMG = bfilter2(SP_IMG,3,[1.2,0.05]);
    figure(4);
    imshow(SP_IMG);
    imwrite(SP_IMG,fullfile(folder_save,['SPIMG_',fn_short,'.png']));
    
    img_yiq_sr = cat(3,SP_IMG,IQLayer_upsampled);
    img_rgb_hr = YIQ2RGB(img_yiq_sr);
    fn_save = sprintf('%s%s.png',fn_short,str_method_appendix);
    imwrite(img_rgb_hr, fullfile(folder_save,fn_save));
end
