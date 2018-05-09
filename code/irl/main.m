add_ourpaths;

trajectory = jsondecode(fileread('trajectory-test.json'));
params     = struct ('kernel',1, 'epsilon',.001, 'gamma',.9, 'sigma',1, 'steps',4, 'seed',1, 'maxdist',15, 'maxage',1000);
result     = algorithm5run(params, trajectory, 1);

%norm([3175,1535]) == 3526.6