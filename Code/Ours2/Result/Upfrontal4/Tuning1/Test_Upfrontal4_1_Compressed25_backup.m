%Chih-Yuan Yang
%4/29/13
%Compressed face hallucination
%I need to execute this file on linux so that the UCI face detection libaray can work
clc
clear
close all

codefolder = fileparts(pwd);
projectfolder = fileparts(codefolder);
addpath(genpath(fullfile(codefolder,'Lib')));
    
para.zooming = 4;
para.settingname = 'Upfrontal';
para.testimagefolder = fullfile('Source','Upfrontal4_Compressed','25');
para.savefolder = 'GeneratedImages';
para.setting = 4;
para.settingnote = 'Run for compressed face images';
para.tuning = 1;
para.tuningnote = 'compression parameter 25';
para.legend = 'Ours';
para.model = 'mi';
para.detectedlandmarkfolder = fullfile('Temp','DetectedLandmarks','Upfrontal3');
para.glasslistfolder = fullfile('Examples','Upfrontal3');
para.loadfolder = fullfile('Examples','Upfrontal3','PreparedMatForLoad');
para.loadname = 'ExampleDataForLoad.mat';

fileidx_start = 2;
fileidx_end = 'all';

para.mainfilename = mfilename;

if para.zooming == 4
    para.Gau_sigma = 1.6;
elseif para.zooming == 3
    para.Gau_sigma = 1.2;
end

resultfolder = 'Result';
para = U23a_PrepareResultFolder(resultfolder, para);

%load all training images
loaddata = load(fullfile(para.loadfolder,para.loadname),'exampleimages_hr','exampleimages_lr','landmarks');
rawexamplelandmarks = loaddata.landmarks;
rawexampleimage = loaddata.exampleimages_hr;
allLRexampleimages = loaddata.exampleimages_lr;
clear loaddata
if matlabpool('size') == 0
    matlabpool open local 4
end
finalsavefolder = fullfile(para.tuningfolder, para.savefolder);
U22_makeifnotexist(finalsavefolder);

%load glass list
fid = fopen(fullfile(para.glasslistfolder,'GlassList.txt'),'r+');
C = textscan(fid,'%05d %s %d\n');
fclose(fid);
glasslist = C{3};
examplefilenamelist = C{2};
clear C fid

filelist = dir(fullfile(para.testimagefolder, '*.jpg'));
filenumber = length(filelist);
if isa(fileidx_end,'char')
    if strcmp(fileidx_end,'all')
        fileidx_end = filenumber;
    end
end
for fileidx=fileidx_start:fileidx_end
    %open specific file
    fn_test = filelist(fileidx).name;
    fprintf('fileidx %d, fn_test %s\n',fileidx,fn_test);
    imd = im2double(imread(fullfile(para.testimagefolder,fn_test)));
    img_yiq = RGB2YIQ(imd);
    img_y = img_yiq(:,:,1);
    IQLayer = img_yiq(:,:,2:3);
    zooming = para.zooming;
    IQLayer_upsampled = imresize(IQLayer,zooming);
    img_bb = imresize(img_y,zooming);
    
    %04/29/13 change here, run face detection online
    img_bb_color = imresize(imd,zooming);
    %bicubic interpolation generates some values less than 0 or greater
    %than 1. We need to clear them.
    img_bb_color(img_bb_color > 1) = 1;
    img_bb_color(img_bb_color < 0) = 0;
    modelname = 'mi';    
    [bs, posemap] = F2_ReturnLandmarks(img_bb_color,modelname);   
    %assume the test file has been detected
    %load computed data
     fn_testshort = fn_test(1:end-4);
%     fn_load = sprintf('%s_mi.mat',fn_testshort);
%     fn_load_full = fullfile(para.detectedlandmarkfolder,fn_load);
%     if ~exist(fn_load_full,'file')
%         continue     %no UCI detected results, go to next or reduce the threshold
%     end
%     loaddata = load(fn_load_full);
%     bs = loaddata.bs(1);

    landmarks_test = F4_ConvertBStoMultiPieLandmarks(bs);
    [gradients_texture, img_texture, img_texture_backprojection] = ...
        F37f_GetTexturePatchMatch_Aligned(img_y, rawexampleimage, allLRexampleimages, landmarks_test, rawexamplelandmarks);
    
    
    [gradient_edge, weightmap_edge] = F21e_EdgePreserving_GaussianKernel(img_y,para.zooming,para.Gau_sigma);
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
    img_out = F4b_GenerateIntensityFromGradient(img_y,img_initial,Grad_exp,Gau_sigma,bReport);

    img_out_yiq = img_out;
    img_out_yiq(:,:,2:3) = IQLayer_upsampled;
    img_out_rgb = YIQ2RGB(img_out_yiq);
    fn = sprintf('%s_%s_%d_%d.png',fn_testshort,para.legend,para.setting,para.tuning);
    imwrite(img_out_rgb, fullfile(finalsavefolder,fn));
    
    %save data
    gradient_final = gradientwholeimage;
    fn_save = sprintf('%s_%s_%d_%d_data.mat',fn_testshort,para.legend,para.setting,para.tuning);
    save(fullfile(finalsavefolder,fn_save),'mask_hr_record','mask_lr_record','retrievedidxrecord',...
        'retrievedhrimagerecord','retrievedlrimagerecord','img_texture','img_texture_backprojection','weightmap_edge',...
        'gradient_edge','gradient_component','gradient_final');
end 
    