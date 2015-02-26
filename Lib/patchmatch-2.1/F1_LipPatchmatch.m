function [a_recos,b_recos] = F1_LipPatchmatch(I_expr, max_expr, trans_L_test, ep_mask, mask)

[L_expr,~,~] = RGB2Lab(I_expr);
L_expr = (L_expr-min(L_expr(:)))/(max_expr-min(L_expr(:)));
lip_expr = L_expr .* ep_mask.lip;
lip_test = trans_L_test .* mask.lip;
lip_expr_color = I_expr .* repmat(ep_mask.lip,[1,1,3]);

cores = 2;    % Use more cores for more speed

if cores==1
  algo = 'cpu';
else
  algo = 'cputiled';
end

patch_w = 5;
ann = nnmex(repmat(lip_test,[1,1,3]), repmat(lip_expr,[1,1,3]), algo, ...
    patch_w, [], [], [], [], [], cores);
% Display reconstruction
recos_test = im2double(votemex(lip_expr_color, ann));
[~,a_recos,b_recos] = RGB2Lab(recos_test);
% imshow(recos_test)       % Coherence