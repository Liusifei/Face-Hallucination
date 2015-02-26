function U22_makeifnotexist(foldername)
    if ~exist(foldername,'dir')
        mkdir(foldername)
    end
end