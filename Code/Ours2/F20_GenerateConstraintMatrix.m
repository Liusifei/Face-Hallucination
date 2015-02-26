%Chih-Yuan Yang
%09/19/12
%Generate the constraint matrix
function Aeq = F20_GenerateConstraintMatrix(h_hr,w_hr,Gau_sigma,zooming)
    %parse I_l = (I_h \otimes G) \downarrow to
    %v_h = Aeq * v_h
    HRpixelnumber = h_hr*w_hr;
    n = HRpixelnumber;
    LRpixelnumber = HRpixelnumber / zooming^2;
    m = LRpixelnumber;
    vectori = zeros(121*HRpixelnumber,1);
    vectorj = zeros(121*HRpixelnumber,1);
    vectors = zeros(121*HRpixelnumber,1);
    G = Sigma2Kernel(Gau_sigma);
    h_lr = h_hr/zooming;
    w_lr = w_hr/zooming;
    idx = 0;
    for k=1:m
        fprintf('k %d totoal %d\n',k,m);
        for t=1:n
            idx = idx + 1;
            img_test(r,c) = 1;
            img_lr = F19_GenerateLRImage_BlurSubSample(img_test,zooming,Gau_sigma);
            AColumn = reshape(img_lr,[LRpixelnumber,1]);
            nonzeroset = find(AColumn);
            setsize = length(nonzeroset);
            for k=1:setsize
                Aeq(k,idx) = AColumn(k);
            end
            c_old = c;
        end
        r_old = r;
    end
    
    nzmax = 121*HRpixelnumber;      %in fact, it should be slightly smaller
    Aeq = sparse(vectori,vectorj,vectors,m, n,nzmax);
end
