%Chih-Yuan Yang
%09/15/12
%Change function name from U20 to F18
%The different from U17: There are 20 points, solve an optimization problem to determine the trasnform matrix
function alignedexampleimage = F18_AlignExampleImageByLandmarkSet(exampleimage,inputpoints,basepoints)
    %use shift and scaling only as the initial variables
    initial_shift = mean(basepoints(:,:)) - mean(inputpoints(:,1));
    initial_deltax = initial_shift(1);
    initial_deltay = initial_shift(2);
    initial_lambda = 1;
    initial_theta = 0;
    initial_variable = [initial_theta, initial_lambda, initial_deltax, initial_deltay];
    
    %solve the optimization problem
    options = optimset('Display','off','TolX',1e-4);
    [x fval]= fminsearch(@(x) OptProblem(x,inputpoints,basepoints), initial_variable, options);

    theta = x(1);
    lambda = x(2);
    deltax = x(3);
    deltay = x(4);
    transformmatrix = [lambda*cos(theta) -lambda*sin(theta) deltax;
                      lambda*sin(theta)  lambda*cos(theta) deltay];
    %take two points most apart to generate input points
    inputpoint1 = inputpoints(1,:)';
    setsize = size(inputpoints,1);
    dxdy = inputpoints - repmat(inputpoints(1,:),[setsize,1]);
    distsqr = sum(dxdy.^2,2);
    [sortresults ix] = sort(distsqr,'descend');
    farestpointidx = ix(1);
    inputpoint2 = inputpoints(farestpointidx,:)';
    inputpoints_2points = cat(1, inputpoint1',inputpoint2');
    basepoint1 = transformmatrix * cat(1,inputpoint1,1);
    basepoint2 = transformmatrix * cat(1,inputpoint2,1);
    basepoints_2points = cat(1, basepoint1', basepoint2');
    
    [h w d] = size(exampleimage);
    tform = cp2tform(inputpoints_2points, basepoints_2points,'nonreflective similarity');
    %generated the transform images
    XData = [1 w];
    YData = [1 h];
    alignedexampleimage = imtransform(exampleimage,tform,'XData',XData,'YData',YData);
end
