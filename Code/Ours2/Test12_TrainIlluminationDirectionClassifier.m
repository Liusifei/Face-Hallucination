%Chih-Yuan Yang
%03/23/2014
%I try to train a classifier of illumination direction
%

clc
clear
close all

folder_code = fileparts(pwd);
folder_project = fileparts(folder_code);
folder_dataset = fullfile(folder_project,'Dataset');
folder_lib = fullfile(folder_code,'Lib');
folder_intraface = fullfile(folder_lib,'FacialFeatureDetection&Tracking_v1.3');
folder_models = fullfile(folder_intraface,'models');
folder_coef_root = 'Coef';
folder_cluster_root = 'Cluster';
addpath(genpath(folder_intraface));     %I nee to add this path, otherwise a mexw64 file can not be loaded
addpath(genpath(fullfile(folder_lib,'YIQConverter')));
addpath(genpath(fullfile(folder_lib,'patchmatch-2.1')));

%settings for eye location
folder_eyelocaion = 'LocationOfTwoEyesForAlignment';
fn_eyelocaion = 'Upfrontal.mat';

%settings for test images
folder_save = fullfile('Result','Test12_IlluminationDirectionClassifier');
folder_filelist = 'Filelist';
fn_filelist = 'MultiPIE_051_Effective.txt';
str_legend = '_test12';

%setup exemplar images and landmarks
folder_savedexamples = fullfile('Examples','Upfrontal3_1','PreparedMatForLoad');
fn_savedexamples = 'ExampleDataForLoad.mat';
folder_glasslist = 'Filelist';
fn_glasslist = 'GlassList_Upfrontal3_1HighContrast_Example_2167.txt';
folder_exampleimage = fullfile('Examples','Upfrontal3_1HighContrast','High');
folder_landmark_example = fullfile('Landmarks','ManuallyLabeled','Upfrontal','Aligned');


idx_file_start = 1;
idx_file_end = 'all';
bSkipIfOutputExist = false;

%load eye location
loaddata = load(fullfile(folder_eyelocation,fn_eyelocation));
location_eyes = loaddata;

%load filelist
arr_filename = U5_ReadFileNameList(fullfile(folder_filelist,fn_filelist));
num_file = length(arr_filename);
if isa(idx_file_end,'char')
    if strcmp(idx_file_end,'all')
        idx_file_end = num_file;
    end
end


%read images and landmarks
for idx_illumination = 1:19
    fn_save = ['illumination_%d.mat',idx_illumination];
    if exist(fullfile(folder_save,fn_save),'file')
        fprintf('skip illumination %d file %s\n',idx_illumination,fn_save);
        continue;
    else
        fprintf('process illumination %d file %s\n',idx_illumination,fn_save);
    end
    
    for idx_file = idx_file_start:idx_file_end
        %I have to load images from the Multi-PIE dataset
        fn_landmark = arr_file_landmark{idx_file};
        fn_short = fn_landmark(1:end-7);
        fn_image = [fn_short '.png'];

        %convert the filename string to folders
        folder_container = F46_ConvertFilenameStringToFolderString_MultiPIE(fn_landmark);
        loaddata = load(fullfile(folder_landmark,fn_landmark));
        landmark = loaddata.pts;
        img_read = imread( fullfile(folder_multipie,folder_container,fn_image) );

        bdrawnumbers = true;
        bdrawpose = false;
        str_pose = [];
        bvisible = true;
        hfig = U21b_DrawLandmarks_Points_ReturnHandle(img_read,landmark,str_pose,bdrawnumbers,bdrawpose,bvisible);
        saveas(hfig, fullfile(folder_save,fn_save));
        close(hfig);
        
    end
end