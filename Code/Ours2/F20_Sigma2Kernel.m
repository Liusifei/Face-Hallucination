%Chih-Yuan Yang
%09/20/12
function Kernel = F20_Sigma2Kernel(Gau_sigma)
    KernelSize = ceil(Gau_sigma * 3)*2+1;
    Kernel = fspecial('gaussian',KernelSize,Gau_sigma);
end
