%Chih-Yuan Yang
%09/16/12
%To parallel run Glasner's algorithm
function U24_CreateSymphonyFile(fn_create,iiend,filenamelist)
    fid = fopen(fn_create,'w+');
    for i=1:iiend
        fprintf(fid,'%05d %s 0\n',i,filenamelist{i});
    end
    fclose(fid);
end
