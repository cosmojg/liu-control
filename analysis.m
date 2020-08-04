% set user-specific parameters
modelparams = '/home/cosmo/code/liu-control/conductances.mat';
cachefolder = '/home/cosmo/code/liu-control/cache/';

% load provided models
load(modelparams) % add "conductances" to workspace

% initialize data structures
stabs = zeros(length(conductances), 1);
newmets = repmat(xtools.V2metrics(0), length(conductances), 1);
oldmets = repmat(xtools.V2metrics(0), length(conductances), 1);

% determine stability of model dynamics with liu_stability
parfor i = 1:length(conductances)
    hash = hashlib.md5hash(conductances(i,:));
    if isfile(fullfile(cachefolder,[hash,'.mat']))
        temp = load(fullfile(cachefolder,[hash,'.mat']));
        stabs(i,1) = temp.stability;
        newmets(i,1) = temp.newmetrics;
        oldmets(i,1) = temp.oldmetrics;
    else
        [stability,newmetrics,oldmetrics] = liu_stability(conductances(i,:));
        parsave(fullfile(cachefolder,[hash,'.mat']),stability,newmetrics,oldmetrics);
        stabs(i,1) = stability;
        newmets(i,1) = newmetrics;
        oldmets(i,1) = oldmetrics;
    end
end

% workaround for saving in parfor loops
function [] = parsave(filename,stability,newmetrics,oldmetrics)
save(filename,'stability','newmetrics','oldmetrics');
end