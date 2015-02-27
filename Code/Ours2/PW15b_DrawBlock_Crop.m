%Chih-Yuan Yang
%11/14/12
%PW15b: copied from GenericSR PW19, new feature: enlarged the cropped regions by nearest neighbor upsampling
%to prevent the bicubic interpolation executed by Acrobat Reader
clear
clc

projectfolder = fileparts(fileparts(pwd));
%usedcase = 'child';
%usedcase = 'child_half';
%usedcase = 'stonestair';
%usedcase = 'mountain';
usedcase = 'helicopter';
%usedcase = 'gorilla';
%usedcase = 'wolves';

scalingfactor_croppedregion = 4;

switch usedcase
    case 'child'
        folder_work = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Results','Child');
        folder_block = fullfile(folder_work,'Block');
        folder_crop = fullfile(folder_work,'Crop');
        block(1).X = 63;%181;
        block(1).Y = 361;%31;
        block(1).width = 40;
        block(1).height = 40;
        block(2).X = 158;%89;
        block(2).Y = 34;%112;
        block(2).width = 40;
        block(2).height = 40;
%         block(3).X = 42;
%         block(3).Y = 273;
%         block(3).width = 40;
%         block(3).height = 40;
        bCropSaveAs = true;
        bDraw = true;
        linethickness = 2;
    case 'child_half'
        folder_work = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Results','Child','Block');
        folder_block = fullfile(folder_work,'Block');
        folder_crop = fullfile(folder_work,'Crop');
        block(1).X = 0;    %283;
        block(1).Y = 0;     %87;
        block(1).width = 256;
        block(1).height = 512;
        bCropSaveAs = true;
        bDraw = false;
        linethickness = 2;
    case 'stonestair'
        folder_work = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Results','StoneStair33044');
        folder_block = fullfile(folder_work,'Block');
        folder_crop = fullfile(folder_work,'Crop');
        block(1).X = 70;
        block(1).Y = 185;
        block(1).width = 30;
        block(1).height = 30;
        block(2).X = 171;
        block(2).Y = 391;
        block(2).width = 30;
        block(2).height = 30;
        bCropSaveAs = true;
        bDraw = true;
        linethickness = 2;
    case 'mountain'
        folder_work = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Results','Mountain28083');
        folder_block = fullfile(folder_work,'Block');
        folder_crop = fullfile(folder_work,'Crop');
        block(1).X = 149;
        block(1).Y = 224;
        block(1).width = 35;
        block(1).height = 35;
        block(2).X = 297;
        block(2).Y = 35;
        block(2).width = 35;
        block(2).height = 35;
        bCropSaveAs = true;
        bDraw = true;
        linethickness = 2;
    case 'helicopter'
        folder_work = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Results','Helicopter');
        folder_block = fullfile(folder_work,'Block');
        folder_crop = fullfile(folder_work,'Crop');
        block(1).X = 266;%315;
        block(1).Y = 289;%591;
        block(1).width = 40;
        block(1).height = 40;
        block(2).X = 315;%389;
        block(2).Y = 591;%176;
        block(2).width = 40;
        block(2).height = 40;
        bCropSaveAs = true;
        bDraw = true;
        linethickness = 2;
    case 'gorilla'
        folder_work = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Results','Gorilla49024');
        folder_block = fullfile(folder_work,'Block');
        folder_crop = fullfile(folder_work,'Crop');
        block(1).X = 326;
        block(1).Y = 272;
        block(1).width = 35;
        block(1).height = 35;
        block(2).X = 375;
        block(2).Y = 154;
        block(2).width = 35;
        block(2).height = 35;
        bCropSaveAs = true;
        bDraw = true;
        linethickness = 2;
    case 'wolves'
        folder_work = fullfile(projectfolder,'PaperWriting','CVPR13','manuscript','figs','Results','Wolves196062');
        folder_block = fullfile(folder_work,'Block');
        folder_crop = fullfile(folder_work,'Crop');
        block(1).X = 169;
        block(1).Y = 225;
        block(1).width = 34;
        block(1).height = 34;
        block(2).X = 259;
        block(2).Y = 70;
        block(2).width = 50;
        block(2).height = 50;
        bCropSaveAs = true;
        bDraw = true;
        linethickness = 2;
end

filelist = dir(fullfile(folder_work,'*.png'));
imagenumber = length(filelist);
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
    
end
