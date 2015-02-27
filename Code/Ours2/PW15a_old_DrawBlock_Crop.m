%Chih-Yuan Yang
%10/09/12

clear
clc
% codefolder = fileparts(pwd);
% projectfolder = fileparts(codefolder);
figsfolder = 'D:\Projects\FACE HR\Results_show';

UsedIdx = 6;

switch UsedIdx
    case 1
        sourcefolder = fullfile(figsfolder,'F13');
        savefolder = fullfile(figsfolder,'F13_Crop');
%         Setting.LoadFileNameprefix = '145_03_01_051_05';
        Setting.block(1).X = 55;
        Setting.block(1).Y = 138;
        Setting.block(1).width = 53;
        Setting.block(1).height = 46;
        Setting.bCropSaveAs = true;
        Setting.bDraw = false;
        Setting.bPaste = false;
    case 2
        sourcefolder = fullfile(figsfolder,'F14');
        savefolder = fullfile(figsfolder,'F14_Crop');
%         Setting.LoadFileNameprefix = '150_04_03_051_05';
        Setting.block(1).X = 93;
        Setting.block(1).Y = 222;
        Setting.block(1).width = 63;
        Setting.block(1).height = 31;
        Setting.bCropSaveAs = true;
        Setting.bDraw = false;
        Setting.bPaste = false;
    case 3
        sourcefolder = fullfile(figsfolder,'F16');
        savefolder = fullfile(figsfolder,'F16_Crop');
%         Setting.LoadFileNameprefix = '005_02_01_041_05';
        Setting.block(1).X = 135;
        Setting.block(1).Y = 210;
        Setting.block(1).width = 55;
        Setting.block(1).height = 30;
        Setting.bCropSaveAs = true;
        Setting.bDraw = false;
        Setting.bPaste = false;
    case 4
        sourcefolder = fullfile(figsfolder,'F17');
        savefolder = fullfile(figsfolder,'F17_Crop');
%         Setting.LoadFileNameprefix = '009_01_01_041_05';
        Setting.block(1).X = 155;
        Setting.block(1).Y = 172;
        Setting.block(1).width = 38;
        Setting.block(1).height = 28;
        Setting.bCropSaveAs = true;
        Setting.bDraw = false;
        Setting.bPaste = false;
    case 5
        sourcefolder = fullfile(figsfolder,'F12');
        savefolder = fullfile(figsfolder,'F12_Crop');
%         Setting.LoadFileNameprefix = 'Ali_Landry_0071_Ours_1_4_autocrop';
        Setting.block(1).X = 57;
        Setting.block(1).Y = 140;
        Setting.block(1).width = 55;
        Setting.block(1).height = 38;
        Setting.bCropSaveAs = true;
        Setting.bDraw = false;
        Setting.bPaste = false;
    case 6
        sourcefolder = fullfile(figsfolder,'F18');
        savefolder = fullfile(figsfolder,'F18_Crop');
%         Setting.LoadFileNameprefix = 'Ali_Landry_0071.jpg';
        Setting.block(1).X = 53;
        Setting.block(1).Y = 130;
        Setting.block(1).width = 55;
        Setting.block(1).height = 32;
        Setting.bCropSaveAs = true;
        Setting.bDraw = false;
        Setting.bPaste = false;
end

U22_makeifnotexist(savefolder);
% filelist = dir(fullfile(sourcefolder,sprintf('%s*',Setting.LoadFileNameprefix)));
filelist = dir(fullfile(sourcefolder,'*.png'));
ImageNumber = length(filelist);
for i=1:ImageNumber
    fn_load = filelist(i).name;
    fn_short = fn_load(1:end-4);
    img = imread( fullfile(sourcefolder,fn_load));
    if size(img,1)<100
        img = imresize(img,4,'nearest');
    end
    for j=1:length(Setting.block)
        X = Setting.block(j).X;
        Y = Setting.block(j).Y;
        width = Setting.block(j).width;
        height = Setting.block(j).height;
        if isfield(Setting.block(j),'PasteX');
            PasteX = Setting.block(j).PasteX;
            PasteY = Setting.block(j).PasetY;
        end
        if isfield(Setting.block(j),'Zoom');
            Zoom = Setting.block(j).Zoom;
        end
        r = Y+1;
        c = X+1;
        Crop = img(r:r+height-1,c:c+width-1,:);
        if isfield(Setting, 'bCropSaveAs')
            if Setting.bCropSaveAs
                Crop_up = imresize(Crop,4,'nearest');
                imwrite( Crop_up , fullfile(savefolder, [fn_short '_crop' num2str(j) '.png' ]));
            end
        end
        
        if isfield(Setting, 'bDraw')
            if Setting.bDraw
                T = Setting(UsedIdx).LineThickness;

                %top line
                img(Y-T+1:Y,X-T+1:X+width-1+T-1,1) = 255;
                img(Y-T+1:Y,X-T+1:X+width-1+T-1,2) = 0;
                img(Y-T+1:Y,X-T+1:X+width-1+T-1,3) = 0;
                %bottom line
                img(Y+height-1:Y+height-1+T-1,X-T+1:X+width-1+T-1,1) = 255;
                img(Y+height-1:Y+height-1+T-1,X-T+1:X+width-1+T-1,2) = 0;
                img(Y+height-1:Y+height-1+T-1,X-T+1:X+width-1+T-1,3) = 0;
                img(Y:Y+height-1,X-T+1:X,1) = 255;
                img(Y:Y+height-1,X-T+1:X,2) = 0;
                img(Y:Y+height-1,X-T+1:X,3) = 0;    
                img(Y:Y+height-1,X+width-1:X+width-1+T-1,1) = 255;
                img(Y:Y+height-1,X+width-1:X+width-1+T-1,2) = 0;
                img(Y:Y+height-1,X+width-1:X+width-1+T-1,3) = 0;    
                imwrite( img , [LoadFileName '_block.png' ]);
            end
        end
        if isfield(Setting, 'bPaste')
            if Setting.bPaste
            ZoomedCrop = imresize(Crop,Zoom);
            ZH = height * Zoom;
            ZW = width * Zoom;
            img(PasteY:PasteY+ZH-1,PasteX:PasteX+ZW-1,:) = ZoomedCrop;
            imwrite( img , [LoadFileName '_Paste.png' ]);
            end
        end
    end
end
