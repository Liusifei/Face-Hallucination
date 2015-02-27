function CosLocalIm = LayPatches(Patchfull,ps,shiftwidth,sizeI)

CosLocalIm = zeros(sizeI);
CountAdd = zeros(sizeI);
xbegin = 4; ybegin = 4;
mm = 0;
for m = ybegin:shiftwidth:sizeI(1)-2
    nn = 0;
    mm = mm +1;
    for n = xbegin:shiftwidth:sizeI(2)-2
        nn = nn + 1;
%         CosLocalIm (m-3:m+2,n-3:n+2) =  reshape(Patchfull(:,mm,nn),[6,6]);
        CosLocalIm (m-3:m+2,n-3:n+2) = CosLocalIm (m-3:m+2,n-3:n+2) + reshape(Patchfull(:,mm,nn),[6,6]);
        CountAdd(m-3:m+2,n-3:n+2) = CountAdd(m-3:m+2,n-3:n+2)+1;
    end
end
CosLocalIm = CosLocalIm./CountAdd;