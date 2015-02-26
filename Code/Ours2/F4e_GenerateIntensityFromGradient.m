%Chih-Yuan Yang
%07/20/14
%F4b: change first gradient from F19 to F19a, which uses a precise Gaussian kernel
%F4c: F4b is too slow, change the parameters
%F4d: open all parameters because they matter
%Gradually incrase the coef of high-low term to achieve the contrained optimization problem
%F4e: I replace the internal functon IF5 by the external function F26 since they are the same. I also
%     replace the F19a by F19c to support the scaling factor of 3. In addition, F19c is simpler than
%     F19a. I also update the term zooming to scalingfactor.
function img_out = F4e_GenerateIntensityFromGradient(img_y,img_initial,Grad_exp,Gau_sigma,bReport,...
    loopnumber,totalupdatenumber,linesearchstepnumber,beta0,beta1,tolf)

    scalingfactor = size(img_initial,1)/size(img_y,1);
    if scalingfactor ~= floor(scalingfactor)
        error('scalingfactor should be an integer');
    end
    
    I = img_initial;
    I_best = I;
    term_intensity_check = zeros(linesearchstepnumber,1);
    term_gradient_check = zeros(linesearchstepnumber,1);
    [h, w] = size(img_initial);
    for updatenumber = 0:totalupdatenumber
        %beta0 = beta0_initial;
        %beta1 = beta1_initial * 0.5^updatenumber;
        for loop = 1:loopnumber
            %refine image by low-high intensity
            img_lr_gen = F19c_GenerateLRImage_GaussianKernel(I,scalingfactor,Gau_sigma);
            diff_lr = img_lr_gen - img_y;
            diff_hr = F26_UpsampleAndBlur(diff_lr,scalingfactor, Gau_sigma);
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
            for line_search_step=1:linesearchstepnumber
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
                term_best = sortvalue(1);
            else
                break;
            end
            if bReport
                fprintf(['updatenumber=%d, loop=%d, all_in=%0.3f, all_out=%0.3f, Intensity_in=%0.3f, Intensity_out=%0.3f, ' ...
                'Grad_in=%0.3f, Grad_out=%0.3f\n'],updatenumber, loop,term_all_in,term_best,term_intensity_in,...
                term_intensity_check(ix(1)), term_gradient_in,term_gradient_check(ix(1)));        
            end
            if term_best > term_all_in - tolf
                break
            end
        end
    end
    img_out = I_best;
end

function f = ComputeFunctionValue_Grad(img, Grad_exp)
    Grad = F14_Img2Grad(img);
    Diff = Grad - Grad_exp;
    Sqrt = Diff .^2;
    f = sqrt(sum(Sqrt(:)));
end