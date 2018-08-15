try run '../../../paths'; catch; end

N = 30;
M = 50;
T = 10;
S = 5;
W = 3;
g = .9;

trans_pre = @huge_trans_pre;
trans_pst = @huge_trans_post;

[state2vindex, ~, ~, a_f] = r_basii_4_1();

s_1 = @() state_rand();
s_a = @s_act_4_1;
r_b = @(s) a_f * state2vindex(s);
v_b = @v_basii_4_1;
r_t = [zeros(1,size(r_b(s_1()),1)-1),1];
s_r = @(s) r_t * r_b(s);

tic
Pf = approx_policy_iteration_13b(s_1, s_a, s_r, v_b, trans_pst, trans_pre, g, N, M, S, W);
toc

r_b_E = policy_eval_at_states(Pf{N+1}, state_init(), r_b, 1, T, trans_pre, 20);
fprintf('touches = %.2f', r_b_E(end));
fprintf('\n');

episodes = cell(1,5);

episodes{1} = generate_episodes_from_state(Pf{N+1}, s_1(), trans_pre, T, 15);
episodes{2} = generate_episodes_from_state(Pf{N+1}, s_1(), trans_pre, T, 15);
episodes{3} = generate_episodes_from_state(Pf{N+1}, s_1(), trans_pre, T, 15);
episodes{4} = generate_episodes_from_state(Pf{N+1}, s_1(), trans_pre, T, 15);
episodes{5} = generate_episodes_from_state(Pf{N+1}, s_1(), trans_pre, T, 15);

episodes = horzcat(episodes{:});

params = struct ('epsilon',.0001, 'gamma',.9, 'seed',0);
result = algorithm4run(episodes, params, 1);

t_reward_per_basii = r_t * a_f;
i_reward_per_basii = result'*eye(size(a_f,2));

abs(t_r - i_r)

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