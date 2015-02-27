function Cons_a = LayoutPatches(Patches, imsize, interval, patchsize)

% boundarySize = PATCHSIZE/2;
Cons_a = zeros(imsize);
% o_a = Cons_a;
xbegin = interval+1; ybegin = xbegin;
k = 0;
left = patchsize/2;right = patchsize/2-1;

for n = xbegin:interval:imsize(2)-interval+1
    for m = ybegin:interval:imsize(1)-interval+1
        k = k + 1;
%         Cons_a(m-left:m+right, n-left:n+right)+...
        Cons_a(m-left:m+right, n-left:n+right) =... 
            double(reshape(Patches(k,:),[patchsize,patchsize]));
%        o_a(m-left:m+right, n-left:n+right) = ...
%            o_a(m-left:m+right, n-left:n+right) + ones(patchsize);
    end
end
% Cons_a = Cons_a./o_a;