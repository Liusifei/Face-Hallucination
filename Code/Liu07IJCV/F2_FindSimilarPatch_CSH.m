%Chih-Yuan Yang, EECS, UC Merced
%Last Modified: 08/23/12
%Find similar patches form many images using CSH
%Question: I do not need to use all patches cropped from the query image.
%Only parts are required. How to handle it?
%However, do not consider it now.
%And what I need are the coordinate and norm, not the patch. How to do it?

function F2_FindSimilarPatch_CSH(queryimage,middlebandimage)
    addpath('Utility');
    addpath(genpath(fullfile('Lib','CSH_code_v2')));

    %set randseed
    seed = RandStream('mcg16807','Seed',0); 
    RandStream.setGlobalStream(seed) 

    im8 = imread( para.SourceFile);
    im8y = rgb2gray(im8);
    %find the CSH nn
    
    width = ps;      %should I use 4 or 8?     Problem: CSH does not support patch size as 6
    iteration = 5;
    nnk = 20;
    [lh lw d] = size(im8);
    recin = 20;
    normcurr = zeros(lh,lw,nnk);
    A = im8y;
    ps = width;
    eh = lh-ps+1;
    ew = lw-ps+1;   %effective w
    scanr = zeros(eh,ew,recin,4);       %scan results, norm, ii, sr, sc
    bigvalue = 255*width*width;
    scanr(:,:,:,1) = bigvalue;
    iistart = para.iistart;
    iiend = para.iiend;
    
    for ii=iistart:iiend
        %if ii == 2
        %    keyboard
        %end
        fn = sprintf('%05d.png',ii);
        fprintf('csh fn: %s\n',fn);
        ime = imread(fullfile(DatasetFolder,fn));       %the channel number is 1
        B = ime;
        idxhead = (ii-1)*nnk+1;
        idxend = idxhead + nnk-1;
        retres  = CSH_nn(A,B,width,iteration,nnk);      %x,y  <==> c,r  $retrived results
        %dimension: w,h,2,nnk
        for l = 1:nnk
            colMap = retres(:,:,1,l);
            rowMap = retres(:,:,2,l);
            br_boundary_to_ignore = width -1;
            %GetAnnError_GrayLevel_C1 is a funciton in CHS lab. It can compute very fast
            normcurr(:,:,l) = GetAnnError_GrayLevel_C1(A,B,uint16(rowMap),uint16(colMap),uint16(0),uint16(br_boundary_to_ignore), uint16(width));
        end
        
        %update scanr
        normcurrmin = min(normcurr,[],3);
        checkmap = normcurrmin(1:eh,1:ew) < scanr(:,:,recin,1);     %the last one has the largest norm
        [rset cset] = find(checkmap);
        setin = length(rset);
        for j=1:setin
            rl = rset(j);
            cl = cset(j);
            [normcurrsort ixcurr] = sort(normcurr(rl,cl,:));
            for i=1:nnk
                %update the smaller norm
                compidx = recin-i+1;
                if normcurrsort(i) < scanr(rl,cl,compidx,1)
                    %update
                    oriidx = ixcurr(i);
                    scanr(rl,cl,compidx,1) = normcurrsort(i);
                    scanr(rl,cl,compidx,2) = ii;
                    scanr(rl,cl,compidx,3) = retres(rl,cl,2,oriidx);        %rowmap
                    scanr(rl,cl,compidx,4) = retres(rl,cl,1,oriidx);        %colmap
                else
                    break
                end
            end
            
            %sort again the updated data
            [normnewsort ixnew] = sort(scanr(rl,cl,:,1));
            tempdata = scanr(rl,cl,:,:);
            for i=1:recin
                if ixnew(i) ~= i
                    scanr(rl,cl,i,:) = tempdata(1,1,ixnew(i),:);
                end
            end
        end
    end
    sn = sprintf('%s_csh_scanr_%d_%d.mat',para.SaveName,iistart,iiend);
    save(fullfile(para.tuningfolder,sn),'scanr');
end

