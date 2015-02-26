%Jun 16 2010
%Chih-Yuan Yang EECS UC Merced
%Implement Glasner ICCV 09 paper
function yiq = RGB2YIQ( rgb )
    yiq(:,:,1) = 0.299 * rgb(:,:,1) + 0.587 * rgb(:,:,2) + 0.114 * rgb(:,:,3);
    yiq(:,:,2) = 0.595716 * rgb(:,:,1) -0.274453 * rgb(:,:,2) -0.321263 * rgb(:,:,3);
    yiq(:,:,3) = 0.211456 * rgb(:,:,1) -0.522591 * rgb(:,:,2) +0.311135 * rgb(:,:,3);
end