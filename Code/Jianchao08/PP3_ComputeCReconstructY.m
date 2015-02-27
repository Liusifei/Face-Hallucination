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
folder_exampleimages = fullfile(codefolder,'Ours2','Examples','NonUpfrontal3','Training');
fileext = '.png';
exampleMATfolder = fullfile(codefolder,'Ours2','Examples','NonUpfrontal3','PreparedMatForLoad');
fn_exampleMAT = 'ExampleDataForLoad.mat';
addpath(fullfile(codefolder,'Ours2'));
folder_save = fullfile('Data','NonUpfrontal3','s4','Reconstructed');
folder_basisW = fullfile('Data','NonUpfrontal3','s4');
fn_basisW = 'TempDHWi_setting1.mat';
U22_makeifnotexist(folder_save);

%load the basisW
loaddata = load(fullfile(folder_basisW,fn_basisW),'W');
basisW = loaddata.W / 255;            %the training range is 0~255, so here it needs to be devided by 255
clear loaddata

%load training image
loaddata = load(fullfile(exampleMATfolder,fn_exampleMAT),'exampleimages_hr','exampleimages_lr');
exampleimages_hr = loaddata.exampleimages_hr;
exampleimages_lr = loaddata.exampleimages_lr;
clear loaddata

%generate the filelist, so that we can run parallel process
filelist = dir(fullfile(folder_exampleimages,['*' fileext]));
filenumber = length(filelist);
fileidx_start = 1;
fileidx_end = 'all';

if isa(fileidx_end,'char')
    if strcmp(fileidx_end,'all')
        fileidx_end = filenumber;
    end
end
for fileidx = fileidx_start:fileidx_end
    %open specific file
    fn_test = filelist(fileidx).name;
    fprintf('fileidx %d, fn_test %s\n',fileidx,fn_test);
    
    %reconstruct the HR image using basisW
    %solve the optimization problem
    [h_hr, w_hr, imagenumber] = size(exampleimages_hr);
    h_lr = size(exampleimages_lr,1);
    zooming = round(h_hr/h_lr);
    options = optimset('Display','iter','MaxIter',100);
    sigma = 1.6;
    img_y = exampleimages_lr(:,:,fileidx);
    img_bb = imresize(img_y,zooming,'bilinear');
    vector_bb = reshape(img_bb,[h_hr * w_hr,1]);   %if bicubic, there will be negative coefs
    initial_variable = basisW\vector_bb;       %this is the least square error solution
    coeflength = size(basisW,2);
    %it takes long time to run.
    %the result is very close to c* already
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    lb = zeros(coeflength,1);
    ub = [];
    nonlcon = [];
    %the optimization also takes long time
    %it is terribly slow. It is impossible to produce the optimal coef in time.
    %[x fval]= fmincon(@(x) F4_OptimizationTerm(x,basisW,img_y,sigma), initial_variable, A,b,Aeq,beq,lb,ub,nonlcon,options);
    x = initial_variable;
    vector_recon = basisW * x;
    img_recon = reshape(vector_recon,[h_hr,w_hr]);

    %save the result
    fn_short = fn_test(1:end-4);
    fn_save = [fn_short '_recon.mat'];
    save(fullfile(folder_save,fn_save),'img_recon');
    fn_write = [fn_short '_recon.png'];
    imwrite(img_recon,fullfile(folder_save,fn_write));
end