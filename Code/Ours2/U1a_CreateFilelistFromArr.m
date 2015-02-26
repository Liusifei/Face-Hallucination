%Chih-Yuan Yang
%08/24/13
%U1a: do not have the label 0
function U1a_CreateFilelistFromArr(fn_create,arr_filename)
    fid = fopen(fn_create,'w+');
    for i=1:length(arr_filename)
        fprintf(fid,'%d %s\n',i,arr_filename{i});
    end
    fclose(fid);
end
