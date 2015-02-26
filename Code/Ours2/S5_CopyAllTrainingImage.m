%Chih-Yuan Yang
%what date?
%What is the purpose of this file? Do I still need it?
%copy MultiPEI image files to this folder
currfolder = pwd;
parentfolder = fileparts(currfolder);
MPfolder = 'C:\Users\Chih-Yuan\Documents\Research\Dataset\Face\Multi-Pie';     %MultiPIE
%destinationfolder = fullfile('training','HR');
destinationfolder = fullfile('test','HRColor');
if ~exist(destinationfolder,'dir')
    mkdir(destinationfolder);
end
destinationfolderfull = fullfile(pwd,destinationfolder);
%copy
eis = [2 3 3 3];     %expressioninsession
til = 11:20;  %training identity list
for si = 1:4
    sessionsubfolder = sprintf('session%02d',si);
    multiviewfolder = fullfile(MPfolder,'data',sessionsubfolder,'multiview');
    for ii = til    %identity index
        fprintf('si:%d ii:%d\n',si, ii);
        identityfoldername = sprintf('%03d',ii);
        identityfolder = fullfile(multiviewfolder,identityfoldername);
        %check the identity attendance
        if exist(identityfolder,'dir')
            for eisi = 1:eis(si)
                imagesourcefolder = fullfile(identityfolder,sprintf('%02d',eisi),'05_0');
                %copy all images in these folder to the destination
                commandstr = sprintf('copy %s\\*.* %s',imagesourcefolder,destinationfolderfull);
                dos(commandstr);
            end
        end
    end
end