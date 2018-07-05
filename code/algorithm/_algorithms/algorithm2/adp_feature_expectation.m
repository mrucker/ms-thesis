function fe = adp_feature_expectation(r_theta, s_0, gamma)

    N       = 20; %the bigger N, the more policies we iterate through when trying to find the best policy
    M       = 20; %the bigger M, the better our estimate of v_theta for the given basis functions
    T       = 450;
    RF      = 5;  %the number of basis functions in the reward function
    VF      = 5;  %the number of basis functions in the value function approximator
    A       = [1,1; 2,2; 3,3; 4,4; 5,5];

    v_theta = zeros([VF N+1 T]);
    
    for n = 1:N 
        
        %s(1) = randomly selected state;

        for m = 1:M 

            for t = 1:T

                action_values = r_theta * adp_basii_reward(s(t)) + gamma * v_theta(:,n,t) * adp_basii_value(adp_transition_post_decision(s(t), A));

                [~, a] = max(action_values);
                s(t+1) = adp_transition_exogenous_info(adp_transition_post_decision(s(t), A(a,:)));

            end

            v = zeros(1,451);
            
            for t = T:-1:1
                v(t) = r_theta * adp_basii_reward(s(t)) + gamma * v(t+1);
            end
            
            if m == 1
                v_theta(:,n+1,:) = v_theta(:,n,:);
                B                = eye(VF) * .1; %see page 351 for why ".1" (aka, B0 = I * ["a small constant"])
            end
            
            t = 1;
            
            f                 = adp_basii_value(s);
            e                 = v_theta(:,n+1,t) * f(t) - v(t);
            g                 = 1 + f(t)'*B*f(t);
            H                 = 1/g * B;
            v_theta(:,n+1, t) = v_theta(:,n+1,t) - H * f(t) * e;
            B                 = B - 1/g * (B * (f(t) * f(t)') * B );
        end    
    end
   
    s = s_0;
    fe = zeros([RF 1]);
    for t = 1:T

        fe = fe + gamma^(t-1) * adp_basii_reward(s);
        
        action_values = r_theta * adp_basii_reward(s) + gamma * v_theta(:,n,t) * adp_basii_value(adp_transition_post_decision(s, A));

        [~, a] = max(action_values);
        s = adp_transition_exogenous_info(adp_transition_post_decision(s, A(a,:)));

    end
    
end