% make a bursting neuron
x = xolotl.examples.neurons.BurstingNeuron;

% debug, see this for verbosity flags
% https://xolotl.readthedocs.io/en/master/reference/matlab/xolotl/#verbosity
x.verbosity = 7;

% add sensors to neuron
% note that all components
% will appear in alphabetical order
% and "Z" comes before "a"
x.AB.add('DCSensor')
x.AB.add('FastSensor')
x.AB.add('SlowSensor')
x.AB.add('FSDTarget')


% measure sensor values at baseline
x.t_end = 30e3;
x.integrate;
[~,~,M] = x.integrate;
sensor_targets = mean(M);

% now add Liu controllers to all channels (except Leak)
channels = setdiff(x.AB.find('conductance'),'Leak');
for i = 1:length(channels)
	x.AB.(channels{i}).add('LiuController');
end

% set the magic numbers from Table 1 of Liu et al. 
x.AB.NaV.LiuController.A = 1;
x.AB.CaS.LiuController.B = 1;
x.AB.CaT.LiuController.B = 1;

x.AB.Kd.LiuController.A = 1;
x.AB.Kd.LiuController.B = -1;

x.AB.KCa.LiuController.B = -1;
x.AB.KCa.LiuController.C = -1;

x.AB.ACurrent.LiuController.B = -1;
x.AB.ACurrent.LiuController.C = -1;

x.AB.ACurrent.LiuController.B = 1;
x.AB.ACurrent.LiuController.C = 1;

% configure targets 
x.set('*Target',sensor_targets)


x.t_end = 3e3;
x.integrate;