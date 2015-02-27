%Chih-Yuan Yang
%4/3/12
%To parallel run 
function U27f_CreateSemaphoreFile_FromFilenamelist_SetArray(fn_create,arr_filename, arr_value)
    fid = fopen(fn_create,'w+');
    for i=1:length(arr_filename)
        fprintf(fid,'%05d %s %d\n',i,arr_filename{i},arr_value(i));
    end
    fclose(fid);
end
