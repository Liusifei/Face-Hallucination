%2/3/15
%Chih-Yuan Yang
%Test5: We are going to generate more JPEG compressed images as the 
%supplimentary website for PAMI submission
clc
clear
close all

    
scalingfactor = 4;

str_legend = 'Liu07_test5';

idx_file_start = 1;
idx_file_end = 'all';

folder_save = fullfile('Result',mfilename);
folder_code = fileparts(pwd);
folder_ours = fullfile(folder_code,'Ours2');
addpath(folder_ours);
U22_makeifnotexist(folder_save);
folder_filelist = fullfile(folder_ours,'Filelist');

addpath('patchmatch-2.1');
addpath('Bilateral Filtering');
addpath(fullfile('Lib','YIQConverter'));

%fn_filelist = 'MultiPIE_Upfrontal_Compressed_25_50_75_100.txt';
%folder_test = fullfile(folder_ours,'Source','Upfrontal3','Input','25_50_75_100');
fn_filelist = 'PubFig2_2Foundable_JPEGCompressed25_50_75_100.txt';
folder_test = fullfile(folder_ours,'Source','PubFig2_2Foundable','JPEGCompressed');


if scalingfactor == 4
    Gaussian_sigma = 1.6;
elseif scalingfactor == 3
    Gaussian_sigma = 1.2;
end

%load the offline trained data
folder_LearnedResult = 'LearnedResult_new';
load(fullfile(folder_LearnedResult,'CMuLambda.mat'),'CCCterm','mu','lambda','r','B');

%Compute A mu
h = 320;
w = 240;
lh = h/scalingfactor;
lw = w/scalingfactor;
img_mu = reshape(mu, [h w]);
img_Amu = U3_GenerateLRImage_BlurSubSample(img_mu, scalingfactor, Gaussian_sigma);
Amu = reshape(img_Amu, [lh*lw 1] );

%load the training local images and middle band images
fn_load = fullfile(folder_LearnedResult,'MiddleBandAndLocalImage');
%localimage means the difference maps of the training from the blurred middlebandimage
load(fn_load,'middlebandimage','localimage','kernelwidth','hsize');
img_training_middleband = middlebandimage;        %rename it
img_training_highfrequency = localimage;          %rename it
num_trainingimage = size(img_training_middleband,3);
kernel = fspecial('gaussian',hsize,kernelwidth);

%the patch size parameters used by Lui07
ps = 6;
overlappingwidth = 2;
shiftwidth = ps - overlappingwidth;
nIterations = [1,5,10,30,50];
alpha = 0.5;
kn = 20;            %this parameter control the number of patches in a stack used in the MRF problem.

arr_filename = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_file = length(arr_filename);
if isa(idx_file_end,'char')
    if strcmp(idx_file_end,'all')
        idx_file_end = num_file;
    end
end

for idx_file = idx_file_start:idx_file_end
    %open specific file
    fn_test = arr_filename{idx_file};
    fn_short = fn_test(1:end-4);
    fprintf('fileidx %d, fn_test %s\n',idx_file,fn_test);
    
    %Check, if the output exist, go to the next fil
    fn_save = sprintf('%s_%s.png',fn_short,str_legend);
    if exist(fullfile(folder_save,fn_save),'file')
        fprintf('output file exist %s\n', fn_save);
        %If this an empty file, its previous program may crash already. Check the size and created time
        fileinfo = dir(fullfile(folder_save,fn_save));
        if fileinfo(1).bytes == 0
            date_difference_day = now - datenum(fileinfo(1).date);
            date_difference_hour = date_difference_day * 24;
            
            if date_difference_hour > 3
                %overwrite the existing empty file
                fprintf('Overwrite exiting empty file %s\n', fn_save);
                fid = fopen(fullfile(folder_save,fn_save),'w+');
                fclose(fid);   
            else
                continue
            end
        else
            continue
        end
    else
        fid = fopen(fullfile(folder_save,fn_save),'w+');
        fclose(fid);
    end
        
        
    %open specific file
    imd = im2double(imread( fullfile(folder_test, fn_test)) );     %There is no para.SourceFile
    img_yiq = RGB2YIQ(imd);
    img_y = img_yiq(:,:,1);
    img_iq = img_yiq(:,:,2:3);
    img_iq_hr = imresize(img_iq,scalingfactor);
        
    %compute the (C^t C)^-1 C^t (I_l - A mu) from here
    img_y_array = reshape(img_y, [lh*lw 1]);
    X = CCCterm * (img_y_array - Amu);
    %generate the HR intensity image BX + mu
    vector_generated = double(B)*X + mu;
    img_global = reshape(vector_generated, [h w] );
    %dump the image
    
    %apply Markov Random Field to reconstruct the local image
    %generate the middleband image
    img_test_middleband = imfilter(img_global,kernel);
    %find all eta-tolerance patches from training middle band images
    %crop patches
    %         LocalPatches = cell(1,size(middlebandimage,3));
    
    % config of patchmatch
    cores = 1;    % Use more cores for more speed
    if cores==1
        algo = 'cpu';
    else
        algo = 'cputiled';
    end
    
    %2/3/2015, I can not use a small number here for sanity test.
    %I have to use the full number and otherwise there will be an error.
    %I need to ask Sifei to figure out her design.
    for m = 1:num_trainingimage
        fprintf('Processing the %4dth/%4d training image, for %dth test image\n',m,num_trainingimage,idx_file);
        %     for m = 1:3
        %                 [D_best,ann] = PatchMatch(img_test_middleband,middlebandimage(:,:,rm(m)),knn);
        %function ann = nnmex(A, B, [algo='cpu'], [patch_w=7], [nn_iters=5], [rs_max=100000], [rs_min=1], [rs_ratio=0.5], [rs_iters=1.0], [cores=2], [bmask=NULL]...
        % [win_size=[INT_MAX INT_MAX]], [nnfield_prev=[]], [nnfield_prior=[]], [prior_winsize=[]], [knn=1], [scalerange=4])
        A = uint8(repmat(img_test_middleband,[1,1,3])*255);      %re-color the middleband image into 3 channels to be used in PatchMatch
        CB = uint8(repmat(img_training_middleband(:,:,m),[1,1,3])*255);
        patch_w=7;
        nn_iters=[]; %default 5
        rs_max = []; %default 100000
        rs_min = []; %default 1
        rs_ratio = []; %default 0.5
        rs_iters = []; %default 1.0
        bmask = [];   %defaut NULL
        win_size = []; %default [INT_MAX INT_MAX]], 
        nnfield_prev = []; %default []
        nnfield_prior = []; %default []
        prior_winsize = []; %default []
        knn = 2;    %default 1. There seems a bug in the nnmex implementation. If we assign 1 in this variable, there will
        %be a runtime error "knn is less than zero". However, we can assign it as [] to pass the parameter checking.

        ann = nnmex(A, CB, algo, patch_w, nn_iters, rs_max, rs_min, rs_ratio, rs_iters, cores, bmask, win_size, nnfield_prev, nnfield_prior, prior_winsize, knn);
        
        %The output of ann is a h*w*3 matrix where ann(:,;,1) is the x coordinate, ann(:,:,2) is the y coordinate, and
        %ann(:,:,3) is the l2-norm


        % Match original output: 3 * 79* 59****************
        if length(size(ann))==4
            D_best = reshape(ann(:,:,3,:),[size(ann,1),size(ann,2),knn]);       %D_best is l2-norm (distance)
            cnn = zeros(size(ann,1),size(ann,2),knn);
            for kk = 1:knn
                x = ann(:,:,1,kk)+1;        %get coordinate
                y = ann(:,:,2,kk)+1;
                x(or(x<1,x>240))=240; 
                y(or(y<1,y>320))=320;
                cnn(:,:,kk) = reshape(sub2ind([size(ann,1),size(ann,2)], y(:), x(:)),[size(ann,1),size(ann,2)]);
            end
            ann = DownSMapping(ann, ps, shiftwidth);
            D_best = D_best(ps/2+1:shiftwidth:size(A,1)-ps/2+1, ps/2+1:shiftwidth:size(A,2)-ps/2+1,:);
            ann = MatTransfer(ann);
            D_best = MatTransfer(D_best);
        else
            D_best = reshape(ann(:,:,3),[size(ann,1),size(ann,2)]);
            ann = DownSMapping(ann, ps, shiftwidth);
            D_best = D_best(ps/2+1:shiftwidth:size(A,1)-ps/2+1, ps/2+1:shiftwidth:size(A,2)-ps/2+1);
        end
        
        L_Patches = im2patches(img_training_highfrequency(:,:,m),ps,shiftwidth);
        
        %************Local part check**********************
        [M_Patches,max_x,max_y] = im2patches(img_training_middleband(:,:,m),ps,shiftwidth);
                        Cons_g = Patch_Present(M_Patches, reshape(ann(1,:,:),[max_y,max_x]));
                        Cons_l = Patch_Present(L_Patches, reshape(ann(1,:,:),[max_y,max_x]));
%         Cons_g = Patch_Present(M_Patches, ann);
%         Cons_l = Patch_Present(L_Patches, ann);
        %**************************************************
        
        if m == 1
            if knn > 1
                CO = zeros(knn*num_trainingimage, size(D_best,2), size(D_best,3));
            else
                %2/3/15 Chih-Yuan: What is the CO variable here? Does Sifei want to solve a MRF problem?
                CO = zeros(knn*10, size(D_best,1), size(D_best,2));
            end
            Cnn = CO;
            Cind = CO;
        end
        %             for r = 1:max_y
        %                 for c = 1:max_x
        %             LocalPatches(r,c,m) = mat2cell(L_Patches(ann(:,r,c)).vec);
        %                 end
        %             end
        if knn > 1
            CO((m-1)*knn+1:m*knn,:,:) = D_best;
            Cnn((m-1)*knn+1:m*knn,:,:) = ann;
            Cind((m-1)*knn+1:m*knn,:,:) = m * ones(size(ann));
        else
            CO(m,:,:) = D_best;
            Cnn(m,:,:) = ann;
            Cind(m,:,:) = m * ones(size(ann));
        end
    end %end of loop for m=1:num_trainingimage
    
     
    %**************Distribution Check*********************
    %     DrawRandPatch(Cnn);
    %*****************************************************
    
    % rank best k
    [Y,I] = sort(CO,1,'ascend');
    %         CO = Y(1:20,:,:);
    CO = Y(1:kn,:,:);
    CIND = CO; 
    CNN = CO;
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
            Candidate_p(:,:,m,n) = GetLocalPatch(img_training_highfrequency,CNN(:,m,n),CIND(:,m,n),shiftwidth,ps,max_y,max_x);
            Candidate_g(:,:,m,n) = GetLocalPatch(img_training_middleband,CNN(:,m,n),CIND(:,m,n),shiftwidth,ps,max_y,max_x);
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
    %                 patch_query = img_test_middleband(r:r2,c:c2);
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
    %2/3/15 I comment this figure because now I run the code on a Linux machine
    %figure(3);
    %clf;
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
        CosLocalIm = LayPatches(Patchfull,ps,shiftwidth,size(img_test_middleband));
        CosGlobalIm = LayPatches(g_Patchfull,ps,shiftwidth,size(img_test_middleband));
        %subplot(2,length(nIterations),ii)
        %imshow(CosGlobalIm,[]);
        %subplot(2,length(nIterations),length(nIterations)+ii)
        %imshow(img_test_middleband + CosLocalIm,[]);
    end
    %figure(3);
    %saveas(gcf,[folder_save,'SPImage12_',fn_testfile_short,'.fig'],'fig');
    SP_IMG = (img_test_middleband + CosLocalIm);
    %save([folder_save,'CosLocalIm_',fn_testfile_short,'.mat'],'CosLocalIm');
    SP_IMG = (SP_IMG-min(SP_IMG(:)))/(max(SP_IMG(:))-min(SP_IMG(:)));
    %imwrite(SP_IMG,[folder_save,'SPIMGPre_',fn_testfile_short,'.png']);
    %----------------------------------------------------------------------
    % Step 3, Biliteral Filtering
    %----------------------------------------------------------------------
    SP_IMG = bfilter2(SP_IMG,3,[1.2,0.05]);
    %figure(4);
    %imshow(SP_IMG);
    img_yiq_hr = cat(3,SP_IMG,img_iq_hr);
    img_rgb_hr = YIQ2RGB(img_yiq_hr);
    imwrite(img_rgb_hr,fullfile(folder_save,fn_save));
end
