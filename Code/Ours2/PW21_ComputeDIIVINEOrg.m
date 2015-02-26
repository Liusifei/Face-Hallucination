% Compute DIIVINE
clear all; close all; clc;
addpath(genpath('\\vision-u1\Research\120801SRForFace\code\Lib'));
workfolder = 'D:\Projects\FACE HR\Results_show';
% fields = {'Upfrontal','NonUpfrontal','Wild'};
fields = {'Upfrontal_supp'};
pfix = 'Org';
findex = length(fields);
for m = 1:findex
    disp(m);
    filefolder = fullfile(workfolder, fields{m}, pfix);
    imdir = dir(fullfile(filefolder,'*.png'));
    fin = fopen(fullfile(filefolder,'diivine.txt'),'a+');
    for n =1:length(imdir) 
        img_input = imread(fullfile(filefolder,imdir(n).name));
        DIIVINE = divine(img_input);
        fprintf(fin,[imdir(n).name,': %d\n'],DIIVINE);
    end
    fclose(fin);
end