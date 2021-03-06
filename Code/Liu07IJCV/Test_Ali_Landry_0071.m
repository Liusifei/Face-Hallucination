%Chih-Yuan Yang
%11/21/12
%Copied from Test_Face_wild
%I need the result of Ali_Landry_0071 to fill the supplementary material
clc
clear
close all

    
para.zooming = 4;
para.SaveName = 'Liu2';
para.testimagefolder = fullfile('Source','Wild2','Input');
para.setting = 1;
para.settingnote = '';
para.tuning = 1;
para.tuningnote = '';
para.Legend = 'Liu';

para.iistart = 4;
para.iiend = 4;
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

para.resultfolder = 'sf_results_wild';

%call main procedure
S3_MainProcedure_Lui07_wild