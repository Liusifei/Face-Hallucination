%Chih-Yuan Yang
%09/19/12
%hint: for patch work, loading all data into memory can save time.
function [sfall srecall] = F12_ACCV12Preprocess_LoadingData(zooming,featurefilename,recordfilename)
    if zooming == 4
        featurefolder = fullfile('TexturePatchDataset','Feature','s4');
    elseif zooming == 3
        featurefolder = fullfile('TexturePatchDataset','Feature','s3');
    end
    
    sfall = cell(6,1);
    srecall = cell(6,1);
    quanarray = [1 2 4 8 16 32];
    for qidx=1:6
        quan = quanarray(qidx);
        loadfilename = sprintf('%s%d.mat',featurefilename,quan);
        loaddata = load(fullfile(featurefolder,loadfilename));
        sfall{qidx} = loaddata.sf;
        loadfilename = sprintf('%s%d.mat',recordfilename,quan);
        loaddata = load(fullfile(featurefolder,loadfilename));
        srecall{qidx} = loaddata.srec;
        fprintf('.');
    end
    fprintf('\n');
end
