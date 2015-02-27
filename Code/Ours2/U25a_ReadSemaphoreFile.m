%Chih-Yuan Yang
%08/28/13
%To parallel run Glasner's algorithm
%Just read, do not change the semaphore file
function [arr_filename, arr_label] = U25a_ReadSemaphoreFile(fn_symphony)
    fid = fopen(fn_symphony,'r+');
    C = textscan(fid,'%05d %s %d\n');
    arr_filename = C{2};
    arr_label = C{3};
    fclose(fid);
end