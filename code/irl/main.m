add_ourpaths;

trajectory = jsondecode(fileread('trajectory.json'));
params     = struct ('kernel',1, 'epsilon',.001, 'gamma',.9, 'sigma',1);
result     = algorithm5run(params, trajectory, 1);