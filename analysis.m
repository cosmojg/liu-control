% load provided models
load('conductances.mat')

% initialize data structures
stabs = zeros(length(conductances), 1);
newmets = repmat(xtools.V2metrics(0), length(conductances), 1);
oldmets = repmat(xtools.V2metrics(0), length(conductances), 1);

% determine stability of model dynamics with liu_stability
parfor i = 1:length(conductances)
    hash = hashlib.md5hash(conductances(i,:));
    if isfile(fullfile('cache',[hash,'.mat']))
        temp = load(fullfile('cache',[hash,'.mat']));
        stabs(i,1) = temp.stability;
        newmets(i,1) = temp.newmetrics;
        oldmets(i,1) = temp.oldmetrics;
    else
        [stability,newmetrics,oldmetrics] = liu_stability(conductances(i,:));
        parsave(fullfile('cache',[hash,'.mat']),stability,newmetrics,oldmetrics);
        stabs(i,1) = stability;
        newmets(i,1) = newmetrics;
        oldmets(i,1) = oldmetrics;
    end
end

% workaround for saving in parfor loops
function [] = parsave(filename,stability,newmetrics,oldmetrics)
save(filename,'stability','newmetrics','oldmetrics');
end