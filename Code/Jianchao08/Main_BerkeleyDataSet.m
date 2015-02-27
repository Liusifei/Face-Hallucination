%Use algorithm to run Berkeley Segment Data Set
%Mar 10 2010
%Chih-Yuan Yang
clear
TrainIIDS = dlmread('Source\BSDS300\iids_train.txt');

Para.SettingNum = 1;
Para.RunAnn = true;
Para.BriefExplanation = 'Run for all Berkeley Segmentation Data Set';
Para.B_GauVar = 0.8;
Para.nn = 9;
Para.Scaling = 3;
Para.PatchOverlap = 4;
Para.PatchSize = 5;
Para.SubLayerNumber = 6;

Para.SigmaForReliability = 50;
Para.DumpDebuggingImage = true;

for i=1:length(TrainIIDS)
    clear img_input CbCrLayer UppderLayers LowerLayers L0
    Para.SaveName = num2str(TrainIIDS(i));
    Para.TempDataFolder = ['TempData\BerkeleyDataSet\Setting' num2str(Para.SettingNum) '\' num2str(i) '_' Para.SaveName '\'];
    Para.SourceFile = ['Source\BSDS300\images\Train\' Para.SaveName '.jpg'];
    SaveInfo( Para , mfilename );
    
    %too big, down sample to 1/2
    [img_input CbCrLayer] = LoadData_Berkeley( Para );
    [LowerLayers SizePyramid] = CreateSubLayers2( img_input , Para);
    L0 = PackageLayer( img_input , 0 );

    PatchRecordTable = RecordPatchIndex(LowerLayers, Para.PatchSize, Para.PatchSize - 1, Para);
    PatchNum = size(PatchRecordTable , 2);
    PatchRecordTable_Source = RecordPatchIndex(L0, Para.PatchSize , Para.PatchOverlap, Para);
    if Para.RunAnn
        DumpPatchToTxtForAnn([Para.TempDataFolder 'AnnSource.txt'], PatchRecordTable_Source);
        DumpPatchToTxtForAnn([Para.TempDataFolder 'AnnSearchPool.txt'], PatchRecordTable);
        DoAnn( [Para.TempDataFolder 'AnnResult.txt'] , [Para.TempDataFolder 'AnnSource.txt'], ...
            [Para.TempDataFolder 'AnnSearchPool.txt'] , Para.nn , Para.PatchSize^2 , PatchNum);
    end
    PatchMappingTable = ConvertAnnResultToMappingTable( [Para.TempDataFolder 'AnnResult.txt'] , PatchRecordTable, PatchRecordTable_Source );

    tStart = now;

    UpperLayers = BuildDataLayer7(PatchMappingTable , L0 , LowerLayers, SizePyramid , Para);
    if Para.DumpDebuggingImage
        DbgDumpUpperLayers(UpperLayers , Para);
    end
    H = imresize( L0.grid , Para.Scaling );
    H = BackProjection_Daniel1(H , UpperLayers , L0, Para);
    DumpColorfulTopLayer( Para , H , CbCrLayer , 1);


    tEnd = now;
    NeedTime = datestr(tEnd-tStart, 'dd:HH:MM:SS');

    WriteToInfoFile( NeedTime , Para );
    save([Para.TempDataFolder Para.SaveName '_Setting' num2str(Para.SettingNum) '_ForCluster2.mat'] , 'UpperLayers', 'LowerLayers', 'CbCrLayer' , 'SizePyramid' , 'Para', 'H' , 'L0');
end