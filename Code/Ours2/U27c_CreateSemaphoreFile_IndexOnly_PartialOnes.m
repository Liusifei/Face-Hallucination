%Chih-Yuan Yang
%3/30/13
%
function U27c_CreateSemaphoreFile_IndexOnly_PartialOnes(fn_create,iiend,num_filluntil)
    fid = fopen(fn_create,'w+');
    for i=1:iiend
        if i <= num_filluntil
            fprintf(fid,'%05d 1\n',i);
        else
            fprintf(fid,'%05d 0\n',i);
        end
    end
    fclose(fid);
end
