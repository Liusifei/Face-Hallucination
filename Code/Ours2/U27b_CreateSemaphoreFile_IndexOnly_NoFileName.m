%Chih-Yuan Yang
%3/22/13
%
function U27b_CreateSemaphoreFile_IndexOnly_NoFileName(fn_create,iiend)
    fid = fopen(fn_create,'w+');
    for i=1:iiend
        fprintf(fid,'%05d 0\n',i);
    end
    fclose(fid);
end
