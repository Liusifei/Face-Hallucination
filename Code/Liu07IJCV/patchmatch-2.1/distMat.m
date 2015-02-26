function D_best = distMat(Patch_a,Patch_b,ann)
% caculate the distance matrix for Patch_a and Patch_b
% with ann as index matrix
[row,col] = size(ann);
% D_best = zeros(row,col);
% ind = sub2ind([row,col],repmat([1:row]',[col,1]),kron([1:col]',ones(row,1)));
D_best = dist(Patch_a(1:row*col,:),Patch_b(ann(:),:));
% for m = 1:row
%     for n = 1:col
%         ind = sub2ind([row,col],m,n);
%         %         D_best(m,n) = dist(Patch_a(ind).vec,Patch_b(ann(m,n)).vec);
%         D_best(m,n) = dist(Patch_a(ind,:),Patch_b(ann(m,n),:));
%     end
% end
