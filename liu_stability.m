%{
Configure Liu controllers for a model with a given set of conductances and
determine the stability of model dynamics (burst period and duty cycle)
with controllers versus without
%}

function [stability,newmetrics,oldmetrics] = liu_stability(gbars)
assert(isvector(gbars), 'gbars is not a vector')
assert(length(gbars) == 8, 'gbars does not have 8 elements')

% make a bursting neuron
x = xolotl.examples.neurons.BurstingNeuron;

% set new conductances
x.set('*gbar', gbars);

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

% store baseline metrics (no controllers)
voltages = x.integrate;
oldmetrics = xtools.V2metrics(voltages, 'sampling_rate', 10);

% add Liu controllers to all channels (except Leak)
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
x.set('*Target',sensor_targets);

% allow model to stabilize
x.t_end = 500e3;
x.integrate;

% check if burst period and duty cycle are stable with controllers
x.t_end = 30e3;
voltages = x.integrate;
newmetrics = xtools.V2metrics(voltages, 'sampling_rate', 10);
bpdiff = abs((oldmetrics.burst_period - newmetrics.burst_period)/oldmetrics.burst_period);
dcdiff = abs((oldmetrics.duty_cycle_mean - newmetrics.duty_cycle_mean)/oldmetrics.duty_cycle_mean);
stability = bpdiff < .1 && dcdiff < .1;