%Chih-Yuan Yang
%11/07/12

clear
clc

projectfolder = fileparts(fileparts(pwd));
%usedcase = 'Ali_Landry_0071';
%usedcase = '156_02_03_051_05';
%usedcase = 'Korean146_01_01_051_05';
usedcase = 'BlackMan152_01_02_051_05';

scalingfactor_croppedregion = 4;
switch usedcase
    case 'Ali_Landry_0071'
        folder_work = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Results','Failure2','Ali_Landry_0071');
        folder_block = fullfile(folder_work,'Block');
        folder_crop = fullfile(folder_work,'Crop');
        block(1).X = 61;
        block(1).Y = 148;
        block(1).width = 45;
        block(1).height = 30;
        bCropSaveAs = true;
        bDraw = false;
        linethickness = 2;
    case '156_02_03_051_05'
        folder_work = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Results','Failure2','156_02_03_051_05');
        folder_block = fullfile(folder_work,'Block');
        folder_crop = fullfile(folder_work,'Crop');
        block(1).X = 66;
        block(1).Y = 151;
        block(1).width = 43;
        block(1).height = 27;
        bCropSaveAs = true;
        bDraw = false;
        linethickness = 2;
    case 'Korean146_01_01_051_05'
        folder_work = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Results','Upfrontal3','146_01_01_051_05');
        folder_block = fullfile(folder_work,'Block');
        folder_crop = fullfile(folder_work,'Crop');
        block(1).X = 88;
        block(1).Y = 170;
        block(1).width = 62;
        block(1).height = 50;
        bCropSaveAs = true;
        bDraw = false;
        linethickness = 2;
    case 'BlackMan152_01_02_051_05'
        folder_work = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Results','Upfrontal3','152_01_02_051_05');
        folder_block = fullfile(folder_work,'Block');
        folder_crop = fullfile(folder_work,'Crop');
        block(1).X = 81;
        block(1).Y = 224;
        block(1).width = 82;
        block(1).height = 40;
        bCropSaveAs = true;
        bDraw = false;
        linethickness = 2;        
end

filelist = dir(fullfile(folder_work,'*.png'));
imagenumber = length(filelist);
if imagenumber == 0
    error('wrong folder.');
end
for i=1:imagenumber
    fn_read = filelist(i).name;
    fn_short = fn_read(1:end-4);
    img = imread( fullfile(folder_work, fn_read));
    
    if size(img,3) == 1
        img = cat(3,img,img,img);
    end
    
    for j=1:length(block)
        X = block(j).X;
        Y = block(j).Y;
        width = block(j).width;
        height = block(j).height;
        r = Y+1;
        c = X+1;
        r1 = r+height-1;
        c1 = c+width-1;
        
        crop = img(r:r1,c:c1,:);
        if bCropSaveAs
            U22_makeifnotexist(folder_crop);
            fn_save = [fn_short '_crop' num2str(j) '.png'];
            imwrite( crop , fullfile(folder_crop,fn_save));
            fn_save = [fn_short '_crop_up' num2str(j) '.png'];
            imwrite( imresize(crop,scalingfactor_croppedregion,'nearest') , fullfile(folder_crop,fn_save));            
        end
        
        if bDraw
            T = linethickness-1;
            %top line
            img(r-1-T:r-1,c-1-T:c1+1+T,1) = 255;
            img(r-1-T:r-1,c-1-T:c1+1+T,2) = 0;
            img(Y-1-T:r-1,c-1-T:c1+1+T,3) = 0;
            %bottom line
            img(r1+1:r1+1+T,c-1-T:c1+1+T,1) = 255;
            img(r1+1:r1+1+T,c-1-T:c1+1+T,2) = 0;
            img(r1+1:r1+1+T,c-1-T:c1+1+T,3) = 0;
            %left line
            img(r:r1,c-1-T:c-1,1) = 255;
            img(r:r1,c-1-T:c-1,2) = 0;
            img(r:r1,c-1-T:c-1,3) = 0;    
            %right line
            img(r:r1,c1+1:c1+1+T,1) = 255;
            img(r:r1,c1+1:c1+1+T,2) = 0;
            img(r:r1,c1+1:c1+1+T,3) = 0;    

            U22_makeifnotexist(folder_block);
            fn_save = [fn_short '_block.png'];
            imwrite( img , fullfile(folder_block,fn_save));
        end        
    end
    
%     if isfield(UsedSetting, 'bSaveDown')
%         if bSaveDown
%             DownScale = DownScale;
%             img_Down = imresize(img,DownScale,'nearest');
%             imwrite( img_Down , [LoadFileName '_Down.png' ]);
%         end
%     end
    
    %imshow(img);
end
