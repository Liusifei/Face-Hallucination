%10/23/11
function Kernel = Sigma2Kernel(Gau_sigma)
    KernelSize = ceil(Gau_sigma * 3)*2+1;
    Kernel = fspecial('gaussian',KernelSize,Gau_sigma);
end
