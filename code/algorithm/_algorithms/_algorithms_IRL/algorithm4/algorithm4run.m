function irl_result = algorithm4run(episodes, params, verbosity)

    a_start = tic;

    r_basii = @r_basii_4_9;        
    
    N = 30;
    M = 90;
    S = 3;
    W = 4;

    
    
    %N = 30;
    %M = 70;
    %S = 3;
    %W = 3;

    T = 10;

    p_time = 0;
    s_time = 0;

    episode_count  = numel(episodes);
    episode_length = size(episodes{1},2);

    episode_states = horzcat(episodes{:});
    episode_starts = episode_states(1:episode_length:episode_count*episode_length);

    %this represents the number of times we evaluate an episode start
    %when calculating feature expectation. Through experimentation it
    %seemed important that this wasn't less than 1 (aka, randomly pick 
    %a subset of episode starts) while anything greater than 1 didn't add
    %much accuracy but greatly increased execution time.
    EVAL_N = 1;    

    [state2identity, a_f, a_b] = r_basii();
    
    adp_algorithm = @approx_policy_iteration_13h;

    s_1 = @() episode_starts{randi(numel(episode_starts))};
    s_a = s_act_4_2();
    r_b = state2identity;
    v_b = @v_basii_4_4;

    fprintf(1,'Start of Algorithm4 \n');

    params = setDefaults(params);

    if params.seed ~= 0
        rng(params.seed);
    end

    E = 0;

    for e = 1:numel(episodes)
        for t = 1:size(episodes{e},2)
            assert(all(a_f * r_b(episodes{e}(:,t)) == a_b(episodes{e}(:,t))), 'something is wrong with the r_basii');
            E = E + params.gamma^(t-1) * r_b(episodes{e}(:,t));
        end
    end

    E = E./numel(episodes);

    ff = k(a_f,a_f,params.kernel);

    i  = 1;
    rs = {};
    ss = {};
    sb = {};
    ts = {};

    % Generate arbitray reward

    rs{i} = ff*rand(size(ff,1),1);
    s_r   = @(s) rs{i}'*r_b(s);

    t_start = tic;
        Pf    = adp_algorithm(s_1, s_a, s_r, v_b, @huge_trans_post, @huge_trans_pre, params.gamma, N, M, S, W);
    p_time = p_time + toc(t_start);

    t_start = tic;
        ss{i} = policy_eval_at_states(Pf{N+1}, episode_starts, r_b, params.gamma, T, @huge_trans_pre, EVAL_N);
    s_time = s_time + toc(t_start);

    sb{i} = ss{i};
    ts{i} = Inf;

    if verbosity ~= 0
        fprintf(1,'Completed IRL iteration, i=%d, t=%f\n',1,ts{1});
    end

    i = 2;

    while 1

        rs{i} = ff*(E-sb{i-1});
        s_r   = @(s) rs{i}'*r_b(s);

        t_start = tic;
            Pf    = adp_algorithm(s_1, s_a, s_r, v_b, @huge_trans_post, @huge_trans_pre, params.gamma, N, M, S, W);
        p_time = p_time + toc(t_start);

        t_start = tic;
            ss{i} = policy_eval_at_states(Pf{N+1}, episode_starts, r_b, params.gamma, T, @huge_trans_pre, EVAL_N);
        s_time = s_time + toc(t_start);

        ts{i} = sqrt(E'*ff*E + sb{i-1}'*ff*sb{i-1} - 2*E'*ff*sb{i-1});

        if verbosity ~= 0
            fprintf(1,'Completed IRL iteration, i=%d, t=%f\n',i,ts{i});
        end

        if  (abs(ts{i}-ts{i-1}) <= params.epsilon) || (ts{i} <= params.epsilon)
            break;
        end

        i = i + 1;

        sn       = (ss{i-1}-sb{i-2})'*ff*(E-sb{i-2});
        sd       = (ss{i-1}-sb{i-2})'*ff*(ss{i-1}-sb{i-2});
        sc       = sn/sd;
        sb{i-1}  = sb{i-2} + sc*(ss{i-1}-sb{i-2});
    end

    [m,i] = min(diag((E-cell2mat(ss))'*ff*(E-cell2mat(ss))));

    a_time = toc(a_start);
    
    if verbosity ~= 0
        fprintf('\n');
        fprintf(1,'FINISHED IRL,i=%d, t=%f \n',i,ts{i});
        fprintf(1,'p_time=%.2f; s_time=%.2f; a_time=%.2f \n',[p_time, s_time, a_time]);
    end

    m
    [a_f*E, a_f*ss{i}]'

    %irl_result = a_f * (E-sb{i-1});
    irl_result = rs{i};
end

function p = setDefaults(params)
    % Fill in default parameters.
    if ~isfield(params,'seed')
        params.('seed') = 0;
    end

    if ~isfield(params,'kernel')
        params.('kernel') = 1;
    end

    if ~isfield(params,'sigma')
        params.('sigma') = 1;
    end

    if ~isfield(params,'gamma')
        params.('gamma') = .9;
    end

    if ~isfield(params,'epsilon')
        params.('epsilon') = .01;
    end
    
    if ~isfield(params,'kernel')
        params.('kernel') = 1;
    end

    p = params;
end

function k = k(x1, x2, kernel)
    p = 2;
    c = 1;
    s = .5;

    switch kernel
        case 1
            b = k_dot();
        case 2
            b = k_polynomial(k_hamming(1),p,c);
        case 3
            b = k_hamming(0);
        case 4
            b = k_equal(k_norm());
        case 5
            b = k_gaussian(k_norm(),s);
        case 6
            b = k_exponential(k_norm(),s);
        case 7
            b = k_anova(size(x1,1));
        case 8
            b = k_exponential_compact(k_norm(),s);
    end

    k = b(x1,x2);
end