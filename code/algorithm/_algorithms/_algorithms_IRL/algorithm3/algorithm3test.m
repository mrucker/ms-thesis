try run '../../../paths'; catch; end

N = 50;
M = 80;

%N = 10;
%M = 10;

T = 10;
S = 5;
W = 5;
g = .9;

trans_pre = @huge_trans_pre;
trans_pst = @huge_trans_post;

s_1 = @( ) state_rand();
s_a = @s_act_3;
r_b = @r_basii_3_4;
v_b = @v_basii_3_2;

r_b_count = size(r_b(s_1()),1);

%finish this guy
s_r = @(s) [zeros(1,r_b_count-1),1] * r_b(s);

tic
Pf = approx_policy_iteration_8(s_1, s_a, s_r, v_b, trans_pst, trans_pre, g, N, M, S, W);
toc

%this needs to be episodes not feature expectation

E = policy_eval_at_states(Pf{N+1}, {s_1(),s_1(),s_1()}, r_b, 1, T, trans_pre, 20);

fprintf('touches = %.2f', E(end));
fprintf('\n');

episodes = cell(1,5);

episodes{1} = generate_episodes_from_state(Pf{N+1}, s_1(), trans_pre, T, 15);
episodes{2} = generate_episodes_from_state(Pf{N+1}, s_1(), trans_pre, T, 15);
episodes{3} = generate_episodes_from_state(Pf{N+1}, s_1(), trans_pre, T, 15);
episodes{4} = generate_episodes_from_state(Pf{N+1}, s_1(), trans_pre, T, 15);
episodes{5} = generate_episodes_from_state(Pf{N+1}, s_1(), trans_pre, T, 15);

episodes = horzcat(episodes{:});

params = struct ('epsilon',.0001, 'gamma',.9, 'seed',0);
result = algorithm3run(episodes, params, 1);

function s = state_rand()
    population = {
       [1145;673;-8;-2;-1;6;-7;4;3175;1535;156];
       [1158;673;15;0;10;0;5;0;3175;1535;156;626;555;155;2249;305;60];
       [2358;345;203;-153;-79;-68;87;5;3175;1535;156;626;555;953;2249;305;857;1895;1165;536;2847;278;369;2941;1297;225;2701;465;80]
   };

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