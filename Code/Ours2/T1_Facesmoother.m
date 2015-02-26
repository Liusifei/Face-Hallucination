function img = T1_Facesmoother(img)
% for super-resolution results smmother
dimg = T2_MultiDoG(img);
edge_bw = edge(rgb2gray(img),'canny',[0.01,0.12]);
img = T1_EdgeSmoothing(img, dimg, edge_bw);
end

% EDGESOMMTHIMG.m produce the edages by preserveing the edge-data in
% ref_im, and generates new pixels of other regions from dst_im.
% In face denoising it helps preserving the edge area. 
% In face beautification, it helps manipulating the mask's boundaries.
% Input:
% ref_im: original image or image layer;
% dst_im: processed image or image layer
% edge_bw: binary image of edge map;
% Output:
% rut_im: combined result image
% Sifei Liu, 05/30/2013

function rut_im = T1_EdgeSmoothing(ref_im, dst_im, edge_bw)
%% parameters configuration
w_im = double(edge_bw);
% thr = 10;
[r,c,n] = size(ref_im);
thr = floor(min(r,c)/40);
w_im(1:thr,:) = 1; w_im(end-thr:end,:) = 1;
w_im(:,1:thr) = 1; w_im(:,end-thr:end) = 1;
%% find the nearest edge point
[er,ec] = find(edge_bw == 1);
e_len = length(er);
mat = T1_RangeMat(thr);
for m = 1:e_len
    if and(and(er(m)>thr+1,er(m)<r-thr-1),and(ec(m)>thr+1,ec(m)<c-thr-1))
    w_im(er(m)-thr:er(m)+thr,ec(m)-thr:ec(m)+thr) = max(w_im(er(m)-thr:er(m)+thr,ec(m)-thr:...
        ec(m)+thr),mat);
    end
end
%% update image according to weighing map
rut_im = uint8(repmat(w_im,[1,1,n]) .* double(ref_im) + (1-repmat(w_im,[1,1,n])) .* double(dst_im));
end

%% T2_MultiDoG.m
function RI = T2_MultiDoG(I)

layer = 6;
l = floor(min(size(I,1),size(I,2))/10);
if l >= 50
    hl = fspecial('gaussian',[3,3],sqrt(2));
    l1=2;l2=3;l3=5;
else
    hl = fspecial('gaussian',[2,2],sqrt(2));
    l1=1;l2=5;l3 = l2;
end
hh = fspecial('gaussian',[l,l],sqrt(l/2));

if length(size(I)) == 3
    [L,a,b] = RGB2Lab(I);
    maxL = max(max(L));minL = min(min(L));
    L = Normalize(L,maxL,minL);
else
    maxL = max(max(I));minL = min(min(I));
    L = Normalize(I,maxL,minL);
end

DI = cell(1,layer+1);
DI{1,1} = L;
da = imfilter(a,hh);
db = imfilter(b,hh);

for m = 1:layer
    DI{1,m+1} = imfilter(DI{1,m},hl);
end
Dh = imfilter(L,hh);

% RL = DI{1,1}-(DI{1,l1}-DI{1,l2})-(DI{1,l3}-Dh);
RL = DI{1,1}-(DI{1,3}-Dh);

RI = ReNormalize(RL, maxL,minL);

if length(size(I)) == 3
    RI = Lab2RGB(RI,da,db);
end
close all
% imshow(RI);
end

function I = Normalize(I,MAX,MIN)
I = (I - MIN)/(MAX-MIN);
end

function I = ReNormalize(I, MAX, MIN)
I = I * (MAX-MIN) + MIN;
end