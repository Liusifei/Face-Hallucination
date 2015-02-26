function d = dist(p_a,p_b)
global MAX_X; 
global MAX_Y;
if min(size(p_a))==1
    d = sum((double(p_a)-double(p_b)).^2);
else
    d = sum((double(p_a)-double(p_b)).^2,2);
    d = reshape(d,[MAX_Y,MAX_X]);
end