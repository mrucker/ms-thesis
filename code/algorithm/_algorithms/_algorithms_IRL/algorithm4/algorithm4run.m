function irl_result = algorithm4run(episodes, params, verbosity)

    %N = 30;
    %M = 80;

    N = 20;
    M = 50;
    T = 10;
    S = 5;
    W = 3;

    episode_count  = numel(episodes);
    episode_length = size(episodes{1},2);
    
    episode_states = horzcat(episodes{:});
    episode_starts = episode_states(1:episode_length:episode_count*episode_length);

    [state2rbindex, ~, ~, a_f] = r_basii_4_1();
    
    a_n  = size(a_f,2);
    
    e_n = @(row_n,rows) cell2mat(arrayfun(@(row) [zeros(row-1,1);1;zeros(row_n-row,1)], rows, 'UniformOutput', false)');
    s_1 = @() episode_starts{randi(numel(episode_starts))};
    s_a = @s_act_4_1;
    r_b = @(s) e_n(a_n,state2rbindex(s));
    v_b = @v_basii_4_1;

    fprintf(1,'Start of Algorithm4 \n');

    params = setDefaults(params);

    if params.seed ~= 0
        rng(params.seed);
    end
    
    exp_time = 0;
    krn_time = 0;
    svm_time = 0;
    mdp_time = 0;

    E = 0;

    for e = 1:numel(episodes)
        for t = 1:size(episodes{e},2)
            E = E + params.gamma^(t-1) * r_b(episodes{e}(:,t));
        end
    end

    E = E./numel(episodes);

    ff = a_f'*a_f;
    
    % Generate random policy.
    tic;

        rand_r = rand(size(a_f,1),1);
        rand_r = rand_r/sum(abs(rand_r));

        s_r = @(s) rand_r'*a_f*r_b(s);        
        
        Pf     = approx_policy_iteration_13b(s_1, s_a, s_r, v_b, @huge_trans_post, @huge_trans_pre, params.gamma, N, M, S, W);
        rand_s = policy_eval_at_states(Pf{N+1}, episode_starts, r_b, params.gamma, T, @huge_trans_pre, ceil(150/numel(episode_starts)));

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
            rs{i} = ff*(E-sb{i-1});
            s_r   = @(s) rs{i}'*r_b(s);

            Pf    = approx_policy_iteration_13b(s_1, s_a, s_r, v_b, @huge_trans_post, @huge_trans_pre, params.gamma, N, M, S, W);
            ss{i} = policy_eval_at_states(Pf{N+1}, episode_starts, r_b, params.gamma, T, @huge_trans_pre, ceil(150/numel(episode_starts)));
        mdp_time = mdp_time + toc;

        ts{i} = sqrt(E'*ff*E + sb{i-1}'*ff*sb{i-1} - 2*E'*ff*sb{i-1});

        if verbosity ~= 0
            fprintf(1,'Completed IRL iteration, i=%d, t=%f\n',i,ts{i});
        end

        if  (abs(ts{i}-ts{i-1}) <= params.epsilon) || (ts{i} <= params.epsilon)
            break;
        end

        i = i + 1;

        tic;
        sn       = (ss{i-1}-sb{i-2})'*ff*(E-sb{i-2});
        sd       = (ss{i-1}-sb{i-2})'*ff*(ss{i-1}-sb{i-2});
        sc       = sn/sd;
        sb{i-1}  = sb{i-2} + sc*(ss{i-1}-sb{i-2});
        svm_time = svm_time + toc;
    end

    [~,i] = min(diag((E-cell2mat(ss))'*ff*(E-cell2mat(ss))));

    if verbosity ~= 0
        fprintf('\n');
        fprintf(1,'FINISHED IRL,i=%d, t=%f \n',i,ts{i});
        fprintf(1,'exp_time=%.2f;  krn_time=%.2f; svm_time=%.2f; mdp_time=%.2f; \n',[exp_time, krn_time, svm_time, mdp_time]);
    end

    [a_f*E, a_f*ss{i},a_f*(E-sb{i-1})]

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