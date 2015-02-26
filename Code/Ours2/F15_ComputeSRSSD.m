%03/17/12
function SRSSD = F15_ComputeSRSSD(GradOrImg)
    if size(GradOrImg,3) == 8
        Grad = GradOrImg;
    else
        Grad = F14_Img2Grad(GradOrImg);
    end
    Sqr = Grad .^2;
    Sum = sum(Sqr,3);
    SRSSD = sqrt(Sum);
end