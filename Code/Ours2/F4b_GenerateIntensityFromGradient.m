%Chih-Yuan Yang
%09/29/12
%F4b: change first gradient from F19 to F19a, which uses a precise Gaussian kernel
%Gradually incrase the coef of high-low term to achieve the contrained optimization problem
%07/20/14 This file should be replaced by F4e
%function img_out = F4b_GenerateIntensityFromGradient(img_y,img_initial,Grad_exp,Gau_sigma,bReport)
    
    LoopNumber = 30;
    beta0_initial = 1;      %beginning
    beta1_initial = 1;
    
    zooming = size(img_initial,1)/size(img_y,1);
    if zooming ~= floor(zooming)
        error('zooming should be an integer');
    end
    
    I = img_initial;
    linesearchstepnumber = 20;
    term_intensity_check = zeros(linesearchstepnumber,1);
    term_gradient_check = zeros(linesearchstepnumber,1);
    [h w] = size(img_initial);
    for updatenumber = 0:10
        beta0 = beta0_initial;
        beta1 = beta1_initial * 0.5^updatenumber;
        for loop = 1:LoopNumber
            %refine image by low-high intensity
            img_lr_gen = F19a_GenerateLRImage_GaussianKernel(I,zooming,Gau_sigma);
            diff_lr = img_lr_gen - img_y;
            diff_hr = IF5_Upsample(diff_lr,zooming, Gau_sigma);
            Grad0 = diff_hr;

            %refine image by expected gradeint
            %Gradient decent
            OptDir = Grad_exp - F14_Img2Grad(I);
            Grad1 = sum(OptDir,3);
            Grad_all = beta0 * Grad0 + beta1 * Grad1;

            I_in = I;       %make a copy, restore the value if all beta fails
            tau_initial = 1;
            term_gradient_in = ComputeFunctionValue_Grad(I,Grad_exp);
            term_intensity_in = F28_ComputeSquareSumLowHighDiff(I,img_y,Gau_sigma);
            term_all_in = term_intensity_in * beta0 + term_gradient_in * beta1;
            for line_search_step=1:linesearchstepnumber    %try to change here for speed up
                tau = tau_initial * 0.5^(line_search_step-1);
                I_check = I_in - tau * Grad_all;
                term_gradient_check(line_search_step) = ComputeFunctionValue_Grad(I_check,Grad_exp);
                term_intensity_check(line_search_step) = F28_ComputeSquareSumLowHighDiff(I_check,img_y,Gau_sigma);
            end
            
            term_all_check = term_intensity_check * beta0 + term_gradient_check * beta1;
            [sortvalue ix] = sort(term_all_check);
            if sortvalue(1) < term_all_in
                %update 
                search_step_best = ix(1);
                tau_best = tau_initial * 0.5^(search_step_best-1);
                I_best = I_in - tau_best * Grad_all;
                I = I_best;     %assign the image for next loop
            else
                break;
            end
            if bReport
                fprintf(['updatenumber=%d, loop=%d, all_in=%0.3f, all_out=%0.3f, Intensity_in=%0.3f, Intensity_out=%0.3f, ' ...
                'Grad_in=%0.3f, Grad_out=%0.3f\n'],updatenumber, loop,term_all_in,sortvalue(1),term_intensity_in,...
                term_intensity_check(ix(1)), term_gradient_in,term_gradient_check(ix(1)));        
            end
        end
    end
    img_out = I_best;
end
function diff_hr = IF5_Upsample(diff_lr,zooming, Gau_sigma)
    [h w] = size(diff_lr);
    h_hr = h*zooming;
    w_hr = w*zooming;
    upsampled = zeros(h_hr,w_hr);
    if zooming == 3
        for rl = 1:h
            rh = (rl-1) * zooming + 2;
            for cl = 1:c
                ch = (cl-1) * zooming + 2;
                upsampled(rh,ch) = diff_lr(rl,cl);
            end
        end
        kernel = Sigma2Kernel(Gau_sigma);
        diff_hr = imfilter(upsampled,kernel,'replicate');
    elseif zooming == 4
        %compute the kernel by ourself, assuming the range is 
        %control the kernel and the position of the diff
        kernelsize = ceil(Gau_sigma * 3)*2+2;      %+2 this is the even number
        kernel = fspecial('gaussian',kernelsize,Gau_sigma);
        %subsample diff_lr to (3,3), because of the result of imfilter
        for rl = 1:h
            rh = (rl-1) * zooming + 3;
            for cl = 1:w
                ch = (cl-1) * zooming + 3;
                upsampled(rh,ch) = diff_lr(rl,cl);
            end
        end
        diff_hr = imfilter(upsampled, kernel,'replicate');
    else
        error('not processed');
    end
end

function f = ComputeFunctionValue_Grad(img, Grad_exp)
    Grad = F14_Img2Grad(img);
    Diff = Grad - Grad_exp;
    Sqrt = Diff .^2;
    f = sqrt(sum(Sqrt(:)));
end