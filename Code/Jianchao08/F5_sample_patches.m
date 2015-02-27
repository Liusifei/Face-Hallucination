%Chih-Yuan Yang
%10/29/12
%Export this function form F1a_rnd_smp_dictionary
function [HP, LP] = F5_sample_patches(img_reconstructed, img_original, patchsize, patch_num)

[nrow, ncol] = size(img_reconstructed);

x = randperm(nrow-patchsize+1);
y = randperm(ncol-patchsize+1);
[X,Y] = meshgrid(x,y);

xrow = X(:);
ycol = Y(:);

xrow = xrow(1:patch_num);
ycol = ycol(1:patch_num);

% compute the first and second order gradients
hf1 = [-1,0,1];
vf1 = [-1,0,1]';
 
grad1 = conv2(img_reconstructed,hf1,'same');
grad2 = conv2(img_reconstructed,vf1,'same');
 
hf2 = [1,0,-2,0,1];
vf2 = [1,0,-2,0,1]';
 
grad3 = conv2(img_reconstructed,hf2,'same');
grad4 = conv2(img_reconstructed,vf2,'same');

featurelength_hr = patchsize^2;
featurelength_lr = 4*patchsize^2;
HP = zeros(featurelength_hr,patch_num);
LP = zeros(featurelength_lr,patch_num);
for idx = 1:patch_num,
    
    hrow = xrow(idx);
    hcol = ycol(idx);
    Hpatch = img_original(hrow:hrow+patchsize-1,hcol:hcol+patchsize-1);
    
    Lpatch1 = grad1(hrow:hrow+patchsize-1,hcol:hcol+patchsize-1);
    Lpatch2 = grad2(hrow:hrow+patchsize-1,hcol:hcol+patchsize-1);
    Lpatch3 = grad3(hrow:hrow+patchsize-1,hcol:hcol+patchsize-1);
    Lpatch4 = grad4(hrow:hrow+patchsize-1,hcol:hcol+patchsize-1);
     
    Lpatch = [Lpatch1(:);Lpatch2(:);Lpatch3(:);Lpatch4(:)];
     
    HP(:,idx) = Hpatch(:)-mean(Hpatch(:));
    LP(:,idx) = Lpatch;
end


    
    