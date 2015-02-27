%Chih-Yuan Yang
%09/15/12
%return alignedpoints for paper writing
function [alignedexampleimage alignedpoints]= F17_AlignExampleImageByLandmarkSet(exampleimage,inputpoints,basepoints)
    %inputpoints format: m x 2, m is the number of points
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
    
    %compute the aligned points
    alignedpoints_tranlate = transformmatrix * cat(1,inputpoints',ones(1,setsize));
    alignedpoints = alignedpoints_tranlate';
end
