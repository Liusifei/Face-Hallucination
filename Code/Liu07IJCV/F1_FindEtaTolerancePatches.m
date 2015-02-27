function patchlist = F1_FindEtaTolerancePatches(patch_query,middlebandimage, eta)
    [h w count] = size(middlebandimage);
    vectorlength = 36;
    vector_query = reshape(patch_query,vectorlength,1);
    ps = size(patch_query,1);
    patchlist = struct('ii',0,'r',0,'c',0,'vec',0);
    listidx = 0;
    minnormvalue = 10;
    for ii = 1:count
        fprintf('ii %d, minnormvalue %0.4f total %d\n',ii,minnormvalue,count);
        for r=1:h-ps+1
            r2=r+ps-1;
            for c=1:w-ps+1
                c2=c+ps-1;
                vector_test = reshape(middlebandimage(r:r2,c:c2),vectorlength,1);
                normvalue = norm(vector_query - vector_test);
                if normvalue < minnormvalue
                    minnormvalue = normvalue;
                    minii = ii;
                    minr = r;
                    minc = c;
                    minvec = vector_test;
                end
                %fprintf('%0.4f\n',normvalue);
                if normvalue < eta
                    listidx = listidx + 1;
                    patchlist(listidx).ii = ii;                    
                    patchlist(listidx).r = r;
                    patchlist(listidx).c = c;
                    patchlist(listidx).vec = vector_test;
                end
            end
        end
    end
    if listidx ==0
        listidx = listidx + 1;
        patchlist(listidx).ii = minii;
        patchlist(listidx).r = minr;
        patchlist(listidx).c = minc;
        patchlist(listidx).vec = minvec;
    end
end