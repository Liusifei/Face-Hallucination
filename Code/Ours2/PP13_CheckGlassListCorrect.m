%Chih-Yuan Yang
%10/19/12
%generate class list
clear
codefolder = fileparts(pwd);
addpath(genpath(fullfile(codefolder,'Lib')));

exampleimagefolder = fullfile('Examples','MetaData','AllImages_Upfrontal');
glasslistfolder = fullfile('Examples','MetaData');
fn_read = 'GlassList_AllImages_Upfrontal.txt';
outputfolder_glass = fullfile('Examples','MetaData','Upfrontal_Glass');
outputfolder_noglass = fullfile('Examples','MetaData','Upfrontal_NoGlass');
U22_makeifnotexist(outputfolder_glass);
U22_makeifnotexist(outputfolder_noglass);

%open glass list file
fid = fopen(fullfile(glasslistfolder,fn_read),'r+');
C = textscan(fid,'%05d %s %d\n');
fclose(fid);

filelist = dir( fullfile(exampleimagefolder,'*.png') );
filenumber = length(filelist);
for i=1:filenumber
    fn_copy = filelist(i).name;
    if C{3}(i) == 0
        strcmd = sprintf('copy %s %s',fullfile(exampleimagefolder,fn_copy), fullfile(outputfolder_noglass,fn_copy));
    else
        strcmd = sprintf('copy %s %s',fullfile(exampleimagefolder,fn_copy), fullfile(outputfolder_glass,fn_copy));
    end
    dos(strcmd);
end
