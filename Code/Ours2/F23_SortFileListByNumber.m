%Chih-Yuan Yang
%09/21/12
%the default dir() result is sorted by string, but Windows and MATLAB sort file name by number
%make the 
function filelist_out = F23_SortFileListByNumber(filelist,appendix)
    listlength = length(filelist);
    filelist_out(1:listlength,1) = struct('name',[]);
    allnameasnumber = zeros(listlength,1);
%    extrecord = cell(listlength,1);
%    namerecord = cell(listlength,1);
    if ~exist('appendix','var');
        appendix = [];
    end
    for i=1:listlength
        fn_original = filelist(i).name;
        k = strfind(fn_original, appendix);
        fn_number = fn_original(1:k-1);
        allnameasnumber(i) = str2double(fn_number);
%        extrecord{i} = ext;     %the ext includes dot.
%        namerecord{i} = fn_number;
    end
    %sort all the number
    [~, ix] = sort(allnameasnumber);
    
    %write it to filelist_out
    for i=1:listlength
        originalidx = ix(i);
        filelist_out(i).name = filelist(originalidx).name;
    end
end
