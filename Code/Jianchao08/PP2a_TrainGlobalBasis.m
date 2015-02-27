%Chih-Yuan Yang
%10/25/12
%Training global constraint, the basis
%PP2a: change the inital W as D, see whether the objective term converge faster

clear;
close all
clc;

codefolder = fileparts(pwd);
exampleimagefolder = fullfile(codefolder,'Ours2','Examples','Upfrontal3','Training');
exampleMATfolder = fullfile(codefolder,'Ours2','Examples','Upfrontal3','PreparedMatForLoad');
fn_exampleMAT = 'ExampleDataForLoad.mat';
addpath(fullfile(codefolder,'Ours2'));
savefolder = fullfile('Data','Upfrontal3','s4');
fn_save = 'BasisW.mat';
U22_makeifnotexist(savefolder);

%load all training face
loaddata = load(fullfile(exampleMATfolder,fn_exampleMAT),'exampleimages_hr');
exampleimages_hr = loaddata.exampleimages_hr;
[h_hr, w_hr, imagenumber] = size(exampleimages_hr);
n = h_hr*w_hr;
m = imagenumber;
D = zeros(n,m);       %linearize each image
for ii=1:imagenumber
    D(:,ii) = double(reshape(exampleimages_hr(:,:,ii),[n,1]));
end
%compute H and W from D
r = round(n*m/(n+m));
H = rand(r,m);            %can not use eye, some columns are pure zeros and produce 0 in the denominator
H = cat(2,eye(r),rand(r,m-r));
W = D(:,1:r);            %how to initialize it?
figs = zeros(3);
for j=1:3
    figs(j) = figure;
end

diff = D-W*H;
object_initial = sum(sum(diff.^2));
fprintf('object_initial=%f\n',object_initial);

for i=1:50
    fprintf('iteration i=%d ',i);
    WtD = W'*D;
    WtWH = W'*W*H;
    H = H.*WtD./WtWH;
    DHt = D*(H');
    WHHt = W*(H*H');
    W = W.*DHt./WHHt;
    %check the convergence
    W_afterupdate = W;
    diff = D-W*H;
    object_afterupdate = sum(sum(diff.^2));
    fprintf(' object=%f\n',object_afterupdate);
    for j=1:3
        figure(figs(j));
        imshow(reshape(W(:,j),[h_hr,w_hr])/255);
    end
    drawnow
    %check the correctness
    if nnz(W<0) > 1
        error('W contains negative');
    end
    if nnz(H<0) > 1
        error('H contains negative');
    end
    
end
%save the computed bases
save(fullfile(savefolder,fn_save),'W');