clear; paths; close all

%all these observations are in the trial 1 dataset

%study_1 -- 1ff40e9f5818b8978.json super back and forth (RewardId = 2)

%study_1 -- 1a92ecaf5864960f1.json very few touches but with correct radius so RL can get touches (RewardId = 3)
    %this works well but brings up an interesting conundrum. It scores all the targets highly 
    %but the dead space higher... This is broken by the way I handle the "top 10" since it makes 
    %several states equal to empty space perhaps a solution to this is to subtract empty space 
    %from targets making the majority of targets show 0 value instaed of majority showing .98

%study_1 -- a3cb0e1e586811391.json stayed entirely on the right third of the screen, otherwise normal.

%study_2 -- 1b37aabe5971bcc6c.json a normal test where I attempted to touch as many targets as I could

%study_2 -- 452515135984d0d0d.json the T_N field for this experiment is extremely high in the ThesisExperiments table.

trajectory_observations = jsondecode(fileread('../../data/entries/study_1/observations/1ff40e9f5818b8978.json'));
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

params = struct ('epsilon',.0001, 'gamma',.9, 'seed',0, 'kernel', 5);
result = algorithm4run(trajectory_episodes, params, 1);

cleaned_result_1 = result_clean_1(result);
cleaned_result_2 = result_clean_2(result);

fprintf('%s\n\n', jsonencode(cleaned_result_1));
fprintf('%s\n\n', jsonencode(cleaned_result_2));

figure('NumberTitle', 'off', 'Name', 'histogram of state rewards');

subplot(2,1,1);
hist(cleaned_result_1);
title('empty state set to 0')

subplot(2,1,2);
hist(cleaned_result_2);
title('top 3% states set to 1')

function rc = result_clean_1(result)
    %result(result > prctile(result,97)) = prctile(result,97);

    epsilon_result = result - result(1);

    if(max(epsilon_result) == 0)
        epsilon_result(epsilon_result == 0) = 1;
    end

    epsilon_result(epsilon_result<0) = 0;

    min_result = min(epsilon_result);
    max_result = max(epsilon_result);

    rc = round((epsilon_result - min_result)/(max_result-min_result),2);
end

function rc = result_clean_2(result)

    result(result > prctile(result,97)) = prctile(result,97);

    epsilon_result = result - result(1);

    if(max(epsilon_result) == 0)
        epsilon_result(epsilon_result == 0) = 1;
    end

    epsilon_result(epsilon_result<0) = 0;

    min_result = min(epsilon_result);
    max_result = max(epsilon_result);

    normal_epsilon_result = round((epsilon_result - min_result)/(max_result-min_result),2);

    rc = normal_epsilon_result;
end