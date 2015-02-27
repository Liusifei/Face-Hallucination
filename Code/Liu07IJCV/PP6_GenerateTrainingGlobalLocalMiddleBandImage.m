%Chih-Yuan Yang, EECS, UC Merced
%Last Modified: 08/22/12
%Implement Liu07 methods, Generate patch pairs of middle band and high band

lrimagefolder = fullfile('Examples','TrainingFaces_LRGray');
groundtruthimagefolder = fullfile('Examples','TrainingFaces_Gray');
filelist = dir(fullfile(groundtruthimagefolder, '*.png'));
filecount = length(filelist);

    %load the offline trained data
savefolder = 'LearnedResult';
% load(fullfile(savefolder,'CMuLambda.mat'),'CCCterm','mu','lambda','r','B');
load(fullfile(savefolder,'CMuLambda_old.mat'),'CCCterm','mu','lambda','r','B');

generatedglobalimagefolder = fullfile('LearnedResult','GeneratedGlobalImages');
if ~exist(generatedglobalimagefolder, 'dir')
    mkdir(generatedglobalimagefolder);
end

groundtruthimagefolder = fullfile('Examples','TrainingFaces_Gray');
localpatchfolder = fullfile('LearnedResult','LocalPatch');
if ~exist(localpatchfolder,'dir')
    mkdir(localpatchfolder)
end

para.bdumpgeneratedglobalimage = false;
para.bdumplocalimage = true;
para.bdumpmiddlebandimage = true;

%Compute A mu
scaling = 4;
gau_sigma = 1.6;
h = 320;
w = 240;
lh = h/scaling;
lw = w/scaling;
img_mu = reshape(mu, [h w]);
img_Amu = U3_GenerateLRImage_BlurSubSample(img_mu, scaling, gau_sigma);
Amu = reshape(img_Amu, [lh*lw 1] );

%allocate space
generatedglobalimage = zeros(h,w,filecount);
filenamelist = cell(filecount,1);
for fileidx=1:filecount
    %open specific file
    fn_testfile = filelist(fileidx).name;
    filenamelist{fileidx} = fn_testfile;
    img_y = im2double(imread( fullfile(lrimagefolder,fn_testfile)) );

    %compute the (C^t C)^-1 C^t (I_l - A mu) from here
    img_y_array = reshape(img_y, [lh*lw 1]);
    X = CCCterm * (img_y_array - Amu);
    %generate the HR intensity image BX + mu
    vector_generated = B*X + mu;
    img_generated = reshape(vector_generated, [h w] );
    %dump the image
    if para.bdumpgeneratedglobalimage
        fn_testfile_short = fn_testfile(1:end-4);
        savename = fullfile(generatedglobalimagefolder, sprintf('%s%s',fn_testfile_short ,'_Lui07_Step1.png'));
        imwrite(img_generated,savename);
    end
   
    %preserve the generated image
    generatedglobalimage(:,:,fileidx) = img_generated;
end
%save the generated images as a MATLAB file
save(fullfile(localpatchfolder,'generatedglobalimage'),'generatedglobalimage','filenamelist');

%compute the local image (ground truth image minus generated global image)
localimage = zeros(h,w,filecount);
localimagedumpfolder = fullfile('DumpedImage','LocalImage');
if ~exist(localimagedumpfolder,'dir')
    mkdir(localimagedumpfolder);
end
for fileidx=1:filecount
    fn_testfile = filelist(fileidx).name;
    img_gt = im2double(imread( fullfile(groundtruthimagefolder,fn_testfile)) );
    img_global = generatedglobalimage(:,:,fileidx);
    img_local = img_gt - img_global;
    localimage(:,:,fileidx) = img_local;
    %dump some image as an illustration
    if para.bdumplocalimage
        hfig = figure;
        imagesc(localimage(:,:,fileidx));
        colorbar
        colormap gray
        saveas(hfig,fullfile(localimagedumpfolder,fn_testfile));
        close(hfig);
    end
end

%generate middle bank of the generated global image
kernelwidth = 1.6;          %this is a hyper parameter. tune it
hsize =11;
kernel = fspecial('gaussian',hsize,kernelwidth);
middlebandimage = zeros(h,w,filecount);
middlebandimagedumpfolder = fullfile('DumpedImage','MiddleBandImage');
if ~exist(middlebandimagedumpfolder,'dir')
    mkdir(middlebandimagedumpfolder);
end
for fileidx=1:filecount
    fn_testfile = filelist(fileidx).name;
    middlebandimage(:,:,fileidx) = imfilter(generatedglobalimage(:,:,fileidx),kernel,'replicate');
    if para.bdumpmiddlebandimage
        imwrite(middlebandimage(:,:,fileidx),fullfile(middlebandimagedumpfolder,fn_testfile));
    end
end

%save the middlebandimage and localimage as 
fn_save = fullfile('LearnedResult','MiddleBandAndLocalImage');
save(fn_save,'middlebandimage','localimage','kernelwidth','hsize','filenamelist','-v7.3');