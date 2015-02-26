%09/06/12
%Chih-Yuan Yang
function value = OptProblem(x,inputpoints,basepoints)
    theta = x(1);
    lambda = x(2);
    deltax = x(3);
    deltay = x(4);
    pointnumber = size(inputpoints,1);
    transformmatrix = [lambda*cos(theta) -lambda*sin(theta) deltax;
                      lambda*sin(theta)  lambda*cos(theta) deltay];
    newxy = transformmatrix * cat(1, inputpoints', ones(1,pointnumber));
    diff = basepoints - newxy';
    sqr = diff .^2;
    value = sum(sqr(:));
end