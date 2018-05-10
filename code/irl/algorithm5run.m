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
    F = [
      1  0  0  0  0  0; %distance
      1 -1  0  0  0  0; %velocity
      1 -2  1  0  0  0; %acceleration
      1 -3  3 -1  0  0; %jerk
      0  0  0  0  1  0; %touched
      0  0  0  0  0  1; %age
    ];        

    maxD = params.maxdist; %makes sure all distances \in [0,1]
    maxT = 1;              %makes sure touches between [0,1]  (because we average 1 is the max)
    maxA = params.maxage;  %makes sure age is between [0,1]   (because we average 1000 is the max)
    
    %column [1,2,3,4]/maxDistance
    %column [5]/maxTouch
    %column [6]/maxAge
    %Each row divided by max(sum(postive)) [note, this means a reward is always R <= 1, that is no lower bound]
    F = diag(1./sum(F.*(F>0),2)) * F * diag([1/maxD,1/maxD,1/maxD,1/maxD,1/maxT,1/maxA]);
    %ff = k(F,F, params);
    ff = eye(6) * diag([1/maxD,1/maxD,1/maxD,1/maxD,1/maxA,1/maxT]);
    
    %I used this when doing kernels, it just doesn't seem to work well at all.
    %ff = diag(1./sum(ff.*(ff>0),2)) * ff * diag([1/maxD,1/maxD,1/maxD,1/maxD,1/maxT,1/maxA]);

    %[d1,d2,d3,d4,touched,age]
    sE = zeros(6,1);
    pE = [];

    start = 0;
    
    [T,N] = size(trajectories);
    T = min([T,params.steps+1]);
    tic;
    for n=1:N
        pE = reshape(trajectories{1+start,n}(3:8),[],3);
        for t=1:T
            st = features(trajectories{t+start,n}(1:2), trajectories{t+start,n}(3:8), trajectories{t+start,n}(9:end));
            sE = sE + (1/N) * params.gamma^(t-1) * st;
            pE = horzcat(trajectories{t+start,n}(1:2), pE);
        end
    end
    exp_time = exp_time + toc;    

    actions        = createActionsMatrix();
    startLocation  = reshape(trajectories{1+start,1}(1:8), [], 4);
    targetStepData = cell(T,1);    

    for t=1:T
        targetStepData{t} = trajectories{t+start,1}(9:end);
        targetStepData{t} = reshape(targetStepData{t}, [], numel(targetStepData{t})/3);
    end

    % Generate random policy.
    tic;
    %come back to this...
    rand_r = rand(1,6)';    
    rand_r = rand_r - min(rand_r);
    rand_r = rand_r/sum(rand_r);
    rand_r = ff' * rand_r;
    
    
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
        %rs{i}         = rs{i} - min(rs{i});
        %rs{i}         = rs{i}/sum(rs{i});
        [ps{i},ss{i}] = featureExpectation(startLocation, targetStepData, actions, rs{i}, params.gamma);
        mdp_time = mdp_time + toc;

        ts{i} = sqrt(sE'*ff*sE + sb{i-1}'*ff*sb{i-1} - 2*sE'*ff*sb{i-1});

        if verbosity ~= 0
            fprintf(1,'Completed IRL iteration, i=%d, t=%f\n',i,ts{i});
        end;

        if  (abs(ts{i}-ts{i-1}) <= params.epsilon) || (ts{i} <= params.epsilon)
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

    -diff(ps{idx},1,2)
    -diff(pE(:,1:4),1,2)
    [~,i] = min(sqdist(sE,cell2mat(ss)))
    
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

    dx = dx*1;
    dy = dy*1;
    
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