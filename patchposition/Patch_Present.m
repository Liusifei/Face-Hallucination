function Cons_a = Patch_Present(P_b, ann)

global SIZE; global PATCHSIZE; global INTERVALSIZE;
% boundarySize = PATCHSIZE/2;
intervalSize = INTERVALSIZE;
Cons_a = zeros(SIZE);
xbegin = 4; ybegin = 4;
mm = 0;
for m = ybegin:intervalSize:SIZE(1)-2
    nn = 0;
    mm = mm +1;
    for n = xbegin:intervalSize:SIZE(2)-2
        nn = nn + 1;
        Cons_a (m-3:m+2,n-3:n+2) = reshape(P_b(ann(mm,nn)).vec,[6,6]);
    end
end

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