function ann_ss = DownSMapping(ann, ps, shiftwidth)

% initialization
sann = ones(size(ann(:,:,1)));

% get H to L coordinations
[grid_xx,grid_yy]=meshgrid(ps/2+1:shiftwidth:size(ann,2)-ps/2+1, ps/2+1:shiftwidth:size(ann,1)-ps/2+1);
[r,c] = size(grid_xx);

% sann: L-index map in H image
for m = 1:r
    for n = 1:c
        x = grid_xx(m,n); y = grid_yy(m,n);
        sann(y-ps/2:y+ps/2-1, x-ps/2:x+ps/2-1) = repmat(sub2ind([r,c],m,n),ps,ps);
    end
end

if length(size(ann))==3
    % x,y of ann mapping index
    x = ann(:,:,1)+1;
    y = ann(:,:,2)+1;
    x(or(x<1,x>240))=240; y(or(x<1,y>320))=320;
    ind = sub2ind([size(ann,1),size(ann,2)], y(:), x(:));                       % H-index 1-D set in ann
    [pind_y,pind_x] = ind2sub([r,c],sann(ind));             % restore L-index 2-D set
    pind_y = reshape(pind_y,size(sann));pind_x = reshape(pind_x,size(sann));
    pind_px = pind_x(ps/2+1:shiftwidth:size(ann,1)-ps/2+1, ps/2+1:shiftwidth:size(ann,2)-ps/2+1);   % get sampled version x
    pind_py = pind_y(ps/2+1:shiftwidth:size(ann,1)-ps/2+1, ps/2+1:shiftwidth:size(ann,2)-ps/2+1);   % get sampled version y
    ann_ss = reshape(sub2ind([size(pind_px,1),size(pind_px,2)], pind_py(:), pind_px(:)),[size(pind_px,1),size(pind_px,2)]);
else
    for chan = 1:size(ann,4)
        x = ann(:,:,1,chan)+1;
        y = ann(:,:,2,chan)+1;
        x(or(x<1,x>240))=240; y(or(y<1,y>320))=320;
        ind = sub2ind([size(ann,1),size(ann,2)], y(:), x(:));              % H-index 1-D set in ann
        [pind_y,pind_x] = ind2sub([r,c],sann(ind));                        % restore L-index 2-D set
    pind_y = reshape(pind_y,size(sann));pind_x = reshape(pind_x,size(sann));
    pind_px = pind_x(ps/2+1:shiftwidth:size(ann,1)-ps/2+1, ps/2+1:shiftwidth:size(ann,2)-ps/2+1);   % get sampled version x
    pind_py = pind_y(ps/2+1:shiftwidth:size(ann,1)-ps/2+1, ps/2+1:shiftwidth:size(ann,2)-ps/2+1);   % get sampled version y
    if chan == 1
        ann_ss = zeros(size(pind_px,1),size(pind_px,2),size(ann,4));
    end
    ann_ss(:,:,chan) = reshape(sub2ind([size(pind_px,1),size(pind_px,2)], pind_py(:), pind_px(:)),[size(pind_px,1),size(pind_px,2)]);
    end
end