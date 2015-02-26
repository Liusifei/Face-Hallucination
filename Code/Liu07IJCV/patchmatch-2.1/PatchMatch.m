function [D_best,ann] = PatchMatch(IM_a,IM_b,itern)

global SIZE; global PATCHSIZE; global INTERVALSIZE;
SIZE = size(IM_a);
patchSize = 6; PATCHSIZE = patchSize;
intervalSize = 4; INTERVALSIZE = intervalSize;
global MAX_X; 
global MAX_Y;

[Patches_a,max_x,max_y] = im2patches(IM_a,patchSize,intervalSize);
MAX_X = max_x;
MAX_Y = max_y;

Patches_b = im2patches(IM_b,patchSize,intervalSize);
% itern = 5;
rs_max = min(max_x,max_y);
% Global
% Global_p(max_x,max_y);

% Initial: random assignment of bx,by
bx_v = max(round(rand(1,max_x) * max_x),1);
by_v = max(round(rand(1,max_y) * max_y),1);
[bx,by]=meshgrid(bx_v,by_v);
ann = zeros(itern+1,max_y, max_x); D_best = zeros(itern+1, max_y, max_x);
ann(1,:,:) = reshape(sub2ind([max_y,max_x], by(:), bx(:)),[max_y,max_x]);
D_b = distMat(Patches_a,Patches_b,reshape(ann(1,:,:),max_y,max_x));
D_best(1,:,:) = D_b;
range = max(D_b(:))-min(D_b(:));
% figure(1);
% subplot(1,itern+1,1)
% imshow(D_b/range);
% figure(2);
% Cons_a = Patch_Present(Patches_b, reshape(ann(1,:,:),[max_y,max_x]));
% subplot(1,itern+1,1);
% imshow(Cons_a,[]);
% D(1) = sum(D_best(:));
% Iter
for m = 1:itern
    fprintf('Processing iteration %d: \n',m);
    if mod(m,2) == 0
        ystart = 1; yend = max_y; ychange = 1;
        xstart = 1; xend = max_x; xchange = 1;
    else
        ystart = max_y; yend = 1; ychange = -1;
        xstart = max_x; xend = 1; xchange = -1;
    end
    % for each patch
    for nx = xstart:xchange:xend
%         fprintf('nx: %d ', nx);
        for ny = ystart:ychange:yend
            % current best
            [ybest,xbest] = ind2sub([max_y,max_x],ann(m,ny,nx));
            dbest = D_best(m,ny,nx);
            % propergation
            if nx - xchange < max_x && nx - xchange > 0
                % left
                vp = ann(m,ny,nx-xchange);
                [by,bx] = ind2sub([max_y,max_x],vp);
                bx = bx + xchange;
                if bx < max_x && bx >0
                    [xbest,ybest,dbest] = ...
                        improve_guess(Patches_a,Patches_b,nx,ny,xbest,ybest,dbest,bx,by);
                end
            end
            if ny - ychange < max_y && ny - ychange >0
               % right
               vp = ann(m,ny-xchange,nx);
                [by,bx] = ind2sub([max_y,max_x],vp);
                by = by + ychange;
                if by < max_y && by > 0
                    [xbest,ybest,dbest] = ...
                        improve_guess(Patches_a,Patches_b,nx,ny,xbest,ybest,dbest,bx,by);
                end
            end
            %Random search: Improve current guess by searching in boxes of exponentially 
            %decreasing size around the current best guess.
%             if m == itern
                mag = rs_max;
                while mag >= 2
                    xmin = max(xbest-mag, 1); xmax = min(xbest+mag,max_x);
                    ymin = max(ybest-mag, 1); ymax = min(ybest+mag,max_y);
                    bx = round(xmin + rand*(xmax-xmin));
                    by = round(ymin + rand*(ymax-ymin));
                    [xbest,ybest,dbest] = ...
                        improve_guess(Patches_a,Patches_b,nx,ny,xbest,ybest,dbest,bx,by);
                    mag = mag/2;
                end
                ann(m+1,ny,nx) = sub2ind([max_y,max_x],ybest,xbest);
                D_best(m+1,ny,nx) = dbest;
%             end
        end
    end
%     figure(1);
%     subplot(1,itern+1,m+1);
%     imshow(reshape(D_best(m+1,:,:),size(D_best,2),size(D_best,3))/range);
%     Cons_a = Patch_Present(Patches_b, reshape(ann(m+1,:,:),[max_y,max_x]));
%     figure(2)
%     subplot(1,itern+1,m+1);
%     imshow(Cons_a,[]);
%     D(m+1) = sum(D_best(:));
end
ann = ann(2:end,:,:);
D_best = D_best(2:end,:,:);
% figure;
% plot(D);