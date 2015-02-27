%FrontalSelection.m
% FrontalSelection.m aims at selecting frontal, neutral expression faces
% for Ma's algorithm

clear; close all; clc;

% set path
PathSelected_LR = 'D:\Projects\PositionPatch\Data\Sele_TrainingFaces_LRGray';
PathSelected_HR = 'D:\Projects\PositionPatch\Data\Sele_TrainingFaces_HRGray';
PathSelected_test = 'D:\Projects\PositionPatch\Data\Sele_TestFaces_Gray';
if ~exist(PathSelected_LR,'dir')
   mkdir(PathSelected_LR);
end
if ~exist(PathSelected_HR,'dir')
   mkdir(PathSelected_HR);
end
if ~exist(PathSelected_test,'dir')
   mkdir(PathSelected_test);
end

% current path
Train_LR = 'D:\Projects\PositionPatch\Data\TrainingFaces_LRGray';
Train_HR = 'D:\Projects\PositionPatch\Data\TrainingFaces_Gray';
Test_HR = 'D:\Projects\PositionPatch\Data\TestFaces_Gray';
Dir_train_sele = dir(fullfile(Train_LR,'*_*_01_*_*.png'));
Dir_test_sele = dir(fullfile(Test_HR,'*_*_01_*_*.png'));

% check and copy
for m = 1:length(Dir_train_sele)
   fprintf('Copy training file: %s\n',Dir_train_sele(m).name);
   name = fullfile(Train_LR,Dir_train_sele(m).name);
   dst = fullfile(PathSelected_LR,Dir_train_sele(m).name);
   try copyfile(name,dst)
   catch 
       printf('Cannot copy file: %s\n',Dir_train_sele(m).name);
   end
   
   name = fullfile(Train_HR,Dir_train_sele(m).name);
   dst = fullfile(PathSelected_HR,Dir_train_sele(m).name);
   try copyfile(name,dst)
   catch 
       printf('Cannot copy file: %s\n',Dir_train_sele(m).name);
   end
end

for m = 1:length(Dir_test_sele)
    fprintf('Copy testing file: %s\n',Dir_test_sele(m).name);
    name = fullfile(Test_HR, Dir_test_sele(m).name);
    dst = fullfile(PathSelected_test,Dir_test_sele(m).name);
    try copyfile(name,dst)
    catch
        printf('Cannot copy file: %s\n',Dir_test_sele(m).name);
    end
end