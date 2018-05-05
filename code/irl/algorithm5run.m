% Abbeel & Ng algorithm implementation (projection version) with my kernel stuff.
function irl_result = algorithm5run(algorithm_params, mdp_data, example_samples,verbosity)

    fprintf(1,'Start of Algorithm5 \n');
    
    % Fill in default parameters.   
    if ~isfield(algorithm_params,'epsilon') 
        algorithm_params.('epsilon') = .01;
    end
    
    if ~isfield(algorithm_params,'seed') 
        algorithm_params.('seed') = 0;
    end
    
    if ~isfield(algorithm_params,'seed') 
        algorithm_params.('seed') = 0;
    end
    
    if ~isfield(algorithm_params,'k') 
        algorithm_params.('k') = 1;
    end
    
    if ~isfield(algorithm_params,'s') 
        algorithm_params.('s') = 1;
    end

    % Set random seed.
    if algorithm_params.seed ~= 0
        rng(algorithm_params.seed);
    end

    exp_time = 0;
    krn_time = 0;
    svm_time = 0;
    mdp_time = 0;
    mix_time = 0;

    % Initialize variables.
    [states,actions,~] = size(mdp_data.sa_p);
    [N,T] = size(example_samples);
    
    F = [
      1  0  0  0  0;
      1 -1  0  0  0;
      1 -2  1  0  0;
      1 -3  3 -1  0;
    ];
        
    % Construct state expectations
    sE = zeros(states,1);

    tic;
    for i=1:N
        for t=1:T
            sE(example_samples{i,t}(1)) = sE(example_samples{i,t}(1)) + 1*mdp_data.discount^(t-1);
        end
    end
    exp_time = exp_time + toc;
        
    sE = sE/N;
    
    % Generate random policy.        
    tic;
    rand_r = rand(states,1);
    rand_r = rand_r - min(rand_r);
    rand_p = standardmdpsolve(mdp_data, rand_r);
    rand_s = standardmdpfrequency(mdp_data, rand_p);
    mdp_time = mdp_time + toc;    

    rs = {rand_r};
    ps = {rand_p};
    ss = {rand_s};
    sb = {rand_s};
    ts = {0};

    tic;
    ff = k(F,F, algorithm_params);
    krn_time = krn_time + toc;
    
    i = 2;
    
    while 1

        tic;
        rs{i} = ff*(sE-sb{i-1});
        rs{i} = rs{i} - min(rs{i});
        ps{i} = standardmdpsolve(mdp_data,repmat(rs{i},1,actions));
        ss{i} = standardmdpfrequency(mdp_data, ps{i});        
        mdp_time = mdp_time + toc;

        ts{i} = sqrt(sE'*ff*sE + sb{i-1}'*ff*sb{i-1} - 2*sE'*ff*sb{i-1});

        if verbosity ~= 0
            fprintf(1,'Completed IRL iteration, i=%d, t=%f\n',i,ts{i});
        end;

        if (abs(ts{i}-ts{i-1}) <= algorithm_params.epsilon)
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

function [lambda] = mixPolicies(sE, ss, ff)
    s_mat = cell2mat(ss);
    
    ssffss = s_mat'*ff*s_mat;
    seffse = sE'*ff*sE;
    seffss = sE'*ff*s_mat;
    
    % In Abbeel & Ng's algorithm, we should use lambda to construct a stochastic policy. 
    % However for our purposes, we'll simply pick the reward with the largest lambda weight.
    cvx_begin
        cvx_quiet(true);
        variables l(s_cnt);
        minimize(l'*ssffss*l + seffse - 2*seffss*l);
        subject to
            l >= 0;
            1 == sum(l);
    cvx_end
    
    lambda = l;
end

function k = k(x1, x2, params)
    p = params.p;
    s = params.s;
    c = params.c;
    n = size(x1,1);
        
    switch params.k
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
            b = k_exponential(k_hamming(0),s);
        case 7
            b = k_anova(n);
        case 8
            b = k_exponential_compact(k_norm(),s);
    end
       
    k = b(x1,x2);
end