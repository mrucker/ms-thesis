function irl_result = algorithm3run(episodes, params, verbosity)

    %N = 30;
    %M = 80;

    N = 10;
    M = 50;
    T = 10;
    S = 5;
    W = 5;

    episode_count  = numel(episodes);
    episode_length = size(episodes{1},2);
    
    episode_states = horzcat(episodes{:});
    epsidoe_starts = episode_states(1:episode_length:episode_count*episode_length);

    s_1 = @( ) epsidoe_starts{randi(numel(epsidoe_starts))};
    s_a = @s_act_3;
    r_b = @r_basii_3_4;
    v_b = @v_basii_3_2;

    fprintf(1,'Start of Algorithm3 \n');

    params = setDefaults(params);

    if params.seed ~= 0
        rng(params.seed);
    end

    exp_time = 0;
    krn_time = 0;
    svm_time = 0;
    mdp_time = 0;
    mix_time = 0;

    E = 0;

    for e = 1:numel(episodes)
        for t = 1:size(episodes{e},2)
            E = E + params.gamma^(t-1) * r_b(episodes{e}(:,t));
        end
    end

    E = E./numel(episodes);    

    % Generate random policy.
    tic;

        rand_r = rand(size(E,1),1);
        rand_r = rand_r/sum(abs(rand_r));

        s_r = @(s) rand_r'*r_b(s);

        Pf = approx_policy_iteration_7(s_1, s_a, s_r, v_b, @huge_trans_post, @huge_trans_pre, params.gamma, N, M, S, W);
        rand_s = policy_eval_at_states(Pf{N+1}, epsidoe_starts, r_b, params.gamma, T, @huge_trans_pre, 20);

    mdp_time = mdp_time + toc;

    rs = {rand_r};
    ss = {rand_s};
    sb = {rand_s};
    ts = {Inf};    

    if verbosity ~= 0
        fprintf(1,'Completed IRL iteration, i=%d, t=%f\n',1,ts{1});
    end

    i = 2;

    while 1

        tic;
        rs{i} = (E-sb{i-1});
        rs{i} = rs{i}./sum(abs(rs{i}));
        s_r   = @(s) rs{i}'*r_b(s);

        Pf = approx_policy_iteration_7(s_1, s_a, s_r, v_b, @huge_trans_post, @huge_trans_pre, params.gamma, N, M, S, W);
        ss{i} = policy_eval_at_states(Pf{N+1}, epsidoe_starts, r_b, params.gamma, T, @huge_trans_pre, 2);

        mdp_time = mdp_time + toc;

        ts{i} = sqrt(E'*E + sb{i-1}'*sb{i-1} - 2*E'*sb{i-1});

        if verbosity ~= 0
            fprintf(1,'Completed IRL iteration, i=%d, t=%f\n',i,ts{i});
        end

        if  (abs(ts{i}-ts{i-1}) <= params.epsilon) || (ts{i} <= params.epsilon)
            break;
        end

        i = i + 1;

        tic;
        sn       = (ss{i-1}-sb{i-2})'*(E-sb{i-2});
        sd       = (ss{i-1}-sb{i-2})'*(ss{i-1}-sb{i-2});
        sc       = sn/sd;
        sb{i-1}  = sb{i-2} + sc*(ss{i-1}-sb{i-2});
        svm_time = svm_time + toc;
    end

    x1 = E;
    x2 = cell2mat(ss);

    [~,i] = min((dot(x1,x1,1)+dot(x2,x2,1)'-2*(x2'*x1)));

    if verbosity ~= 0
        fprintf('\n');
        fprintf(1,'FINISHED IRL,i=%d, t=%f \n',i,ts{i});
        fprintf(1,'exp_time=%.2f;  krn_time=%.2f; svm_time=%.2f; mdp_time=%.2f; \n',[exp_time, krn_time, svm_time, mdp_time]);
    end

    [E,ss{i},rs{i}]

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

    p = params;
end

function k = k(x1, x2, params)
    %p = params.p;
    %c = params.c;
    sigma = params.sigma;

    switch params.kernel
        case 1
            b = k_dot();
        case 2
            %b = k_polynomial(k_hamming(1),p,c);
        case 3
            b = k_hamming(0);
        case 4
            b = k_equal(k_norm());
        case 5
            b = k_gaussian(k_norm(),sigma);
        case 6
            b = k_exponential(k_norm(),sigma);
        case 7
            b = k_anova(size(x1,1));
        case 8
            b = k_exponential_compact(k_norm(),sigma);
    end

    k = b(x1,x2);
end