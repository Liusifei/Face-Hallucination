%This is Sifei's code to remove the blocky artifacts.
%The idea is to average gradients of pixels along every 8x8 block
%What is the difference of Grad_o and Grad_v?
function Grad_o = T1_Img2Grad_Blockcompensate(img)

bz = 8;
sftblk = T1_shiftblock(img);
% normalization
% img = (img-min(min(img)))/(max(max(img))-min(min(img)));
% sftblk.Vcons = (sftblk.Vcons-min(min(sftblk.Vcons)))/(max(max(sftblk.Vcons))-min(min(sftblk.Vcons)));
% get gradient images
Grad_o = T1_Img2Grad(img);
Grad_v = T1_Img2Grad(sftblk.Vcons);
Grad_h = T1_Img2Grad(sftblk.Hcons);
dir_num = size(Grad_o,3);
% % ========== for debug ===========
% for k = 1:dir_num
% subplot(2,dir_num,k);imshow(Grad_o(:,:,k),[]);
% end
% % ========== for debug ===========
% replace vertical blocking

for m = 1:dir_num
    % v8
%     if ~isempty(find(m == [1 2 8],1))
        for n = bz:bz:size(img,2)
            %         Grad_o(:,n,m) = (Grad_o(:,n-1,m)+Grad_o(:,n+1,m))/2;
            %         Grad_o(:,n,m) = Grad_v(:,n,m);
            Grad_o(:,n,m) = (Grad_o(:,n-1,m)+Grad_o(:,n+1,m)+Grad_v(:,n,m))/3;
        end
%     end
%     if ~isempty(find(m == [6 7 8],1))
        % h8
        for n = bz:bz:size(img,1)-bz/2
            Grad_o(n,:,m) = (Grad_h(n,:,m) + Grad_o(n-1,:,m) + Grad_o(n+1,:,m))/3;
        end
%     end
        % v9
%     if ~isempty(find(m == [4 5 6],1))
        for n = bz+1:bz:size(img,2)
            %         Grad_o(:,n,m) = (Grad_o(:,n-1,m)+Grad_o(:,n+1,m))/2;
            %         Grad_o(:,n,m) = Grad_v(:,n,m);
            Grad_o(:,n,m) = (Grad_o(:,n-1,m)+Grad_o(:,n+1,m)+Grad_v(:,n,m))/3;
        end
%     end
        % h9
%     if ~isempty(find(m == [2 3 4],1))
        for n = bz+1:bz:size(img,2)
            %         Grad_o(:,n,m) = (Grad_o(:,n-1,m)+Grad_o(:,n+1,m))/2;
            %         Grad_o(:,n,m) = Grad_v(:,n,m);
            Grad_o(n,:,m) = (Grad_h(n,:,m) + Grad_o(n-1,:,m) + Grad_o(n+1,:,m))/3;
        end
%     end
end
% % ========== for debug ===========
% for k = 1:dir_num
% subplot(2,dir_num,dir_num+k);imshow(Grad_o(:,:,k),[]);
% end
% % ========== for debug ===========