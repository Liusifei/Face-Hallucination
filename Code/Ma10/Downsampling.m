function L = Downsampling(H,factor)

[row,col] = size(H);
L = H(1:factor:row,1:factor:col);