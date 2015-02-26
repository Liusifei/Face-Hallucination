function [xbest,ybest,dbest] = improve_guess(p_a,p_b,ax,ay,xbest,ybest,dbest,bx,by)
global MAX_X; 
global MAX_Y;
inda = sub2ind([MAX_Y,MAX_X],ay,ax);
indb = sub2ind([MAX_Y,MAX_X],by,bx);
% d_n = dist(p_a(inda).vec,p_b(indb).vec);
d_n = dist(p_a(inda,:),p_b(indb,:));
if d_n < dbest
    xbest = bx;
    ybest = by;
    dbest = d_n;
end