function [eigvector, eigvalue, sampleMean, elapse] = PCA(data,options)
% PCA: Principle Component Analysis
%
% [eigvector, eigvalue, sampleMean, elapse] = PCA(data, options)
%
% Input:
%            data - Data matrix. Each column vector of fea is a data point.
%         options - Struct value in Matlab. The fields in options
%                   that can be set:
%
%                            PCARatio  -  The percentage of principal
%                                         component kept in the PCA
%                                         step. The percentage is
%                                         calculated based on the
%                                         eigenvalue. Default is 1
%                                         (100%, all the non-zero
%                                         eigenvalues will be kept.
%                                         If PCARatio > 1, the PCA step
%                                         will keep exactly PCARatio principle
%                                         components (does not exceed the
%                                         exact number of non-zero
%                                         components).  

if ~exist('data','var')
    global data;
end

if (~exist('options','var'))
   options = [];
end
if ~isfield(options,'PCARatio')
    options.PCARatio = 1;
end

tmp_T = cputime;

% ====== Initialization
[nFea,nSmp] = size(data);
if issparse(data)
    data = full(data);
end
sampleMean = mean(data,2);
data = (data - repmat(sampleMean,1,nSmp));

% ======= decomposition
if nSmp > nFea
    ddata = data*data';
    ddata = max(ddata,ddata');

    [eigvector, eigvalue] = eig(ddata);
    eigvalue = diag(eigvalue);
    clear ddata;

    maxEigValue = max(abs(eigvalue));
    eigIdx = find(eigvalue/maxEigValue < 1e-12);
    eigvalue(eigIdx) = [];
    eigvector(:,eigIdx) = [];

    [junk, index] = sort(-eigvalue);
    eigvalue = eigvalue(index);
    eigvector = eigvector(:, index);

    %=======================================
    if options.PCARatio > 1
        idx = options.PCARatio;
        if idx < length(eigvalue)
            eigvalue = eigvalue(1:idx);
            eigvector = eigvector(:,1:idx);
        end
    elseif options.PCARatio < 1
        sumEig = sum(eigvalue);
        sumEig = sumEig*options.PCARatio;
        sumNow = 0;
        for idx = 1:length(eigvalue)
            sumNow = sumNow + eigvalue(idx);
            if sumNow >= sumEig
                break;
            end
        end
        eigvalue = eigvalue(1:idx);
        eigvector = eigvector(:,1:idx);
    end
else
    ddata = data'*data;
    ddata = max(ddata,ddata');

    [eigvector, eigvalue] = eig(ddata);
    eigvalue = diag(eigvalue);
    clear ddata;

    maxEigValue = max(eigvalue);
    eigIdx = find(eigvalue/maxEigValue < 1e-12);
    eigvalue(eigIdx) = [];
    eigvector(:,eigIdx) = [];

    [junk, index] = sort(-eigvalue);
    eigvalue = eigvalue(index);
    eigvector = eigvector(:, index);

    %=======================================
    if options.PCARatio > 1
        idx = options.PCARatio;
        if idx < length(eigvalue)
            eigvalue = eigvalue(1:idx);
            eigvector = eigvector(:,1:idx);
        end
    elseif options.PCARatio < 1
        sumEig = sum(eigvalue);
        sumEig = sumEig*options.PCARatio;
        sumNow = 0;
        for idx = 1:length(eigvalue)
            sumNow = sumNow + eigvalue(idx);
            if sumNow >= sumEig
                break;
            end
        end
        eigvalue = eigvalue(1:idx);
        eigvector = eigvector(:,1:idx);
    end

    eigvector = data*eigvector;
    for i = 1:size(eigvector,2)
        eigvector(:,i) = eigvector(:,i)./norm(eigvector(:,i));
    end
end

elapse = cputime - tmp_T;