function V = evaluate_policy_at_state(Pf, state, eval_statistic, gamma, T, transition_pre, sample_size)

    V = cell(1, sample_size);
    
    for n = 1:sample_size

        v = zeros(size(eval_statistic(state),1), T);
        s = state;

        for t = 1:T
            v(:, t) = v(:, t) + gamma^(t-1) * eval_statistic(s);
            a       = Pf(s);
            s       = transition_pre(s,a);
        end
        
        V{n} = v;
    end
    
end