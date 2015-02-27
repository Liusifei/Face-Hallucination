%Chih-Yuan Yang
%09/29/12
%for parallel execution
function U27_CreateSemaphoreFile_TwoColumn(fn_create,iiend,filenamelist)
    fid = fopen(fn_create,'w+');
    for i=1:iiend
        fprintf(fid,'%05d %s 0\n',i,filenamelist{i});
    end
    fclose(fid);
end
