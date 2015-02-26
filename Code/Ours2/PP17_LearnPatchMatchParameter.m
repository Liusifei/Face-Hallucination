%Chih-Yuan Yang
%10/12/12
%Learn the best parameter for PatchMatch

clc
clear
close all

codefolder = fileparts(pwd);
addpath(genpath(fullfile(codefolder,'Lib')));

para.zooming = 4;
para.detectedlandmarkfolder = fullfile('Temp','DetectedLandmarks','MultiPIE');
para.loadfolder = fullfile('Examples','Upfrontal','PreparedMatForLoad');
para.loadname = 'ExampleDataForLoad.mat';
imageidxstart = 5;
imageidxend = 'all';
patchsize = 5;
savefolder = fullfile('Learn','PatchMatch','Upfrontal');
warray = 0:0.05:1;
U22_makeifnotexist(savefolder);

zooming = para.zooming;
if zooming == 4
    Gau_sigma = 1.6;
elseif zooming == 3
    Gau_sigma = 1.2;
end

%load all training images
loaddata = load(fullfile(para.loadfolder,para.loadname),'exampleimages','exampleimages_lr','landmarks');
rawexamplelandmarks = loaddata.landmarks;
rawexampleimages = loaddata.exampleimages;
landmarks = loaddata.landmarks;
clear loaddata
if matlabpool('size') == 0
    matlabpool open local 4
end

wlength = length(warray);
trainingimagenumber = size(rawexampleimages,3);
set = 28:48;  %eyes and nose

patcharea = patchsize * patchsize;
h_lr = 120;
w_lr = 160;
h_lr_active = h_lr-patchsize+1;
w_lr_active = w_lr-patchsize+1;
[cc rr] = meshgrid(1:w_lr_active,1:h_lr_active);
rawlocationfeature = cat(3,rr,cc);

if isa(imageidxend,'char')
    if strcmp(imageidxend,'all')
        imageidxend = trainingimagenumber;
    end
end
for j=imageidxstart:imageidxend
    testimage_hr = im2double(rawexampleimages(:,:,j));
    testimage_lr = F19a_GenerateLRImage_GaussianKernel(testimage_hr, zooming,Gau_sigma); 
    validationimages = rawexampleimages(:,:,[1:j-1,j+1:end]);
    landmarks_test = landmarks(:,:,j);
    landmarks_validation = landmarks(:,:,[1:j-1,j+1:end]);
    basepoints = landmarks_test(set,:);
    inputpoints = rawexamplelandmarks(set,:,:);

    validateimagenumber = trainingimagenumber-1;
    alignedexampleimage_hr = zeros(480,640,validateimagenumber,'uint8');     %set as uint8 to reduce memory demand
    alignedexampleimage_lr = zeros(120,160,validateimagenumber);
    disp('align images');
    parfor k=1:validateimagenumber
        alignedexampleimage_hr(:,:,k) = F18_AlignExampleImageByLandmarkSet(validationimages(:,:,k),inputpoints(:,:,k),basepoints);
        %F19 automatically convert uint8 input to double
        alignedexampleimage_lr(:,:,k) = F19a_GenerateLRImage_GaussianKernel(alignedexampleimage_hr(:,:,k),zooming,Gau_sigma);
    end
    %extract features, position plus intensity
    intensityfeature_dataset = zeros(h_lr_active,w_lr_active,patcharea,trainingimagenumber-1);
    disp('extract appearance feature');
    parfor ii = 1:validateimagenumber
        for r=1:h_lr_active
            for c=1:w_lr_active
                intensityfeature_dataset(r,c,:,ii) = reshape(alignedexampleimage_lr(r:r+patchsize-1,c:c+patchsize-1,ii),[patcharea 1]);
            end
        end
    end
    intensityfeature_query = zeros(h_lr_active,w_lr_active,patcharea);
    parfor r=1:h_lr_active
        for c=1:w_lr_active
            intensityfeature_query(r,c,:) = reshape(testimage_lr(r:r+patchsize-1,c:c+patchsize-1),[patcharea 1]);
        end
    end
    
    cores = 2;    % Use more cores for more speed
    if cores==1
      algo = 'cpu';
    else
      algo = 'cputiled';
    end
    patch_w = 1;        %because we are using discriptor mode
    nn_iters = 5;
    numberofHcandidate = 1;
    hrpatchextractdata = zeros(h_lr_active,w_lr_active,numberofHcandidate,3);      %ii,r_lr_src,c_lr_src
    
    %there is the problem, I can't get the L2norm, can I modify the C++ code? but it is troublesome.
    xy = zeros(h_lr_active,w_lr_active,3,validateimagenumber,'uint32');
    l2norm = zeros(h_lr_active,w_lr_active,validateimagenumber);
    l2normaverage = zeros(wlength,1);
    for i=1:wlength
        w = warray(i);
        weightadjustlocationfeature = w*rawlocationfeature;
        A = cat(3,weightadjustlocationfeature,intensityfeature_query);
        %run patch match
        fprintf('run PatchMatch w=%0.3f\n',w);
        parfor ii=1:validateimagenumber
            %run patchmatch
            B = cat(3,weightadjustlocationfeature,intensityfeature_dataset(:,:,:,ii));
            xy(:,:,:,ii) = nnmex(A, B, algo, patch_w, nn_iters, [], [], [], [], cores);       %the return totalpatchnumber int32
            l2norm(:,:,ii) = F41_ComputePatchSimilarity(A,B,xy(:,:,:,ii));
        end
        
        %find the min l2norm along all validate images
        disp('extract HR patch');
        [~,ix] = min(l2norm,[],3);
        for r=1:h_lr_active
            for c=1:w_lr_active
                ii_source = ix(r,c);
                x_source = xy(r,c,1,ii_source);
                y_source = xy(r,c,2,ii_source);
                r_source = y_source+1;
                c_source = x_source+1;
                hrpatchextractdata(r,c,1,:) = cat(4,ii_source,r_source,c_source); 
            end
        end
        %retrieve the HR patches
        hrpatch = F39_ExtractAllHrPatches(patchsize,zooming, hrpatchextractdata,alignedexampleimage_hr);
        hrpatch = F40_CompensateHRpatches(hrpatch, testimage_lr, zooming, hrpatchextractdata,alignedexampleimage_lr);
        
        %compute the error rate
        top = zooming*((patchsize-1)/2)+1;
        bottom = top+zooming-1;
        left = zooming*((patchsize-1)/2)+1;
        right = left+zooming-1;
        l2normrecord = zeros(h_lr_active,w_lr_active);
        for r=1:h_lr_active
            rh0 = (r-1)*zooming;
            rh1 = rh0+top;
            rh2 = rh0+bottom;
            for c=1:w_lr_active
                ch0 = (c-1)*zooming;
                ch1 = ch0+left;
                ch2 = ch0+right;
                region_gt = testimage_hr(rh1:rh2,ch1:ch2);
                region_retrieved = hrpatch(top:bottom,left:right,r,c);
                diff = region_gt - region_retrieved;
                l2normrecord(r,c) = sqrt(mean2(diff.^2));
            end
        end
        %compute the average l2norm, for a weight value
        l2normaverage(i) = mean2(l2normrecord);
    end
    %save the result of a test image
    fn_save = sprintf('weighttestresult_%05d.mat',j);
    save(fullfile(savefolder,fn_save),'l2normaverage','warray','l2normrecord');
end