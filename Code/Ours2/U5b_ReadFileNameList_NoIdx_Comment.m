%Chih-Yuan Yang
%03/07/13
%U5: read list from a file and return it as an cell array
function filenamelist = U5b_ReadFileNameList_NoIdx_Comment( fn_list )
    fid = fopen(fn_list,'r');
    %skip the heading comment lines started with %
    tline = fgetl(fid);
    idx_fn = 0;
    filenamelist = cell(1);
    while ischar(tline)
        if isempty(tline) || tline(1) == '%' 
            %do nothing
        else
            idx_fn = idx_fn + 1;
            filenamelist{idx_fn,1} = tline;            
        end
        tline = fgetl(fid);
    end
    fclose(fid);
end

