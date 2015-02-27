%Chih-Yuan Yang, EECS, UC Merced
%Last Modified: 08/23/12
%Solve the problem of huge patch matching to implement Liu07 methods

clear
%load data
fn_load= fullfile('LearnedResult','MiddleBandAndLocalImage');
load(fn_load,'middlebandimage');

%Quantalize
middlebandimage_i16 = int16(middlebandimage*255);

%crop patch
[h w imagenumber] = size(middlebandimage);
ps = 6;
pa = ps^2;
patchnumber = (h-ps+1)*(w-ps+1)*imagenumber;
rec = zeros(3,patchnumber,'uint16');
feature = zeros(pa,patchnumber,'int16');        %I need to use int 16 to compute the difference
idx = 0;
for ii = 1:imagenumber
    fprintf('ii %d\n',ii);
    for r=1:h-ps+1
        r2 = r+ps-1;
        for c=1:w-ps+1
            c2 = c+ps-1;
            idx = idx + 1;
            rec(:,idx) = [ii;r;c];
            feature(:,idx) = reshape(middlebandimage(r:r2,c:c2,ii),pa,1);
        end
    end
end
fn_save = 'FeatureAndRec';
savefolder = fullfile('Examples','QuantilizedFeature');
if ~exist(savefolder,'dir')
    mkdir(savefolder);
end
featuremean = mean(feature);
save(fullfile(savefolder,fn_save),'feature','rec','featuremean','-v7.3');

