%Chih-Yuan Yang
%4/1/13
%
function U27d_CreateSemaphoreFile_IndexOnly_Exclude(fn_create,iiend,set_value0)
    fid = fopen(fn_create,'w+');
    for i=1:iiend
        if nnz(set_value0 == i)
            fprintf(fid,'%05d 0\n',i);
        else
            fprintf(fid,'%05d 1\n',i);
        end
    end
    fclose(fid);
end
