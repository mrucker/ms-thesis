paths;

trajectory = jsondecode(fileread('trajectory-real-2.json'));
params     = struct ('kernel',1, 'epsilon',.0001, 'gamma',.9, 'sigma',1, 'start',1, 'steps',2, 'episodes',100, 'seed',1, 'maxdist',3526, 'maxage',1000);
result     = algorithm1run(params, trajectory, 1);

%norm([3175,1535]) == 3526.6