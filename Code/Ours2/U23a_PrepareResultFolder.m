%Chih-Yuan Yang
%09/25/12
%from U23 to U23a, change the name of setting folder
function para = U23a_PrepareResultFolder(resultfolder,para)
    settingfolder = fullfile(resultfolder,sprintf('%s%d',para.settingname, para.setting));
    tuningfolder = fullfile(settingfolder, sprintf('Tuning%d',para.tuning));
    para.resultfolder = resultfolder;
    para.settingfolder = settingfolder;
    para.tuningfolder = tuningfolder;
    
    U22_makeifnotexist(tuningfolder);
    if ~isempty(para.settingnote)
        fid = fopen(fullfile(settingfolder, 'SettingNote.txt'),'w');
        fprintf(fid,'%s',para.settingnote);
        fclose(fid);
    end
    
    if ~isempty(para.tuningnote)
        fid = fopen(fullfile(para.tuningfolder ,'TuningNote.txt'),'w');
            fprintf(fid,'%s',para.tuningnote);
        fclose(fid);
    end
    
    %copy parameter setting
    if ispc
        cmd = ['copy ' para.mainfilename '.m ' fullfile(para.tuningfolder, [para.mainfilename '_backup.m '])];
    elseif isunix
        cmd = ['cp ' para.mainfilename '.m ' fullfile(para.tuningfolder, [para.mainfilename '_backup.m '])];
    end
    dos(cmd);
end
