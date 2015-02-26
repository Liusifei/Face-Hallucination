%Chih-Yuan Yang
%10/09/12
clear
codefolder = fileparts(pwd);
%exampleimagefolder = fullfile(codefolder,'Ours3_nonupfrontal','Examples','Nonupfrontal','ExampleImages');
exampleimagefolder = fullfile(codefolder,'Ours2_upfrontal','Examples','Training');
filelist = dir(fullfile(exampleimagefolder,'*.png'));
fileidx_start = 1;
fileidx_end = length(filelist);
sujectlist = zeros(346,1);
for i= fileidx_start:fileidx_end
    fn_load = filelist(i).name;
    fn_load_short = fn_load(1:end-4);
    A = sscanf(fn_load_short,'%03d_%02d_%02d_%02d%01d_%02d_lm');
    subjectid = A(1);
    sujectlist(subjectid) = 1;
end
subjectnumber = sum(sujectlist);