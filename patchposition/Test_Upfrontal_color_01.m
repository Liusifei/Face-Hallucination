%Chih-Yuan Yang
%11/08/12
%save gradient_component for paper writing
% should run PP4f_PrepareImageForLoading.m first to store exemplar data
clc
clear
close all
Quality = 100;
rootf = 'D:\Projects\Ours2';
rootp = 'D:\Projects\PIE';
rootr = 'D:\Projects\JPEG_SR\Results';
toolbox = 'D:\Projects\JPEG_SR\jpegtbx_1.4';

codefolder = fileparts(pwd);
projectfolder = fileparts(codefolder);
addpath(genpath(fullfile(codefolder,'patchmatch-2.1')));
addpath(genpath(fullfile(codefolder,'comparison')));
addpath(genpath(rootf));
addpath(toolbox);

para.zooming = 4;
para.settingname = 'Upfrontal3';
para.testimagefolder = fullfile(rootf,'Source','Upfrontal3','Input','png');
% para.testimagefolder = fullfile(rootf,'Source','Upfrontal3','Input',sprintf('%d',Quality));
% para.testimagefolder = fullfile(rootf,'Source','Upfrpmtal_show',sprintf('%d',Quality));
para.savefolder = 'GeneratedImages_stv_color';
para.setting = 3;
para.settingnote = '';
para.tuning = Quality;
para.tuningnote = 'start';
para.legend = 'Ours';
para.model = 'mi';
para.detectedlandmarkfolder = fullfile(rootf,'Temp','DetectedLandmarks','Upfrontal3');
para.glasslistfolder = fullfile(rootf,'Examples','Upfrontal3');
para.loadfolder = fullfile(rootp,'Upfrontal3_training','Training_LR_JPEG','PreparedMatForLoad_color');

% para.loadname = sprintf('ExampleDataForLoad_%d.mat',Quality);
para.loadname = sprintf('ExampleDataForLoad_L.mat');

fileidx_start = 3;
fileidx_end = 'all';

para.mainfilename = mfilename;

if para.zooming == 4
    para.Gau_sigma = 1.6;
elseif para.zooming == 3
    para.Gau_sigma = 1.2;
end

resultfolder = fullfile(rootr,'cvpr14_sp_tv');
para = U23a_PrepareResultFolder(resultfolder, para);

%load all training images
load(fullfile(para.loadfolder,para.loadname));
% allLRexampleimages = exampleimages_lr;

[a,b,~,d] = size(exampleimages_lr);
allLRexampleimages = reshape(exampleimages_lr(:,:,1,:),[a,b,d]);

% ,'exampleimages_hr','exampleimages_lr','landmarks');
load(fullfile(para.loadfolder,'landmarks.mat'));
rawexamplelandmarks = landmarks;
load(fullfile(para.loadfolder,'ExampleDataForLoad_H'));
% rawexampleimage = exampleimages_hr;
[a,b,c,d] = size(exampleimages_hr);
rawexampleimage = reshape(exampleimages_hr(:,:,1,:),[a,b,d]);
% ===================================
%  allLRexampleimages = exampleimages_lr;
% ===================================
% clear exampleimages_lr landmarks exampleimages_hr
% if matlabpool('size') == 0
%     matlabpool open local 4
% end
finalsavefolder = fullfile(para.tuningfolder, para.savefolder);
U22_makeifnotexist(finalsavefolder);

%load glass list
fid = fopen(fullfile(para.glasslistfolder,'GlassList.txt'),'r+');
C = textscan(fid,'%05d %s %d\n');
fclose(fid);
glasslist = C{3};
examplefilenamelist = C{2};
clear C fid
clc

filelist = dir(fullfile(para.testimagefolder, '*.png'));
filenumber = length(filelist);
if isa(fileidx_end,'char')
    if strcmp(fileidx_end,'all')
        fileidx_end = filenumber;
    end
end
% for fileidx=fileidx_start:fileidx_end
for fileidx=[32]
    %open specific file
    fn_test = filelist(fileidx).name;
    fprintf('fileidx %d, fn_test %s\n',fileidx,fn_test);
    imd = im2double(imread(fullfile(para.testimagefolder,fn_test)));
    img_ycbcr = rgb2ycbcr(imd);
    img_y = img_ycbcr(:,:,1);
    cbcrLayer = img_ycbcr(:,:,2:3);
    zooming = para.zooming;
    cbcrLayer_upsampled = imresize(cbcrLayer,zooming);
    img_bb = imresize(FAST_NLM_II(img_y,3,2,0.08),zooming);
    
    %assume the test file has been detected
    %load computed data
    fn_testshort = fn_test(1:end-4);
    fn_load = sprintf('%s_mi.mat',fn_testshort);
    fn_load_full = fullfile(para.detectedlandmarkfolder,fn_load);
    if ~exist(fn_load_full,'file')
        continue     %no UCI detected results, go to next or reduce the threshold
    end
    loaddata = load(fn_load_full);
    bs = loaddata.bs(1);
    
    landmarks_test = F4_ConvertBStoMultiPieLandmarks(bs);
    [gradients_texture, img_color] = ...
        F40fs_GetTexturePatchMatch_Aligned(img_ycbcr, exampleimages_hr, exampleimages_lr, landmarks_test, rawexamplelandmarks);
    %     gradients_texture = ...
    %         Fsb_GetTexturePatchMatch_Aligned(img_y, rawexampleimage, allLRexampleimages, landmarks_test, rawexamplelandmarks,Quality);
    
    
    [gradient_edge, weightmap_edge] = F21f_EdgePreserving_GaussianKernel(img_y,para.zooming,para.Gau_sigma);
    gradientwholeimage = gradient_edge .*repmat(weightmap_edge, [1 1 8]) + gradients_texture .* repmat(1-weightmap_edge,[1 1 8]);
    
    [h_lr, w_lr] = size(img_y);
    h_hr = h_lr * zooming;
    w_hr = w_lr * zooming;
    gradient_zdim = 8;
    gradient_component = zeros(h_hr,w_hr,gradient_zdim);
    
    %Component setting
    componentlandmarkset = cell(4,1);
    setname = cell(4,1);
    componentlandmarkset{1} = 49:68;        %mouth
    componentlandmarkset{2} = 18:27;        %eyebrows
    componentlandmarkset{3} = 37:48;        %eyes
    componentlandmarkset{4} = 28:36;        %nose
    setname{1} = 'mouth';
    setname{2} = 'eyebrows';
    setname{3} = 'eyes';
    setname{4} = 'nose';
    
    
    landmarksetnumber = length(componentlandmarkset);
    for k=1:landmarksetnumber
        set = componentlandmarkset{k};
        switch setname{k}
            case 'mouth'
                [mask_lr, mask_hr] = F32_ComputeMask_Mouth(landmarks_test);
                bglassavoid = false;
            case 'eyebrows'
                [mask_lr, mask_hr] = F33_ComputeMask_Eyebrows(landmarks_test);
                bglassavoid = true;
            case 'eyes'
                [mask_lr, mask_hr] = F34_ComputeMask_Eyes(landmarks_test);
                bglassavoid = true;
            case 'nose'
                [mask_lr, mask_hr] = F35_ComputeMask_Nose(landmarks_test);
                bglassavoid = true;
        end
        
        basepoints = landmarks_test(set,:);
        inputpoints = rawexamplelandmarks(set,:,:);
        fprintf('running %s\n',setname{k});
        [retrievedhrimage, retrievedlrimage, retrivedidx, alignedexampleimage_hr, alignedexampleimage_lr] = ...
            F6d_RetriveImage_DrawFlowChart(img_y, ...
            rawexampleimage, inputpoints, basepoints, mask_lr, para.zooming, para.Gau_sigma, glasslist, bglassavoid);
        %find three images and dump them
        %        if strcmp(setname{k},'eyes')
        %            exampleimagenumber = size(alignedexampleimage_hr,3);
        %            folder_save = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Illustration','FlowChart2');
        %            for ii=1:exampleimagenumber
        %                switch examplefilenamelist{ii}
        %                    case '014_02_02_051_05.png'
        %                    case '024_01_01_051_07.png'
        %                    case '031_03_02_051_05.png'
        %                        fn_example = examplefilenamelist{ii};
        %                        fn_short = fn_example(1:end-4);
        %                        fn_save = [fn_short '_aligned_hr.png'];
        %                        imwrite(alignedexampleimage_hr(:,:,ii),fullfile(folder_save,fn_save));
        %                        fn_save = [fn_short '_aligned_lr.png'];
        %                        imwrite(alignedexampleimage_lr(:,:,ii),fullfile(folder_save,fn_save));
        %                    otherwise
        %                end
        %            end
        %        end
        retrievedidxrecord(k) = retrivedidx;
        retrievedhrimagerecord{k} = retrievedhrimage;
        retrievedlrimagerecord{k} = retrievedlrimage;
        
        [r_set, c_set] = find(mask_hr);
        top = min(r_set);
        bottom = max(r_set);
        left = min(c_set);
        right = max(c_set);
        
        originalgradients = gradientwholeimage(top:bottom,left:right,:);
        retrievedgradients_wholeimage = F14_Img2Grad(im2double(retrievedhrimage));
        retrievedgradients = retrievedgradients_wholeimage(top:bottom,left:right,:);
        mask_region = mask_hr(top:bottom,left:right);
        
        gradientwholeimage(top:bottom,left:right,:) = ...
            retrievedgradients.* repmat(mask_region,[1 1 8]) + ...
            originalgradients .* repmat(1-mask_region,[1 1 8]);
        gradient_component(top:bottom,left:right,:) = retrievedgradients .* repmat(mask_region,[1 1 8]);
        mask_lr_record{k} = mask_lr;
        mask_hr_record{k} = mask_hr;
    end
    
    
    %solve optimization problem
    if exist('img_edge','var');
        img_initial = img_edge;
    else
        img_initial = img_bb;       %change here to img_edge when img_edge is ready
    end
    Grad_exp = gradientwholeimage;
    Gau_sigma = para.Gau_sigma;
    
    %this step is very critical, if the optimization is not strong enough, the textural details do not show
    %so, F4d is too weak to be used here
    bReport = true;
    img_out = F4b_GenerateIntensityFromGradJpeg(img_y,img_initial,1.5 * Grad_exp,Gau_sigma,bReport,Quality);
    
    img_out_ycbcr = img_out;
    img_out_ycbcr(:,:,2:3) = TV(img_color,0.05, 20);
    img_out_rgb = ycbcr2rgb(img_out_ycbcr);
    if Quality~=100
        img_out_rgb = T1_Facesmoother(uint8(img_out_rgb*256));
    else
        img_out_rgb = uint8(img_out_rgb*256);
    end
    fn = sprintf('%s_%s_%d_%d.png',fn_testshort,para.legend,para.setting,para.tuning);
    fm = sprintf('gray_%s_%s_%d_%d.png',fn_testshort,para.legend,para.setting,para.tuning);
    imwrite(img_out_rgb, fullfile(finalsavefolder,fn));
    imwrite(img_out,fullfile(finalsavefolder,fm))
    
    %save data
    gradient_final = gradientwholeimage;
    fn_save = sprintf('%s_%s_%d_%d_data.mat',fn_testshort,para.legend,para.setting,para.tuning);
    save(fullfile(finalsavefolder,fn_save),'mask_hr_record','mask_lr_record','retrievedidxrecord',...
        'retrievedhrimagerecord','retrievedlrimagerecord','img_color','weightmap_edge',...
        'gradient_edge','gradient_component','gradient_final');
end
