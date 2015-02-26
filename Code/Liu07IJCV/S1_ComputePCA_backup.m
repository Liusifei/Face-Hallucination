%08/09/12
%Compute PCA

%load image
para.exampleimagefolder = fullfile('Example','HRGray');
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
featuremean = mean(featurematrix,2);
imagemean = reshape(featuremean, [h w]);
%here we can see a problem of Liu's method: the training faces require precise alignment
X = featurematrix - repmat(featuremean, [1 filenumber]);
%note here the function of cov use row vector
covariancematrix = cov(X');   %the function out of memroy, too.
[W, eigenvaluematrix] = eig(covariancematrix);
%be aware here that the first eigenvalue is the smallest one
eigenvalue = diag(eigenvaluematrix);

%reorder the eigenvalues and eigenvectors
eigenvalue = eigenvalue(end:-1:1);
W = W(:,end:-1:1);
W = W';  

%generate the coordinate in PCA subspace
pc = W * X';
clear featurematrix