function tM = MatTransfer(M)
% transfer the third dimention to the first

[r,c,n] = size(M);
tM = zeros(n,r,c);
for m = 1:n
   tM(m,:,:) = M(:,:,m);
end