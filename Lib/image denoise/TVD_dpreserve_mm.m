function [x, cost] = TVD_dpreserve_mm(y, z, lam, beta, Nit)
% [x, cost] = TVD_mm(y, lam, Nit)
% Total variation denoising using majorization-minimization
% and a sparse linear system solver.
%
% INPUT
%   y - noisy signal
%   lam - regularization parameter
%   Nit - number of iterations
%
% OUTPUT
%   x - denoised signal
%   cost - cost function history
%
% Reference
% 'On total-variation denoising: A new majorization-minimization
% algorithm and an experimental comparison with wavalet denoising.'
% M. Figueiredo, J. Bioucas-Dias, J. P. Oliveira, and R. D. Nowak.
% Proc. IEEE Int. Conf. Image Processing, 2006.

% Ivan Selesnick
% selesi@poly.edu
% 2011

y = y(:);                                               % ensure column vector
cost = zeros(1, Nit);                                   % cost function history
N = length(y);

e = ones(N-1, 1);
DDT = spdiags([-e 2*e -e], [-1 0 1], N-1, N-1);         % D*D' (sparse matrix)
D = @(x) diff(x);                                       % D (operator)
DT = @(x) [-x(1); -diff(x); x(end)];                    % D'

% add for diff preserving
e = ones(N, 1);
e1 = 2*e;
e1(1) = 1; e1(end) = 1;
DTD = spdiags([-e e1 -e], [-1 0 1], N, N);              % D'*D (sparse matrix)
A = spdiags(e,0,N,N) + beta/2 * DTD;
e = ones(N-1, 1);
% IA = A\eye(N);

x = y;                                                  % initialization
Dx = D(x);
d = spdiags([ones(N, 1),-ones(N, 1)],[1 0], N-1, N);
dt = spdiags([ones(N, 1),-ones(N, 1)],[-1 0], N, N-1);

% add for diff preserving
Y = beta/2 * DT(z) + y;                                 % unchanged

for k = 1:Nit
%     F = 2/lam * spdiags(abs(Dx), 0, N-1, N-1) + DDT;    % F : sparse matrix
    % F = 2/lam * diag(abs(D(x))) + DDT;                % not a sparse matrix
    vk = spdiags(abs(Dx),0,N-1,N-1);
    B = beta * spdiags(ones(N-1,1),0,N-1,N-1) + ...
        (lam* spdiags(ones(N-1,1),0,N-1,N-1)) / (vk+eps * spdiags(ones(N-1,1),0,N-1,N-1));
    F = spdiags(ones(N,1),0,N,N) + 1/2 * dt * B * d;
    
%     x = y - DT(F\D(y));                                 % Solve sparse linear system
    x = F\Y;
    Dx = D(x);
    
    cost(k) = sum(abs(x-y).^2) + lam * sum(abs(Dx));    % keep cost function history
end
