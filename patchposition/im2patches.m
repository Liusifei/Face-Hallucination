% function to convert an image into patches according to a possible mask
% note that for now im has to be a grayscale image
function [patches,max_x,max_y] = im2patches(im,patchSize,intervalSize)

if exist('boundarySize','var')~=1
    boundarySize = ceil(patchSize/2);
end
% if boundarySize < patchSize
%     error('The boundary size must be equal to or greater than the patch size!');
% end

% the grid of a patch
[p_xx,p_yy]=meshgrid(-patchSize/2:patchSize/2-1,-patchSize/2:patchSize/2-1);
nDim = numel(p_xx);

[height,width]=size(im);

[grid_xx,grid_yy]=meshgrid(boundarySize+1:intervalSize:width-boundarySize+1,boundarySize+1:intervalSize:height-boundarySize+1);
% [ind_xx,ind_yy]=meshgrid(1:size(grid_xx,2),1:size(grid_xx,1));
if nargin > 1
    max_x = size(grid_xx,2);
    max_y = size(grid_xx,1);
end
grid_xx = grid_xx(:); grid_yy = grid_yy(:);
% ind_xx = ind_xx(:); ind_yy = ind_yy(:);

% if exist('mask','var')==1
%     if ~isempty(mask)
%         index = mask(sub2ind([height,width],grid_yy(:),grid_xx(:)))>0.5;
%         grid_xx = grid_xx(index);
%         grid_yy = grid_yy(index);
%     end
% end

nPatches = numel(grid_xx);
Patches = struct('x',{},'y',{},'vec',{[]});
xx = repmat(p_xx(:)',[nPatches,1]) + repmat(grid_xx(:),[1,nDim]);
yy = repmat(p_yy(:)',[nPatches,1]) + repmat(grid_yy(:),[1,nDim]);
index = sub2ind([height,width],yy(:),xx(:));

patches = reshape(im(index),[nPatches,nDim]);
% for ii = 1:nPatches
%    Patches(ii).x = grid_xx(ii);
%    Patches(ii).y = grid_yy(ii);
% %    Patches(ii).indx = ind_xx(ii);
% %    Patches(ii).indy = ind_yy(ii);
%    Patches(ii).vec = patches(ii,:);
% end

