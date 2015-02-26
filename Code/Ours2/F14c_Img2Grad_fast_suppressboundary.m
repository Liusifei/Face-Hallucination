%Chih-Yuan Yang
%03/05/13
%add class control
%F14b: improve the speed, the boudnary is inaccurate
%F14c: resolve the boundary problem
function grad = F14c_Img2Grad_fast_suppressboundary(img)
    [h, w] = size(img);
    grad = zeros(h,w,8);
    rsup = cell(2,1);
    csup = cell(2,1);
    for i=1:8
        switch i
            case 1              %right
                rs = 0;
                cs = 1;
                rsup{1} = 'all';
                csup{1} = w;
                supnumber = 1;
            case 2              %top right
                rs = -1;
                cs = 1;
                rsup{1} = 'all';
                csup{1} = w;
                rsup{2} = 1;
                csup{2} = 'all';
                supnumber = 2;
            case 3              %top
                rs = -1;
                cs = 0;
                rsup{1} = 1;
                csup{1} = 'all';
                supnumber = 1;
            case 4              %top left
                rs = -1;
                cs = -1;
                rsup{1} = 1;
                csup{1} = 'all';
                rsup{2} = 'all';
                csup{2} = 1;
                supnumber = 2;
            case 5          %left
                rs = 0;
                cs = -1;
                rsup{1} = 'all';
                csup{1} = 1;
                supnumber = 1;
            case 6          %left bottom
                rs = 1;
                cs = -1;
                rsup{1} = 'all';
                csup{1} = 1;
                rsup{2} = h;
                csup{2} = 'all';
                supnumber = 2;
            case 7          %bottom
                rs = 1;
                cs = 0;
                rsup{1} = h;
                csup{1} = 'all';
                supnumber = 1;
            case 8          %bottom right
                rs = 1;
                cs = 1;
                rsup{1} = h;
                csup{1} = 'all';
                rsup{2} = 'all';
                csup{2} = w;
                supnumber = 2;
        end
        grad(:,:,i) = circshift(img,[-rs,-cs]) - img ;  %correct
        %suppress the boundary
        for supidx = 1:supnumber
            if ischar(rsup{supidx}) && strcmp(rsup{supidx},'all')
                c = csup{supidx};
                grad(:,c,i) = 0;
            end
            if ischar(csup{supidx}) && strcmp(csup{supidx},'all')
                r = rsup{supidx};
                grad(r,:,i) = 0;
            end            
        end
    end
end

