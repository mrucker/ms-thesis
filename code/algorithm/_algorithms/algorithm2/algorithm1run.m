function irl_result = algorithm1run(params, trajectories, verbosity)

    fprintf(1,'Start of Algorithm5 \n');

    params = setDefaults(params);

    if params.seed ~= 0
        rng(params.seed);
    end

    exp_time = 0;
    krn_time = 0;
    svm_time = 0;
    mdp_time = 0;
    mix_time = 0;

    ft = @(a,c,d) features(a,c,d,params);
    fe = @(a,b,c,d,e,f) mean(cell2mat(arrayfun(@(a_i) featureExpectation_bb(a(:,a_i), b, c, d, e, f, ft),1:size(a,2), 'UniformOutput', false)),2);

    sE = 0;
    %pE = [];

    
    
    %[T,N] = size(trajectories);
    
    %start    = params.start;
    %steps    = params.steps;
    %episodes = params.episodes;
    
    start    = 1;
    steps    = 2;
    episodes = 100;

    
    tic;
    for n= 0:(episodes-1)
        %pE = reshape(trajectories{1+start,n}(3:8),[],3);
        for t= 0:steps
            st = ft(trajectories{start+t+n}(1:2), trajectories{start+t+n}(3:8), trajectories{start+t+n}(9:end));
            sE = sE + (st * params.gamma^t)/episodes;
            %pE = horzcat(trajectories{t+start,n}(1:2), pE);
        end
    end
    exp_time = exp_time + toc;

    actions        = createActionsMatrix();
    startLocations = [];
    targetStepData = cell(episodes+steps,1);

    for n = 0:(episodes-1)
        startLocations(:,n+1) = trajectories{start+n}(1:8);
    end

    for t=1:episodes+steps
        targetStepData{t} = trajectories{start+t-1,1}(9:end);
        targetStepData{t} = reshape(targetStepData{t}, [], numel(targetStepData{t})/3);
    end

    % Generate random policy.
    tic;
    rand_r = rand(1,size(sE,1))';
    rand_r = rand_r/sum(rand_r);
    rand_s = fe(startLocations, targetStepData, steps, actions, rand_r, params.gamma);
    mdp_time = mdp_time + toc;

    rs = {rand_r};
    %ps = {rand_p};
    ss = {rand_s};
    sb = {rand_s};
    ts = {Inf};

    if verbosity ~= 0
        fprintf(1,'Completed IRL iteration, i=%d, t=%f\n',1,ts{1});
    end;
    
    i = 2;

    while 1

        tic;
        rs{i}    = (sE-sb{i-1});
        ss{i}    = fe(startLocations, targetStepData, steps, actions, rs{i}, params.gamma);
        mdp_time = mdp_time + toc;

        ts{i} = sqrt(sE'*sE + sb{i-1}'*sb{i-1} - 2*sE'*sb{i-1});

        if verbosity ~= 0
            fprintf(1,'Completed IRL iteration, i=%d, t=%f\n',i,ts{i});
        end;

        if  (abs(ts{i}-ts{i-1}) <= params.epsilon) || (ts{i} <= params.epsilon)
            break;
        end;

        i = i + 1;

        tic;
        sn       = (ss{i-1}-sb{i-2})'*(sE-sb{i-2});
        sd       = (ss{i-1}-sb{i-2})'*(ss{i-1}-sb{i-2});
        sc       = sn/sd;
        sb{i-1}  = sb{i-2} + sc*(ss{i-1}-sb{i-2});
        svm_time = svm_time + toc;
    end;

    tic;
    [~,idx] = max(mixPolicies(sE, ss));
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

    [~,i] = min(sqdist(sE,cell2mat(ss)));
    %-diff(ps{idx},1,2)
    %-diff(ps{i},1,2)
    %-diff(pE(:,1:4),1,2)

    ss{i}
    ss{idx}
    sE
    rs{i}
    rs{idx}

    
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