%Chih-Yuan Yang
%08/14/13
%Generate filelist
%The file is copied from project SISRBenchmark
clear
close all
%folder_source = fullfile('Source','Upfrontal3','GroundTruth');
%folder_source = fullfile('Examples','Upfrontal2','Training');
%fn_filenamelist = 'TrainingImage2184Upfrontal.txt';
%case Upfrontal3_1 HighContrast test
% folder_source = fullfile('Source','Upfrontal3_1HighContrast','Raw');
% fn_filenamelist = 'TestImage342UpfrontalHighContrast.txt';
%case upfrontal3_1 HighContrast example
% folder_source = fullfile('Examples','Upfrontal3_1HighContrast','Raw');
% fn_filenamelist = 'TrainingImage2167Upfrontal3_1HighContrast.txt';
%case JANUS small face
%folder_source = fullfile('Source','JANUSProposal','Input');
%fn_filenamelist = 'JANUSProposalReady.txt';
%JPEG input
folder_source = fullfile('Source','Upfrontal3','Input','100');
fn_filenamelist = 'Upfrontal3_342_Q100.txt';


folder_filenamelist = 'FileList';
fileext{1}= '.png';
sortnumberfilename(1) = false;      %set it as true is the filename is pure number (e.g. BSD200)
fileext{2}= '.jpg';
sortnumberfilename(2) = false;
fileext{3}= '.bmp';
sortnumberfilename(3) = false;
fileextnumber = length(fileext);

U22_makeifnotexist(folder_filenamelist);
fid = fopen(fullfile(folder_filenamelist,fn_filenamelist),'w+');
totalidx = 0;
for i=1:fileextnumber
    filelist = dir(fullfile(folder_source,['*' fileext{i}])); %color images
    if sortnumberfilename(i)
        filelist = F23_SortFileListByNumber(filelist,fileext{i});
    end
    filenumber = length(filelist);
    for j=1:filenumber
        totalidx = totalidx + 1;
        fprintf(fid,'%d %s\n',totalidx,filelist(j).name);
    end
end
fclose(fid);
