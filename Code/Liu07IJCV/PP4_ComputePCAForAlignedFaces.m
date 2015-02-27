%08/22/12
%Compute PCA

clear
%load image
para.exampleimagefolder = fullfile('Examples','TrainingFaces_Gray');
filelist = dir(fullfile(para.exampleimagefolder,'*.png'));
filenumber = length(filelist);
%allocate space
fn = filelist(1).name;
im8 = imread(fullfile(para.exampleimagefolder,fn));
[h w] = size(im8);
featurematrix = zeros(h*w,filenumber);

for i=1:filenumber
    if mod(i,100) == 0
        fprintf('load image %d\n',i);
    end
    fn = filelist(i).name;
    im8 = imread(fullfile(para.exampleimagefolder,fn));
    imd = im2double(im8);
    %convert to an array
    imv = reshape(imd, [h*w 1]);
    featurematrix(:,i) = imv;
end

%Compute PCA
options.PCARatio = 1;
[B, lambda, mu, elapse] = PCA(featurematrix,options);
%all eigenvectors are normalized

imagemean = reshape(mu, [h w]);
eigenvector1 = B(:,1);
eigenvalue1 = lambda(1);
%the most significant change is the color of clothing and the illumination
savefolder = 'EigenImage';
if ~exist(savefolder, 'dir')
    mkdir(savefolder);
end
idx = 0;
for i=-5:5
    fig = figure;
    testfeature = mu + i*eigenvector1*sqrt(eigenvalue1)/100;
    %chech this image
    imagecheck = reshape(testfeature,[h w]);
    imshow(imagecheck);
    title(sprintf('%d',i));
    idx = idx+1;
    saveas(fig,fullfile(savefolder,sprintf('eigen%d(%d).png',idx,i)));
end
close all

%unable to compute the matrix A (downsampling matrix) L = A*H
%because of out of memory
%However, AB is much smaller than A, so let's compute AB
s=4;
sigma = 1.6;
H_length = w*h;
L_length = w/4 * h/4;
r = length(lambda);
C = zeros(L_length,r);
for i=1:r
    theeigenvector = B(:,i);
    imageaseigenvector = reshape(theeigenvector, h,w);
    L = U3_GenerateLRImage_BlurSubSample(imageaseigenvector, s, sigma);
    L_vector = reshape(L,L_length,1);
    C(:,i) = L_vector;
end

%Compute the (C^t C)^-1 C^t term here
CCCterm = ((C'*C)\C'); 
savefolder = 'LearnedResult';
if ~exist(savefolder,'dir')
    mkdir(savefolder);
end
save(fullfile(savefolder,'CMuLambda_old'),'B','C','mu','lambda','r','CCCterm','-v7.3');
