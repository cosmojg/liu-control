% load provided models
load('conductances.mat')

% initialize data structures
stabs = zeros(length(conductances), 1);
newmets = repmat(xtools.V2metrics(0), length(conductances), 1);
oldmets = repmat(xtools.V2metrics(0), length(conductances), 1);

% determine stability of model dynamics with liu_stability
parfor i = 1:length(conductances)
    [stabs(i,1),newmets(i,1),oldmets(i,1)] = liu_stability(conductances(i,:));
end