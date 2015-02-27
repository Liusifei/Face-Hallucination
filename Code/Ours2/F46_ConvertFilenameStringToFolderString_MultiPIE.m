%Chih-Yuan Yang
%03/21/14
%Convert a filename string to the folder strings of Multi-PIE dataset
function folder_container = F46_ConvertFilenameStringToFolderString_MultiPIE( fn_file )
    str_identity = fn_file(1:3);
    str_session = fn_file(5:6);
    str_expression = fn_file(8:9);
    str_cameraposition = fn_file(11:13);        %in filename, it is 051; in folder, it is 05_1
    str_illumination = fn_file(15:16);          %this string is not used since images of all illumination are contained in the same folder
    %according to the data, to find the correct folder
    folder_session = sprintf('session%s',str_session);
    folder_multiview = fullfile('data',folder_session,'multiview');
    folder_identity = fullfile(folder_multiview,str_identity);
    folder_expression = fullfile(folder_identity,str_expression);
    folder_cameraposition = fullfile(folder_expression,[str_cameraposition(1:2) '_' str_cameraposition(3)]);
    folder_container = folder_cameraposition;
end

