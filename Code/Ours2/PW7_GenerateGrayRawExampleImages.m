%Chih-Yuan Yang
%09/15/12
%Generate gray example images for paper writing
sourcefolder = fullfile('Examples','Training');
savefolder = fullfile('Examples','Training_Gray');
U22_makeifnotexist(savefolder);
filelist = dir(fullfile(sourcefolder,'*.png'));
filenumber = length(filelist);
for i=1:filenumber
    fprintf('i %d filenumber %d\n',i,filenumber);
    fn_read = filelist(i).name;
    img_read = imread(fullfile(sourcefolder,fn_read));
    img_gray = rgb2gray(img_read);
    fn_write = fn_read;
    imwrite(img_gray,fullfile(savefolder,fn_write));
end