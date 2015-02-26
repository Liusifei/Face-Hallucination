function patch = GetLocalPatch(localimage, cnn, cind,intervalSize,patchSize,max_y,max_x)

    boundarySize = ceil(patchSize/2);
    [indy,indx] = ind2sub([max_y,max_x],cnn);
    patch = zeros(patchSize * patchSize,length(cnn));

    for m = 1:length(cnn)
        indm = (indy(m)-1)*intervalSize+boundarySize+1;
        indn = (indx(m)-1)*intervalSize+boundarySize+1;
        patch(:,m) = reshape(localimage(indm-3:indm+2,indn-3:indn+2,cind(m)),patchSize^2,1);
    end
end