% Abbeel & Ng algorithm implementation (projection version) with my kernel stuff.
function irl_result = algorithm5run(params, trajectories, verbosity)

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

    % Initialize variables.
    [T,N] = size(trajectories);

    T = min([T,params.steps+1]);

    F = [
      1  0  0  0  0  0; %distance
      1 -1  0  0  0  0; %velocity
      1 -2  1  0  0  0; %acceleration
      1 -3  3 -1  0  0; %jerk
      0  0  0  0  1  0; %touched
      0  0  0  0  0  1; %age
    ];

    maxDistance = norm([3175,1535]);                                %makes sure all distances \in [0,1]
    maxAge      = 1000;                                             %makes sure all ages      \in [0,1]
    normalizer  = (1/maxDistance) * diag([1,1,1/2,1/4,1,1/maxAge]); %makes sure all features will be between [0,1]

    F = F * normalizer; 

    %[d1,d2,d3,d4,touched,age]
    sE = zeros(6,1);
    pE = [];

    tic;
    for n=1:N
        pE = reshape(trajectories{1,n}(3:8),[],3);
        for t=1:T
            sE = sE + (1/N) * params.gamma^(t-1) * features(trajectories{t,n}(1:8), trajectories{t,n}(9:end));
            pE = horzcat(trajectories{t,n}(1:2), pE);
        end
    end
    exp_time = exp_time + toc;

    ff = k(F,F, params);

    actions        = createActionsMatrix();
    startLocation  = reshape(trajectories{1,1}(1:8), [], 4);
    targetStepData = cell((T),1);    

    for t=1:T
        targetStepData{t} = trajectories{t,1}(9:end);
        targetStepData{t} = reshape(targetStepData{t}, [], numel(targetStepData{t})/3);
    end

    % Generate random policy.
    tic;
    %come back to this...
    rand_r = abs(rand(1,6)');
    rand_r = F' * rand_r/sum(rand_r);
    [rand_p, rand_s] = featureExpectation(startLocation, targetStepData, actions, rand_r, params.gamma);
    mdp_time = mdp_time + toc;

    rs = {rand_r};
    ps = {rand_p};
    ss = {rand_s};
    sb = {rand_s};
    ts = {0};

    i = 2;

    while 1

        tic;
        rs{i}         = ff*(sE-sb{i-1});
        [ps{i},ss{i}] = featureExpectation(startLocation, targetStepData, actions, rs{i}, params.gamma);
        mdp_time = mdp_time + toc;

        ts{i} = sqrt(sE'*ff*sE + sb{i-1}'*ff*sb{i-1} - 2*sE'*ff*sb{i-1});

        if verbosity ~= 0
            fprintf(1,'Completed IRL iteration, i=%d, t=%f\n',i,ts{i});
        end;

        if  (abs(ts{i}-ts{i-1}) <= params.epsilon)
            break;
        end;

        i = i + 1;

        tic;
        sn       = (ss{i-1}-sb{i-2})'*ff*(sE-sb{i-2});
        sd       = (ss{i-1}-sb{i-2})'*ff*(ss{i-1}-sb{i-2});
        sc       = sn/sd;
        sb{i-1}  = sb{i-2} + sc*(ss{i-1}-sb{i-2});
        svm_time = svm_time + toc;
    end;

    tic;
    [~,idx] = max(mixPolicies(sE, ss, ff));
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

    dx = -10:5:10;
    dy = -10:5:10;

    a = vertcat(reshape(repmat(dx,numel(dx),1), [1,numel(dx)^2]), reshape(repmat(dy',1,numel(dy)), [1,numel(dy)^2]));
end

function l = mixPolicies(sE, ss, ff)

    s_mat = cell2mat(ss);
    s_cnt = size(s_mat,2);

    ssffss = s_mat'*ff*s_mat;
    seffse = sE'*ff*sE;
    seffss = sE'*ff*s_mat;

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