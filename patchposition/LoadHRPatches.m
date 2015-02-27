function HY = LoadHRPatches(pn_ind, TrainingLow)
% pn_ind: position * rind of trainingset
% HY = zeros(size(pn_ind,2),size(pn_ind,2),size(pn_ind,1));
for m = 1:size(pn_ind,1)    % for each position
    for n = 1:size(pn_ind,2) 
        load(fullfile(TrainingLow,sprintf('HRpatches_%.4d.mat',pn_ind(m,n))),'patches');
        if m == 1
            HY = zeros(size(patches,2),size(pn_ind,2),size(pn_ind,1));
        end
        HY(:,n,m) = patches(m,:)';
    end
end