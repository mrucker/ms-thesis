paths;

%4460e5ee57d6e87e2.json absolutely no touches (radius = 0) (but also impossible to get touches, so it is meaningless)

%1ff40e9f5818b8978.json super back and forth, seems to work well. (RewardId = 2)

%1a92ecaf5864960f1.json very few touches but with correct radius so RL can get touches
    %this works well but brings up an interesting conundrum. It scores all the targets highly 
    %but the dead space higher... This is broken by the way I handle the "top 10" since it makes 
    %several states equal to empty space perhaps a solution to this is to subtract empty space 
    %from targets making the majority of targets show 0 value instaed of majority showing .98
    
trajectory_observations = jsondecode(fileread('../../data/entries/observations/1a92ecaf5864960f1.json'));
trajectory_states       = huge_states_from(trajectory_observations);

trajectory_episodes_count  = 380; %we finish at (380+10+30) to trim the last second in case of noise
trajectory_episodes_steps  = 1;   %we only do steps of 1 in order to make sure we don't miss important features
trajectory_epsiodes_start  = 30;  %we start at 30 to trim the first second in case of noise
trajectory_episodes_length = 10;  %this was arbitrarily chosen, but it seems to subjectively work well 

trajectory_episodes = cell(1,trajectory_episodes_count);

for e = 1:trajectory_episodes_count
   episode_start = trajectory_epsiodes_start + (e-1)*(trajectory_episodes_steps);
   episode_stop  = episode_start + trajectory_episodes_length - 1;

   trajectory_episodes{e} = trajectory_states(episode_start:episode_stop); 
end

params = struct ('epsilon',.00001, 'gamma',.9, 'seed',0, 'kernel', 5);
result = algorithm4run(trajectory_episodes, params, 1);

sorted_result = sort(result);

lower = sorted_result(10);
upper = sorted_result(end-9);

epsilon_result = result;

epsilon_result(result < lower) = lower;
epsilon_result(result > upper) = upper;

min_result = min(epsilon_result);
max_result = max(epsilon_result);

normal_epsilon_result = round((epsilon_result - min_result)/(max_result-min_result),2);

jsonencode(normal_epsilon_result)

hist(normal_epsilon_result)