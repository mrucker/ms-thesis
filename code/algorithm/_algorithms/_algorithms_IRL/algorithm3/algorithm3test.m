run '../../../paths';

params = struct ('epsilon',.0001, 'gamma',.9, 'seed',0);
result = algorithm3run(trajectory_episodes, params, 1);

%trajectory = jsondecode(fileread('huge-observed-trajectory-1.json'));


%params     = struct ('epsilon',.1, 'gamma',.9, 'start',1, 'steps',2, 'episodes',100, 'seed',0, 'maxdist',3526, 'maxage',1000);
%result     = algorithm3run(trajectory, params, 1);