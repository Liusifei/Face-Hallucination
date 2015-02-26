%Chih-Yuan Yang
%08/29/12

%the two base_points are assumed horizontal
function transformmatrix = F44_ComputeTransformMatrix(input_points, base_points)
    %check whether the two base_points are horizontal
    point1.y = base_points(1,2);
    point2.y = base_points(2,2);
    if point1.y ~= point2.y
        error('Two points are not horrizontal');
    end
    
    x1 = input_points(1,1);
    y1 = input_points(1,2);
    x2 = input_points(2,1);
    y2 = input_points(2,2);
    xb1 = base_points(1,1);
    yb1 = base_points(1,2);
    xb2 = base_points(2,1);
    yb2 = base_points(2,2);
    %compute the angle of input_points from base_points
    theta = -atan((y2-y1)/(x2-x1));             %note there is a negative sign to rotate closewise
    %compute the scaling factor
    db = sqrt((xb2-xb1)^2 + (yb2-yb1)^2);
    d = sqrt((x2-x1)^2 + (y2-y1)^2);
    lambda = db/d;
    
    %1: shift to origin
    %2: rotate
    %3: scaling
    %4: shift to base points
    m1 = [1 0 -x1;
          0 1 -y1;
          0 0 1];
    m2 = [cos(theta) -sin(theta) 0;
          sin(theta)  cos(theta) 0;
          0           0          1];            
    m3 = [lambda 0      0;
          0      lambda 0;
          0      0      1];
    m4 = [1 0 xb1;
          0 1 yb1;
          0 0 1];
    transformmatrix = m4*m3*m2*m1;
end