function TVL_test = TV(dL_test,lam, Nit, mask)

if exist('mask','var')
  dL_test =  dL_test .* mask; 
end
[h,w,c] = size(dL_test);
TVL_test = zeros(h,w,c);
for k = 1:c
    y = dL_test(:,:,k); y = y(:);
    x = TVD_mm(y, lam, Nit);
    x = reshape(x,[h,w])';
    y = x(:);
    x = TVD_mm(y, lam, Nit);
    TVL_test(:,:,k) = reshape(x,[w,h])';
end