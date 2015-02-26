%Chih-Yuan Yang
%10/31/12
function U27a_CreateSemaphoreFile_ThreeColumn(fn_create,arr_filename, idx_until_setasone)
    fid = fopen(fn_create,'w+');
    for i=1:length(arr_filename)
        if  i <= idx_until_setasone
            fprintf(fid,'%05d %s 1\n',i,arr_filename{i});
        else            
            fprintf(fid,'%05d %s 0\n',i,arr_filename{i});
        end
    end
    fclose(fid);
end
