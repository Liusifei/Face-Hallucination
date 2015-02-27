%Chih-Yuan Yang
%09/15/12
%simplify main function
function para = U23_PrepareResultFolder(resultfolder,para)
    settingfolder = fullfile(resultfolder,sprintf('%s%d',para.SaveName,para.setting));
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
        fid = fopen(fullfile(para.tuningfolder ,'TunningNote.txt'),'w');
            fprintf(fid,'%s',para.tuningnote);
        fclose(fid);
    end
    
    %copy parameter setting
    if ispc
        cmd = ['copy ' para.MainFileName '.m ' fullfile(para.tuningfolder, [para.MainFileName '_backup.m '])];
    elseif isunix
        cmd = ['cp ' para.MainFileName '.m ' fullfile(para.tuningfolder, [para.MainFileName '_backup.m '])];
    end
    dos(cmd);
end
