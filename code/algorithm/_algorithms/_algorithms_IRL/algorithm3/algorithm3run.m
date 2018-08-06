function irl_result = algorithm3run(trajectory_observations, params, verbosity)

    N=10; 
    M=10;
    T=10;
    S=100;
    W=5;

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

    trajectory_states = huge_states_from(trajectory_observations);
    
    %trim off the first four states since they have pre-game noise
    trajectory_states(1:4) = [];
        
    E = 0;

    s_1 = @( ) trajectory_states{randi(numel(trajectory_states))};
    s_a = @s_act_3;
    s_b = @v_basii_3;
    
    tic;
    for t = 1:T
        E = E + params.gamma^(t-1) * r_basii_3(trajectory_states(:,t));
    end
    exp_time = exp_time + toc;
    
    % Generate random policy.
    tic;
    rand_r = rand(size(E,1),1);
    rand_r = rand_r/sum(rand_r);
        
    s_r = @(s) rand_r'*r_basii_3(s);
    [~ , Pf, ~ , ~ , ~ , ~ , ~     , ~     , ~     , ~     ] = approx_policy_iteration_7(s_1, s_a    , s_r   , s_b        , @huge_trans_post, @huge_trans_pre, params.gamma, N, M, T, W);
    rand_s = policy_eval_at_state(Pf{N+1}, trajectory_states{1}, @r_basii_3, params.gamma, T, @huge_trans_pre, S);
    rand_s = sum(cell2mat(rand_s),2)./S;
    
    
    mdp_time = mdp_time + toc;

    rs = {rand_r};
    ss = {rand_s};
    sb = {rand_s};
    ts = {Inf};

    if verbosity ~= 0
        fprintf(1,'Completed IRL iteration, i=%d, t=%f\n',1,ts{1});
    end;

    i = 2;

    while 1

        tic;
        rs{i} = (E-sb{i-1});
        s_r   = @(s) rs{i}'*r_basii_3(s);
        [~, Pf, ~, ~, ~, ~, ~, ~, ~, ~] = approx_policy_iteration_7(s_1, s_a, s_r, s_b, @huge_trans_post, @huge_trans_pre, params.gamma, N, M, T, W);
        ss{i} = policy_eval_at_state(Pf{N+1}, trajectory_states{1}, @r_basii_3, params.gamma, T, @huge_trans_pre, S);
        ss{i} = sum(cell2mat(ss{i}),2)./S;
        
        mdp_time = mdp_time + toc;

        ts{i} = sqrt(E'*E + sb{i-1}'*sb{i-1} - 2*E'*sb{i-1});

        if verbosity ~= 0
            fprintf(1,'Completed IRL iteration, i=%d, t=%f\n',i,ts{i});
        end;

        if  (abs(ts{i}-ts{i-1}) <= params.epsilon) || (ts{i} <= params.epsilon)
            break;
        end;

        i = i + 1;

        tic;
        sn       = (ss{i-1}-sb{i-2})'*(E-sb{i-2});
        sd       = (ss{i-1}-sb{i-2})'*(ss{i-1}-sb{i-2});
        sc       = sn/sd;
        sb{i-1}  = sb{i-2} + sc*(ss{i-1}-sb{i-2});
        svm_time = svm_time + toc;
    end;

    tic;
    %[~,idx] = max(mixPolicies(E, ss));
    idx = i;
    mix_time = mix_time + toc;

    t  = ts{idx};
    r  = rs{idx};

    if verbosity ~= 0
        fprintf(1,'FINISHED IRL,i=%d, t=%f \n',idx,t);
    end

    fprintf(1,'exp_time=%f \n',exp_time);
    fprintf(1,'krn_time=%f \n',krn_time);
    fprintf(1,'svm_time=%f \n',svm_time);
    fprintf(1,'mdp_time=%f \n',mdp_time);
    fprintf(1,'mix_time=%f \n',mix_time);

    x1 = E;
    x2 = cell2mat(ss);
    
    [~,i] = min((dot(x1,x1,1)+dot(x2,x2,1)'-2*(x2'*x1)));
    %-diff(ps{idx},1,2)
    %-diff(ps{i},1,2)
    %-diff(pE(:,1:4),1,2)

    ss{i}
%    ss{idx}
    E
    rs{i}
%    rs{idx}

    irl_result = r;
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

    if ~isfield(params,'steps')
        params.('steps') = 1;
    end

    p = params;
end

function a = createActionsMatrix()
    % The actions matrix should be 2 x |number of actions| where the first row is dx and the second row is dy.
    % This means each column in the matrix represents a dx/dy pair that is the action taken.

    %all combinations of (dx,dy) for dx,dy \in [-10,10]

    dx = -1:1:1;
    dy = -1:1:1;

    dx = dx*100;
    dy = dy*100;
    
    dx = [100,50,10,2,0];
    dy = [100,50,10,2,0];
    
    dx = horzcat(dx,0,-dx);
    dy = horzcat(dy,0,-dy);
        
    %dx = 1:2;
    %dy = [1,1];
    
    a = vertcat(reshape(repmat(dx,numel(dx),1), [1,numel(dx)^2]), reshape(repmat(dy',1,numel(dy)), [1,numel(dy)^2]));
end

function l = mixPolicies(sE, ss)

    s_mat = cell2mat(ss);
    s_cnt = size(s_mat,2);

    ssffss = s_mat'*s_mat;
    seffse = sE'*sE;
    seffss = sE'*s_mat;

    % In Abbeel & Ng's algorithm, we should use lambda to construct a stochastic policy. 
    % However for our purposes, we'll simply pick the reward with the largest lambda weight.
    cvx_begin
        cvx_quiet(true);
        variables lambda(s_cnt);
        minimize(lambda'*ssffss*lambda + seffse - 2*seffss*lambda);
        subject to
            lambda      >= 0;
            sum(lambda) == 1;
    cvx_end
    
    l = lambda;
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