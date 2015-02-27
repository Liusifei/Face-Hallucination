%Chih-Yuan Yang
%04/25/16
%Sifei calls the TVD_dpreserve_mm three times, to regularize images along x, y, and x axis by TV norm.
%Does the paper and the original released code also work in this way consequently for x, y, and then x?
function img_texture = T1_ImprovePatchMatch(img_texture,img_y)
    %Grad_o is a set of refined gradient maps in LR
    Grad_o = T1_Img2Grad_Blockcompensate(img_y);
    y = img_texture;
    [h,w] = size(y);
    %z is the gradient map of +x direction
    z = imresize(Grad_o(:,:,1), 4, 'bilinear');

    %This is Sifei's L1L2norm-regualized gradients
    x = TVD_dpreserve_mm(y(:), z(1:end-1)', 0.036, 0.5, 50);
    x = reshape(x,[h,w])';
    %here z changes to the gradient map of +y direction
    z = imresize(Grad_o(:,:,7), 4, 'bilinear');
    x = TVD_dpreserve_mm(x(:), z(1:end-1)', 0.036, 0.8, 50);

    x = reshape(x,[w,h])';
       
    %Here z goes back to the gradient map of +x direction to smooth the gradients along x-axis again.
    %The new parameters are smaller than the ones of the first x-axis smoothing. I guess that Sifei does
    %not to want over-blur the images.
    z = imresize(Grad_o(:,:,1), 4, 'bilinear');
    x = TVD_dpreserve_mm(x(:), z(1:end-1)', 0.01, 0.5, 50);
    img_texture = reshape(x,[h,w]);
end