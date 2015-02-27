%Chih-Yuan Yang
%09/21/12
%To parallel run Glasner's algorithm
function fileidx = U25_ReturnTheLargestToDoNumber(fn_symphony,iistart)
    fileidx = -1;       %default, if 

    fid = fopen(fn_symphony,'r+');
    C = textscan(fid,'%05d %s %d\n');
    iiend = length(C{1,3});
    bwriteback = false;
    for i=iistart:iiend
        if C{1,3}(i) == 0
            fileidx = i;
            C{1,3}(i) = 1;
            bwriteback = true;
            break;
        end
    end
    if bwriteback
        fseek(fid,0,'bof');     %move to beginning
        for i=1:iiend
            fprintf(fid,'%05d %s %d\n',C{1,1}(i),C{1,2}{i},C{1,3}(i));
        end        
    end
    fclose(fid);
end