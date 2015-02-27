function DrawRandPatch(Cnn)

[r,row,col] = size(Cnn);
x = round(rand * col);
y = round(rand * row);
Distr = zeros(row,col);
idx = Cnn(:,y,x);
for m = 1:length(idx)
   Distr(idx) = Distr(idx)+1;
end
figure;
imshow(Distr,[])
hold on
plot(x,y,'*r')