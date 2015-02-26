function [mat,cent] = T1_RangeMat(thr)
mat = zeros(thr*2+1);
cent = thr + 1;
for m = -thr:thr
    for n = -thr:thr
        v = (m^2 + n^2);
        if v <= thr^2
            mat(cent+m,cent+n) = exp(-v/(0.5*thr^2));
%                 mat(cent+m,cent+n) = 1 - sqrt(v^2/thr^2;
        end
    end
end