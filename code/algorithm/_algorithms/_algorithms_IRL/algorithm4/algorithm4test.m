try run '../../../paths'; catch; end

N = 30;
M = 70;
S = 3;
W = 3;

T = 10;
g = .9;

trans_pre = @huge_trans_pre;
trans_pst = @huge_trans_post;

[state2vindex, ~, ~, a_f] = r_basii_4_2();

r_r = rand(1, size(a_f,2));
r_r = 500*r_r/max(r_r);

s_1 = @() state_rand();
s_a = s_act_4_1();
r_b = @(s) a_f * state2vindex(s);
v_b = @v_basii_4_2;
r_t = rand(size(r_b(s_1()),1), 1);
s_r = @(s) r_t' * a_f * state2vindex(s);

[Pf, ~, ~, ~, ~, ~, f_time, b_time, m_time, a_time] = approx_policy_iteration_13h(s_1, s_a, s_r, v_b, trans_pst, trans_pre, g, N, M, S, W);
[f_time, b_time, m_time, a_time]

episodes = cell(1,5);

inits = state_init();

episodes{1} = generate_episodes_from_state(Pf{N+1}, inits{1}, trans_pre, T, 100);
episodes{2} = generate_episodes_from_state(Pf{N+1}, inits{2}, trans_pre, T, 100);
episodes{3} = generate_episodes_from_state(Pf{N+1}, inits{3}, trans_pre, T, 100);

episodes = horzcat(episodes{:});

params1 = struct ('epsilon',.00001, 'gamma',.9, 'seed',0, 'kernel', 1);
params2 = struct ('epsilon',.00001, 'gamma',.9, 'seed',0, 'kernel', 5);

result_1 = algorithm4run(episodes, params1, 1);

[(r_t-min(r_t))/max((r_t-min(r_t))),(result_1-min(result_1))/max((result_1-min(result_1)))]

%result_2 = algorithm4run(episodes, params2, 1);

%tru_reward_for_each_unique_basii_set   = r_r;
%irl_reward_for_each_unique_basii_set_1 = result_1'*eye(size(a_f,2));
%irl_reward_for_each_unique_basii_set_2 = result_2'*eye(size(a_f,2));

%tru_reward_for_each_unique_basii_set   = tru_reward_for_each_unique_basii_set   - min(tru_reward_for_each_unique_basii_set);
%irl_reward_for_each_unique_basii_set_1 = irl_reward_for_each_unique_basii_set_1 - min(irl_reward_for_each_unique_basii_set_1);
%irl_reward_for_each_unique_basii_set_2 = irl_reward_for_each_unique_basii_set_2 - min(irl_reward_for_each_unique_basii_set_2);

%tru_reward_for_each_unique_basii_set   = tru_reward_for_each_unique_basii_set/max(tru_reward_for_each_unique_basii_set);
%irl_reward_for_each_unique_basii_set_1 = irl_reward_for_each_unique_basii_set_1/max(irl_reward_for_each_unique_basii_set_1);
%irl_reward_for_each_unique_basii_set_2 = irl_reward_for_each_unique_basii_set_2/max(irl_reward_for_each_unique_basii_set_2);

%[
%    norm(tru_reward_for_each_unique_basii_set - irl_reward_for_each_unique_basii_set_1, 2), ...
%    norm(tru_reward_for_each_unique_basii_set - irl_reward_for_each_unique_basii_set_2, 2);
%    norm(tru_reward_for_each_unique_basii_set - irl_reward_for_each_unique_basii_set_1, 1), ...
%    norm(tru_reward_for_each_unique_basii_set - irl_reward_for_each_unique_basii_set_2, 1);
%]

function s = state_init()
    s = {
       [1145;673;-8;-2;-1;6;-7;4;3175;1535;156;626;555;155;2249;305;60];
       [1158;673;15;0;10;0;5;0;3175;1535;156;626;555;155;2249;305;60];
       [1588;768;0;0;0;0;0;0;3175;1535;156;626;555;155;2249;305;60];
   };
end

function s = state_rand()
    population = state_init();

    s = population{randi(numel(population))};
end

function E = generate_episodes_from_state(Pf, state, transition_pre, episode_length, episode_count)

    E = cell(1, episode_count);

    for n = 1:episode_count

        episode    = cell(1,episode_length);
        episode{1} = state;

        for t = 2:episode_length
            episode{t} = transition_pre(episode{t-1}, Pf(episode{t-1}));
        end

        E{n} = episode;
    end
    
end