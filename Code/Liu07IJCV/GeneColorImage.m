function GeneColorImage(savefolder, HRdir, LRdir)
if ~exist('savefolder','var')
   savefolder = '\\vision-u1\Research\120801SRForFace\code\Liu07_2Alignment\Result\Upfrontal3\';
end
addpath(genpath('\\vision-u1\Research\120801SRForFace\code\Lib'));
flag = 0;
factor = 4;
if ~exist('LRdir','var')
    LRdir = '\\vision-u1\Research\120801SRForFace\code\Ours2\Source\Upfrontal3\Input\';
end
if ~exist('HRdir','var')
    HRdir = '\\VISION-U1\Sfliu\Liu07IJCV\sf_results_new\';
    flag = 1;
end
if ~exist(savefolder,'dir')
    mkdir(savefolder);
end

if flag
    hrfile = dir([HRdir,'SPIMG_*.png']);
    for m = 1:length(hrfile)
        disp(m);
        lname = hrfile(m).name;
        fname = lname(7:end);
        lrim = im2double(imread([LRdir,fname]));
%         lrim = (lrim-min(lrim(:)))/(max(lrim(:))-min(lrim(:)));
        hrim = im2double(imread([HRdir,lname]));
%         hrim = (hrim-min(hrim(:)))/(max(hrim(:))-min(hrim(:)));
        lryiq = RGB2YIQ(lrim);
        ColorImg = imresize(lryiq,factor,'bicubic');
        ColorImg(:,:,1) = hrim;
        ColorImg = YIQ2RGB(ColorImg);
        imwrite(ColorImg,[savefolder,fname]);
    end
else
    hrfile = dir([HRdir,'*.png']);
    for m = 1:length(hrfile)
        fname = hrfile(m).name;
        lrim = imread([LRdir,fname]);
        hrim = imread([HRdir,fname]);
%         hrim = uint8(((hrim-min(hrim(:)))/(max(hrim(:))-min(hrim(:))))*255);
        lryiq = RGB2YIQ(lrim);
        ColorImg = imresize(lryiq,factor,'bicubic');
        ColorImg(:,:,1) = hrim;       
%         ColorImg = YIQ2RGB(ColorImg);
        imwrite(ColorImg,[savefolder,fname]);
    end
end
