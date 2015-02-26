%Chih-Yuan Yang
%09/01/13
%U5: read list from a file and return it as an cell array
%U5c: add more comment controls, the comment sign % may occur at the end of a line
function filenamelist = U5c_ReadFileNameList_NoIdx_MoreComment( fn_list )
    fid = fopen(fn_list,'r');
    %skip the heading comment lines started with %
    tline = fgetl(fid);
    idx_fn = 0;
    filenamelist = cell(1);
    str_tab = sprintf('\t');
    while ischar(tline)
        %if it is empty line or starts with %, do nothing
        if isempty(tline) || tline(1) == '%' 
            %do nothing
        else
            %if a % is found, neglect the characters after the first space or %
            k_space = strfind(tline,' ');
            k_percentsign = strfind(tline,'%');
            k_tab = strfind(tline,str_tab);        %how to find a tab?
            if isempty(k_space) && isempty(k_percentsign) && isempty(k_tab)
                idx_fn = idx_fn + 1;
                filenamelist{idx_fn,1} = tline;
            else
                k = length(tline);
                if ~isempty(k_space)
                    k = min(k,k_space(1));
                end
                if ~isempty(k_tab)
                    k = min(k,k_tab(1));
                end
                if ~isempty(k_percentsign)
                    k = min(k,k_percentsign(1));
                end
                idx_fn = idx_fn + 1;
                filenamelist{idx_fn,1} = tline(1:k-1);
            end
        end
        tline = fgetl(fid);
    end
    fclose(fid);
end

