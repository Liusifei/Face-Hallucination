%Chih-Yuan Yang
%4/3/12
%To parallel run 
function U27e_CreateSymphonyFile_FromFilenamelist_ExcludeSet(fn_create,filenamelist, set_value0)
    fid = fopen(fn_create,'w+');
    for i=1:length(filenamelist)
        if nnz(set_value0 == i)
            fprintf(fid,'%05d %s 0\n',i,filenamelist{i});
        else            
            fprintf(fid,'%05d %s 1\n',i,filenamelist{i});
        end
    end
    fclose(fid);
end
