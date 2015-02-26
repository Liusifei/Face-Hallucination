% SHIFTBLOCK output the shift block structures
% jpeg: input jpeg data stucture
% sftblk: output shifted block stucture, including:
%       vdb: coefficients of vertical shifted block;
%       hdb: coefficients of horizontal shifted block;
%       Vvars: spatial domain of step component;
%       Vcons: spatial domain of signal containing no step fucntion;
%       Vtv: total variation in vertical direction;
%       Htv: total variation in horizontal direction;
% Only y channel has been processed in this version
%       Sifei Liu, 21/03/2013

function sftblk = T1_shiftblock(jpeg)

% get y channel
if isstruct(jpeg)
    image = rgb2ycbcr(im2double(jpeg.image));
else
    image = repmat(jpeg,[1,1,3]);
end
[h,w,~] = size(image);
r = mod(size(image,1),8);
c = mod(size(image,2),8);
if r~=0
    image = [image;repmat(image(end,:,:),[8-r,1,1])];
end
if c~=0
    image = [image,repmat(image(:,end,:),[1,8-c,1])];
end

% vertical db
% y_v = image(:,5:end-4,1) * 255;
% y_v = y_v - 128;
y_v = image(:,5:end-4,1);
sftblk.Vdb = bdct(y_v);
% vertical mask
vmask = zeros(8);
vmask(1,2:2:end) = 1; %vmask(2:2:end,1) = 1;
% vmask(1,1)=1;
% vcmask = ones(8) - vmask;
vmask(1,2:2:end) = [ -0.9061 0.3182 -0.2126 0.1802]; 

% image layers
[m,n] = size(sftblk.Vdb);

% % ====== new version ======
vars_beta = sftblk.Vdb .* repmat(vmask,size(sftblk.Vdb)/8);
vars_beta = vars_beta * kron(eye(size(sftblk.Vdb,2)/8),ones(8,1));
vars_beta = vars_beta(1:8:end,:);
vmask(1,2:2:end) = 1;
dct_vars = (sftblk.Vdb .* repmat(vmask,size(sftblk.Vdb)/8)).*...
    kron(vars_beta,ones(8));
sftblk.Vvars = ibdct(dct_vars);
dct_cons = sftblk.Vdb - dct_vars;
sftblk.Vcons = ibdct(dct_cons);
% % =========================
sftblk.Vcons = [repmat(sftblk.Vcons(:,1),1,4),sftblk.Vcons,repmat(sftblk.Vcons(:,end),1,4)];
sftblk.Vvars = [repmat(sftblk.Vvars(:,1),1,4),sftblk.Vvars,repmat(sftblk.Vvars(:,end),1,4)];
sftblk.Vcons = sftblk.Vcons(1:h,1:w);
sftblk.Vvars = sftblk.Vvars(1:h,1:w);
% sftblk.Vvars = ibdct(sftblk.Vdb .* repmat(vmask,size(sftblk.Vdb)/8));
% sftblk.Vvars = (sftblk.Vvars + 48) / 255;
% sftblk.Vcons = ibdct(sftblk.Vdb .* repmat(vcmask,size(sftblk.Vdb)/8));
% sftblk.Vcons = (sftblk.Vcons + 80) / 255;


% % sum along y axies for each block
% m_ax = kron(eye(m/8),ones(1,8));
% m_ay = kron(eye(n/8),[ones(3,1);100;ones(4,1)]);
% y_ax = m_ax * sftblk.Vvars;
% sftblk.Vtv = abs(y_ax - [y_ax(:,2:end),y_ax(:,end)]) * m_ay;
% 
% % horizontal db
y_h = image(5:end-4,:,1);
% y_h = image(5:end-4,:,1) * 255;
% y_h = y_h - 125.5;
sftblk.Hdb = bdct(y_h);
% % horizontal mask
hmask = zeros(8);
hmask(2:2:end,1) = [ -0.9061 0.3182 -0.2126 0.1802]';

% % ====== new version ======
vars_beta = sftblk.Hdb .* repmat(hmask,size(sftblk.Hdb)/8);
vars_beta = kron(eye(size(sftblk.Hdb,1)/8),ones(1,8)) * vars_beta;
vars_beta = vars_beta(:,1:8:end);
hmask(2:2:end,1) = 1;
dct_vars = (sftblk.Hdb .* repmat(hmask,size(sftblk.Hdb)/8)).*...
    kron(vars_beta,ones(8));
sftblk.Hvars = ibdct(dct_vars);
dct_cons = sftblk.Hdb - dct_vars;
sftblk.Hcons = ibdct(dct_cons);
% % =========================
sftblk.Hcons = [repmat(sftblk.Hcons(1,:),4,1);sftblk.Hcons;repmat(sftblk.Hcons(end,:),4,1)];
sftblk.Hvars = [repmat(sftblk.Hvars(1,:),4,1);sftblk.Hvars;repmat(sftblk.Hvars(end,:),4,1)];
sftblk.Hcons = sftblk.Hcons(1:h,1:w);
sftblk.Hvars = sftblk.Hvars(1:h,1:w);
% hcmask = ones(8) - hmask;
% % image layers
% sftblk.Hvars = ibdct(sftblk.Hdb .* repmat(hmask,size(sftblk.Hdb)/8));
% sftblk.Hvars = (sftblk.Hvars + 125.5) / 255;
% sftblk.Hcons = ibdct(sftblk.Hdb .* repmat(hcmask,size(sftblk.Hdb)/8));
% sftblk.Hcons = (sftblk.Hcons + 125.5) / 255;
% % sum along x axies for each block
% [m,n] = size(sftblk.Hvars);
% m_ax = kron(eye(m/8),[ones(1,3),5,ones(1,4)]);
% m_ay = kron(eye(n/8),ones(8,1));
% y_ay = sftblk.Hvars * m_ay;
% sftblk.Htv = m_ax * abs(y_ay - [y_ay(2:end,:);y_ay(end,:)]);

