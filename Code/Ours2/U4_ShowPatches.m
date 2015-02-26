function U4_ShowPatches(para)
    %assume the range of intensity is 0~1
    patchlist = para.patchlist;
    if isfield(para,'valuelist')
        valuelist = para.valuelist;
    else
        valuelist = [];
    end
    if isfield(para,'fn_save')
        fn_save = para.fn_save;
    else
        fn_save = [];
    end
    
    h = 5;      %subplot height
    w = 10;     %subplot width
    listlength = size(patchlist,3);
    hfig = figure;
    showablecount = min(h*w,listlength);
    for i=1:showablecount
        plotr = ceil(i /w);         %to prevent the plot h w is different from the window h w
        plotc = i - (plotr-1) * w;
        plotp = (plotr-1)*w + plotc;
        subplot(h,w,plotp);
        imshow(patchlist(:,:,i));
        if ~isempty(valuelist)
            str = sprintf('%0.4f',valuelist(i));
            title(str);
        end
    end
    if ~isempty(fn_save)
        saveas(hfig,[fn_save '.png']);
        saveas(hfig,[fn_save '.fig']);
    end
end