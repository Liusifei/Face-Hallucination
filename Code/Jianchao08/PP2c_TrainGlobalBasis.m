%Chih-Yuan Yang
%10/25/12
%Training global constraint, the basis
%PP2a: change the inital W as D, see whether the objective term converge faster
%PP2b: save data in each iteration to resume
%PP2c: use input face as initial face
clear;
close all
clc;

codefolder = fileparts(pwd);
exampleimagefolder = fullfile(codefolder,'Ours2','Examples','Upfrontal3','Training');
exampleMATfolder = fullfile(codefolder,'Ours2','Examples','Upfrontal3','PreparedMatForLoad');
fn_exampleMAT = 'ExampleDataForLoad.mat';
addpath(fullfile(codefolder,'Ours2'));
savefolder = fullfile('Data','Upfrontal3','s4');
setting = 2;
fn_save = 'BasisW.mat';
fn_temp = sprintf('TempDHWi_setting%d.mat',setting);
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
H = cat(2,eye(r),rand(r,m-r));
W = D(:,1:r);            %how to initialize it?
figs = zeros(3);
for j=1:3
    figs(j) = figure;
end

diff = D-W*H;
object_beforeupdate = sum(sum(diff.^2));

if exist(fullfile(savefolder,fn_temp),'file')
    load(fullfile(savefolder,fn_temp),'D','W','H','i','object_afterupdate');
else
    i = 1;
end

thd = 100000000;
while true
    fprintf('iteration i=%d ',i);
    if exist('object_afterupdate','var')
        object_beforeupdate = object_afterupdate;
    else
        diff = D-W*H;
        object_beforeupdate = sum(sum(diff.^2));
        fprintf('object_beforeupdate=%f ',object_beforeupdate);
    end
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
    fprintf(' object_afterupdate=%f\n',object_afterupdate);
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
    save(fullfile(savefolder,fn_temp),'D','W','H','i','object_afterupdate');
    objdiff = object_beforeupdate - object_afterupdate;
    if objdiff < thd
        break
    end
    i = i+1;
end
%save the computed bases
save(fullfile(savefolder,fn_save),'W');