%Chih-Yuan Yang
%10/08/12
%Exploit the existing glasslist of upfrontal faces to generate the glasslist of non-upfrontal faces.
%Finally, I found the no one wears glasses in the non-upfrontal example datasets.

clear
codefolder = fileparts(pwd);
addpath(genpath(fullfile(codefolder,'Lib')));

%load image
%folder_exampleimages = fullfile(codefolder,'Ours3_nonupfrontal','Examples','NonUpfrontal','ExampleImages');
%landmarkfolder = fullfile(codefolder,'Ours3_nonupfrontal','Examples','NonUpfrontal','ExampleImageLandmarks');
%folder_save = fullfile(codefolder,'Ours3_nonupfrontal','Examples','NonUpfrontal','PreparedMatForLoad');
%folder_exampleimages = fullfile('Examples','Upfrontal3','Training');
%folder_glasslist_all = fullfile('Examples','MetaData');
%fn_glasslist_all = 'GlassList_AllImages_Upfrontal.txt';
%folder_save = fullfile('Examples','Upfrontal3');

folder_exampleimages = fullfile('Examples','NonUpfrontal2','Training');
folder_glasslist_all = fullfile('Examples','MetaData');
fn_glasslist_all = 'GlassList_AllImages_NonUpfrontal.txt';
folder_save = fullfile('Examples','NonUpfrontal2');

fn_save = 'GlassList.txt';
U22_makeifnotexist(folder_save);

%load glass list
fid = fopen(fullfile(folder_glasslist_all,fn_glasslist_all),'r+');
C = textscan(fid,'%05d %s %d\n');
fclose(fid);
filelist_glass = C{2};
labellist_glass = C{3};
listlength_glass = length(filelist_glass);
clear C fid

%prepare the file to write
fid = fopen(fullfile(folder_save,fn_save),'w+');

filelist = dir(fullfile(folder_exampleimages,'*.png'));
filenumber = length(filelist);
for i=1:filenumber
    fn_image = filelist(i).name;
    bglasslabel = false;
    
    %check the glass lable    
    for j=1:listlength_glass
        if strcmp(fn_image, filelist_glass{j})
            bglasslabel = labellist_glass(j);
            break;
        end
    end
    fprintf(fid,'%05d %s %d\n',i,fn_image,bglasslabel);
end
fclose(fid);
