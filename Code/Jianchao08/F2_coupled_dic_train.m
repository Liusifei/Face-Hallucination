%Chih-Yuan Yang
%10/19/12
%reduce the iteration number to reduce the computation time
%this function needs to be further improved, to pass the temp folder of dictionary to F3_sparse_coding
%and remove the hard-coded folder in F3_sparse_coding
function [Dh, Dl] = F2_coupled_dic_train(Xh, Xl, codebook_size, lambda, iterationnumber)

addpath('Sparse coding/sc2');

hDim = size(Xh, 1);
lDim = size(Xl, 1);

% joint learning of the dictionary
X = [1/sqrt(hDim)*Xh; 1/sqrt(lDim)*Xl];
if size(X,2) > 80000
    X = X(:, 1:80000);
end
Xnorm = sqrt(sum(X.^2, 1));

clear Xh Xl;

X = X(:, Xnorm > 1e-5);
X = X./repmat(sqrt(sum(X.^2, 1)), hDim+lDim, 1);

idx = randperm(size(X, 2));
Binit = X(:, idx(1:codebook_size));
                                      %why is this lambda/2?
fn_save_temp = 'Dictionary_temp';
[D] = F3_sparse_coding(X, codebook_size, lambda/2, 'L1', [], iterationnumber, 5000, fn_save_temp, [], Binit);

Dh = D(1:hDim, :);
Dl = D(hDim+1:end, :);

% normalize the dictionary
Dh = Dh./repmat(sqrt(sum(Dh.^2, 1)), hDim, 1);
Dl = Dl./repmat(sqrt(sum(Dl.^2, 1)), lDim, 1);





