%Chih-Yuan Yang
%2/20/15
%U5: read list from a file and return it as an cell array
%U5a: read glass list
function [arr_label, arr_filename] = U5a_ReadGlassList( fn_list )
    fid = fopen(fn_list,'r');
    C = textscan(fid,'%05d %s %d\n');
    fclose(fid);
    arr_filename = C{2};
    arr_label = C{3};
end
