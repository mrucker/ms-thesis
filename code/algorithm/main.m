paths;

trajectory_observations = jsondecode(fileread('huge-observed-trajectory-1.json'));
trajectory_states       = huge_states_from(trajectory_observations);
trajectory_states(1:4)  = []; %trim off the first four states since they have pre-game noise

trajectory_episodes_count  = 40;
trajectory_epsiodes_start  = 1;
trajectory_episodes_length = 10;

trajectory_episodes = cell(1,trajectory_episodes_count);

for e = 1:trajectory_episodes_count
   episode_start = trajectory_epsiodes_start + (e-1)*(trajectory_episodes_length);
   episode_stop  = episode_start + trajectory_episodes_length - 1;

   trajectory_episodes{e} = trajectory_states(episode_start:episode_stop); 
end

params     = struct ('epsilon',.0001, 'gamma',.9, 'seed',0, 'kernel', 5);
result     = algorithm4run(trajectory_episodes, params, 1);