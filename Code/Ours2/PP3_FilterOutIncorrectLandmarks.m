%Chih-Yuan Yang
%10/19/12 this file looks old and need to fix
clc
clear
close all

    
para.zooming = 4;
para.SaveName = 'PP3';
%try to upsample all 011*.png in Source\LRColor
%para.testimagefolder = fullfile('training','HRColor');
para.filterfolder = fullfile('training','HRResult','modelmi_correct');
para.setting = 1;
para.settingnote = '';
para.tuning = 1;
para.tuningnote = '';
para.Legend = 'Ours';
para.model = 'mi';          %mi or p99 or p146
para.fileidx_start = 1;
para.fileidx_end = 1960;
%para.imagesavefolder = fullfile('training','HRResult','modelmi');
%parameters for edge

para.MainFileName = mfilename;

%call main procedure
S7_MainProcedure_FilterIncorrectLandmark