%Chih-Yuan Yang
%2/21/15
%I would like to figure out Sifie's code. Why does she only use 480 training
%face images rather than the 2184 ones? In fact, Sifei only uses 50 example
%images randomly selected from the 480 training set. She told me that Ma's
%algorithm can not work if the number of example images exceeds the
%number of pixels in a patch.

clear
close all
clc

folder_code = fileparts(pwd);
folder_ours = fullfile(folder_code, 'Ours2');
folder_lib = fullfile(folder_code,'Lib');
addpath(fullfile(folder_lib,'YIQConverter'));
addpath(fullfile(folder_lib,'BilateralFilter'));
folder_filelist = fullfile(folder_ours, 'Filelist');
addpath(folder_ours);
folder_save = fullfile('Result',mfilename);
U22_makeifnotexist(folder_save);

idx_file_start = 1;
idx_file_end = 'all';
str_legend = 'Ma10_test3';

%fn_filelist = 'PubFig2_2Foundable_JPEGCompressed25_50_75_100.txt';
%folder_test = fullfile(folder_ours,'Source','PubFig2_2Foundable','JPEGCompressed');
fn_filelist = 'MultiPIE_NonUpfrontal3_JPEGCompressed.txt';
folder_test = fullfile(folder_ours,'Source','NonUpfrontal3','Input','JPEGCompressed');


array_filename = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_file = length(array_filename);
if isa(idx_file_end,'char')
    if strcmp(idx_file_end,'all')
        idx_file_end = num_file;
    end
end


% Setting Path
TrainingLow = fullfile('Data','Sele_TrainingFaces_LRGray');
folder_example_image_HR = fullfile(folder_ours, 'Examples','NonUpfrontal3','Training');

% =================Generating Training Patches====================
% set parameters
Lpatchsize = 10;
Linterval = 5;
scalingfactor = 4;
Gaussian_sigma = 1.6;

array_example_images_HR = dir(fullfile(folder_example_image_HR,'*.png'));
number_example_images = length(array_example_images_HR);
for index_image = 1:number_example_images
    image_HR = imread(fullfile(folder_example_image_HR,array_example_images_HR(index_image).name));
    if size(image_HR,3) == 3
        image_HR = rgb2gray(image_HR);
    end
    [patches,max_x,max_y] = im2patches(image_HR, Lpatchsize*scalingfactor, Linterval*scalingfactor);
    if index_image==1
        HRpathchesFull = uint8(zeros(size(patches,1),size(patches,2),number_example_images));
    end
    HRpathchesFull(:,:,index_image) = patches;
    %2/21/15 Sifei's format here is weird. She uses double class, but the range is 0~255. I have no
    %time to trace more deeply so that I only can follow her format.
    image_LR = 255*F19c_GenerateLRImage_GaussianKernel(image_HR, scalingfactor, Gaussian_sigma);
    [patches,max_x,max_y] = im2patches(image_LR, Lpatchsize, Linterval);
    if index_image==1
        LRpatchesFull = zeros(size(patches,1),size(patches,2),number_example_images);
    end
    LRpatchesFull(:,:,index_image) = patches;
end



% Testing: 
% 1 downsample; 2 caculating w; 3 synthesis HR patches; 4 Present Patches
pk = 50;
for idx_file = idx_file_start:idx_file_end
    fprintf('Processing %.4d test image...\n',idx_file);
    % generating LR testing image
    fn_test = array_filename{idx_file};
    fn_short = fn_test(1:end-4);
    fn_save = sprintf('%s_%s.png', fn_short, str_legend);    
    if exist(fullfile(folder_save,fn_save),'file')
        fprintf('output file exist\n');
        %If this an empty file, its previous program may crash already. Check the size and created time
        fileinfo = dir(fullfile(folder_save,fn_save));
        if fileinfo(1).bytes == 0
            date_difference_day = now - datenum(fileinfo(1).date);
            date_difference_hour = date_difference_day * 24;
            if date_difference_hour > 3
                %overwrite the existing empty file
                fprintf('Overwrite the exiting empty file %s\n', fn_save);
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
    
    img_read = im2double(imread(fullfile(folder_test, fn_test)));
    img_yiq = RGB2YIQ(img_read);
    img_y = img_yiq(:,:,1);
    im = im2uint8(img_y);
    img_iq = img_yiq(:,:,2:3);
    [patches,max_x,max_y] = im2patches(im, Lpatchsize, Linterval);
    LRreco = patches;
    HRreco = uint8(zeros(size(patches,1),size(patches,2)*scalingfactor^2));
    [pn,pl] = size(patches);
    C = ones(pk,1);
    w = zeros(pn,pk);
    pn_ind = zeros(pn,pk);
    % caculating w for each position
    for k = 1:pn
        test_P = double(patches(k,:)');
        rn = randperm(number_example_images);
        rind = rn(1:pk);
        pn_ind(k,:) = rind;
        Y = reshape(LRpatchesFull(k,:,rind),[pl, pk]);
        X = test_P * C';
        Z = (X-Y)' * (X-Y);
        w(k,:) = ((Z+ eye(pk))\ C)/(C'* (Z+ eye(pk))^(-1) * C);
        % check LR reconstruction
        LRreco(k,:) = Y * w(k,:)'; 
        % check HR reconstruction
        HY = reshape(HRpathchesFull(k,:,rind), pl*scalingfactor^2, pk);
        HRreco(k,:) = double(HY) * w(k,:)'; 
    % HRreco(k,:) = double(HY) * ones(100,1)/100; 
    end   
    Cons_a = LayoutPatches(LRreco, size(im), Linterval, Lpatchsize);
    Cons_a = (Cons_a - min(Cons_a(:)))/(max(Cons_a(:))-min(Cons_a(:)));
%    imwrite(Cons_a,[RCtestLow,'\','RC_',HRtestdir(idx_file).name]);
    % Reconstruction of HR faces
    Cons_ha = LayoutPatches(HRreco, size(im).* scalingfactor, Linterval * scalingfactor, Lpatchsize * scalingfactor);
    %----------------------------------------------------------------------
    % Biliteral Filtering
    %----------------------------------------------------------------------
    SP_IMG = bfilter2((Cons_ha-min(Cons_ha(:)))/(max(Cons_ha(:))-min(Cons_ha(:))), 3,[1.5,0.1]);
    img_y_hr = SP_IMG;
%    imwrite(SP_IMG,[RCtestHigh,'\','RC_',HRtestdir(idx_file).name]);
    
    %Combine the Y and IQ channels
    img_iq_hr = imresize(img_iq, scalingfactor );
    img_yiq_hr = cat(3,img_y_hr,img_iq_hr);
    img_rgb_hr = YIQ2RGB(img_yiq_hr);
    imwrite(img_rgb_hr,fullfile(folder_save, fn_save));
end
