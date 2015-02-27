% modified from Patch_Present.m
% reconstruct a through examplehr, with index ann;
function Cons_a = Patch_Present_SR(examplehr, ann_y, factor)

if ~exist('factor','var')
    factor = 4;
end
global SIZE; global PATCHSIZE; global INTERVALSIZE;
size = [320,256];
patchsize = PATCHSIZE * factor;
intervalSize = INTERVALSIZE * factor;
boundarySize = patchsize/2;
% intervalSize = INTERVALSIZE;
Cons_a = zeros(size);
xbegin = boundarySize; ybegin = boundarySize;

mm = 0;

for m = ybegin+1:intervalSize:size(1)-boundarySize+1
    nn = 0;
    mm = mm +1;
    for n = xbegin+1:intervalSize:size(2)-boundarySize+1
        nn = nn + 1;
        Cons_a (m-boundarySize:m+boundarySize-1,n-boundarySize:n+boundarySize-1)...
            = reshape(examplehr(ann_y(mm,nn),:),[patchsize,patchsize]);
    end
end


%             = reshape(examplehr(sub2ind(ind_size,mm,nn),:),[PATCHSIZE * factor,PATCHSIZE *factor]);
% the grid of a patch
% [p_xx,p_yy]=meshgrid(-PATCHSIZE/2:PATCHSIZE/2-1,-PATCHSIZE/2:PATCHSIZE/2-1);
% nDim = numel(p_xx);
% [grid_xx,grid_yy]=meshgrid(boundarySize+1:intervalSize:SIZE(2)-boundarySize,...
%     boundarySize+1:intervalSize:SIZE(1)-boundarySize);
% grid_xx = grid_xx(:); grid_yy = grid_yy(:);
% xx = repmat(p_xx(:)',[length(grid_xx),1]) + repmat(grid_xx(:),[1,nDim]);
% yy = repmat(p_yy(:)',[length(grid_xx),1]) + repmat(grid_yy(:),[1,nDim]);
% index = sub2ind(SIZE,yy(:),xx(:));
% n = 1;
% for m = 1:36:length(index)
%     Cons_a(index(m:m+35)) = P_b(ann(n)).vec;
%     n = n + 1;
% end
% subplot(121)
% imshow(Cons_a);
% subplot(122)
% imshow(P_a);