%06/11/13
%Is this file still used?
function imglisthr = F3_LoadExampleImagesAndLandmark(exampleimagefolder)
    filelist = dir(fullfile(exampleimagefolder,'*.png'));
    listlength = length(filelist);
    imglisthr = zeros(480,640,listlength,'uint8');
    for i=1:listlength
        fn = filelist(i).name;
        imglisthr(:,:,i) = imread(fullfile(exampleimagefolder,fn));
    end
end