clear; paths; close all

%all these observations are in the trial 1 dataset

%study 1 -- 1ff40e9f5818b8978.json super back and forth (RewardId = 2)

%study 1 -- 1a92ecaf5864960f1.json very few touches but with correct radius so RL can get touches (RewardId = 3)
    %this works well but brings up an interesting conundrum. It scores all the targets highly 
    %but the dead space higher... This is broken by the way I handle the "top 10" since it makes 
    %several states equal to empty space perhaps a solution to this is to subtract empty space 
    %from targets making the majority of targets show 0 value instaed of majority showing .98

%study 1 -- a3cb0e1e586811391.json stayed entirely on the right third of the screen, otherwise normal.

%study 2 -- 1b37aabe5971bcc6c.json a normal test where I attempted to touch as many targets as I could

%study 2 -- 452515135984d0d0d.json the T_N field for this experiment is extremely high in the ThesisExperiments table.

run_irl_on_single_experiment('2', '452515135984d0d0d');

%run_irl_on_every_experiment('3');

function run_irl_on_every_experiment(study_id)
    obs_path = ['../../data/studies/', study_id, '/observations/'];

    yn = input(['Are you sure you want to run irl on every experiment in study ', study_id, '? [y,n] ' ], 's');
    
    if(yn == 'n') 
        fprintf('aborting...\n\n');
        return;
    end
    
    fprintf('\n\n');
    
    files = dir([obs_path, '*.json']);
    
    for i = 1:numel(files)
        
        experiment_id = files(i).name(1:end-5);
        
        fprintf(['processing ' experiment_id ' (%.0f/%.0f)... \n\n'], [i,numel(files)]);
        run_irl_on_single_experiment(study_id, experiment_id);
    end
end

function run_irl_on_single_experiment(study_id, experiment_id)

    obs_path = ['../../data/studies/', study_id, '/observations/'];
    res_path = ['../../data/studies/', study_id, '/results/'];

    trajectory_episodes = read_trajectory_episodes_from_file(obs_path, experiment_id);

    params  = struct ('epsilon',.0001, 'gamma',.9, 'seed',0, 'kernel', 5);
    results = algorithm4run(trajectory_episodes, params, 1);

    write_results_to_file(results, res_path, experiment_id);
    write_results_to_screen(results, experiment_id);
end

function write_results_to_file(results, path, experiment_id)
    file_id = fopen([path, experiment_id, '.json'], 'w');
    fprintf(file_id, '%s', jsonencode(results));
    fclose(file_id);
    
    cleaned_rewards_1 = rewards_clean_1(results.rewards);
    cleaned_rewards_2 = rewards_clean_2(results.rewards);

    h = figure('NumberTitle', 'off', 'Name', ['rewards for ' experiment_id], 'Visible', 'off');   
    
    subplot(2,1,1);
    hist(cleaned_rewards_1);
    title('empty state set to 0')

    subplot(2,1,2);
    hist(cleaned_rewards_2);
    title('top 3% states set to 1')
    
    savefig(h,[experiment_id '.fig'],'compact')
end

function write_results_to_screen(results, experiment_id)

    fprintf('results for %s', experiment_id)

    results.feature_distance
    [results.expert_features, results.learned_features]'

    cleaned_rewards_1 = rewards_clean_1(results.rewards);
    cleaned_rewards_2 = rewards_clean_2(results.rewards);

    fprintf('%s\n\n', jsonencode(cleaned_rewards_1));
    fprintf('%s\n\n', jsonencode(cleaned_rewards_2));
    
    openfig([experiment_id '.fig'], 'visible');
end

function te = read_trajectory_episodes_from_file(path, experiment_id)
    
    trajectory_observations = jsondecode(fileread([path, experiment_id, '.json']));
    trajectory_states       = huge_states_from(trajectory_observations);

    trajectory_episodes_count  = 380; %we finish at (380+10+30) to trim the last second in case of noise
    trajectory_episodes_steps  = 1;   %we only do steps of 1 in order to make sure we don't miss important features
    trajectory_epsiodes_start  = 30;  %we start at 30 to trim the first second in case of noise
    trajectory_episodes_length = 10;  %this was arbitrarily chosen, but it seems to subjectively work well 

    te = cell(1,trajectory_episodes_count);

    for e = 1:trajectory_episodes_count
       episode_start = trajectory_epsiodes_start + (e-1)*(trajectory_episodes_steps);
       episode_stop  = episode_start + trajectory_episodes_length - 1;

       te{e} = trajectory_states(episode_start:episode_stop); 
    end
end

function rc = rewards_clean_1(rewards)
    %result(result > prctile(result,97)) = prctile(result,97);

    epsilon_result = rewards - rewards(1);

    if(max(epsilon_result) == 0)
        epsilon_result(epsilon_result == 0) = 1;
    end

    epsilon_result(epsilon_result<0) = 0;

    min_result = min(epsilon_result);
    max_result = max(epsilon_result);

    rc = round((epsilon_result - min_result)/(max_result-min_result),2);
end

function rc = rewards_clean_2(rewards)

    rewards(rewards > prctile(rewards,97)) = prctile(rewards,97);

    epsilon_result = rewards - rewards(1);

    if(max(epsilon_result) == 0)
        epsilon_result(epsilon_result == 0) = 1;
    end

    epsilon_result(epsilon_result<0) = 0;

    min_result = min(epsilon_result);
    max_result = max(epsilon_result);

    normal_epsilon_result = round((epsilon_result - min_result)/(max_result-min_result),2);

    rc = normal_epsilon_result;
end