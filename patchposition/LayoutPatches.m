function Cons_a = LayoutPatches(Patches, imsize, interval, patchsize)

% boundarySize = PATCHSIZE/2;
Cons_a = zeros(imsize);
o_a = ones(imsize);
k = 0;
left = patchsize/2;right = patchsize/2-1;
xbegin = left+1; ybegin = xbegin;

for n = xbegin:interval:imsize(2)-right
    for m = ybegin:interval:imsize(1)-right
        k = k + 1;
        Cons_a(m-left:m+right, n-left:n+right)=...
        Cons_a(m-left:m+right, n-left:n+right) +... 
            double(reshape(Patches(k,:),[patchsize,patchsize]));
       o_a(m-left:m+right, n-left:n+right) = ...
           o_a(m-left:m+right, n-left:n+right) + ones(patchsize);
    end
end
nn = n+right;
mm = m+right;
in = imsize(2)-nn;
Cons_a = Cons_a./o_a;
Cons_a(:,nn+1:imsize(2)) = Cons_a(:,nn:-1:nn-in+1);
Cons_a(mm+1:imsize(1),:) = repmat(Cons_a(mm,:),[imsize(1)-mm,1]);
