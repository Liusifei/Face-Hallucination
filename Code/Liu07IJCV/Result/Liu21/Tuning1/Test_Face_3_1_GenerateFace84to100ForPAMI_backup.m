%08/22/12
%Chih-Yuan Yang
%Test_Face_3_1: We only have 83 images, and we need the 84th to 100th images to compute the mean
clc
clear
close all

    
para.zooming = 4;
para.SaveName = 'Liu2';
para.testimagefolder = fullfile('Source','Upfrontal3','Input');
para.setting = 1;
para.settingnote = '';
para.tuning = 1;
para.tuningnote = '';
para.Legend = 'Liu';

para.iistart = 84;  %we have 83 images already
para.iiend = 100;
para.ExtDatasetNumber = 1;      %remove it later

para.MainFileName = mfilename;
para.patchsize = 7;
para.bLoadExistingImgTextureAndImgEdge = false;      %for tuning weight factor
para.bLoadExistingTexture_NoLGD = false;
para.bUseExsitingSearchingResult = false;
para.bApplyNonLocalSimilarityFilter = true;             %must use
para.bEnablemhrf = true;
para.ehrfKernelWidth = 1.0;
para.NumberOfHCandidate = 20;

para.bApplyLocalGradientDistribution = false;
para.bComputeDiivine = true;           %to save time
para.bTimeTest = false;
%debuggin option
para.bDumpInformation = false;
para.SimilarityFunctionSettingNumber = 1;
para.UseL2NormForSelfSimilarPatchSearch = true;

para.resultfolder = 'Result_new';

%call main procedure
S3_MainProcedure_Lui07_3