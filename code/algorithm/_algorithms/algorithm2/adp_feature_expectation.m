function fe = adp_feature_expectation(r_theta, T, s_0, gamma)

    N       = 10; %the bigger N, the more policies we iterate through when trying to find the best policy
    M       = 10; %the bigger M, the better our estimate of v_theta for the given basis functions
    RF      = size(r_theta,1);  %the number of basis functions in the reward function
    VF      = size(r_theta,1);  %the number of basis functions in the value function approximator
    A       = createActionsMatrix();

    v_theta = zeros([VF T N+1]);
    
    for n = 1:N 
        s_start = s_0; %I should eventually make this random
        
        for m = 1:M 

            s = cell(1, T);
            s{1} = s_start; 
            
            
            for t = 1:T
                action_values = r_theta' * adp_basii_reward(s{t}) + gamma * v_theta(:,t,n)' * adp_basii_value(adp_transition_post_decision(s{t}, A));

                [~, a] = max(action_values);

                s{t+1} = adp_transition_exogenous_info(adp_transition_post_decision(s{t}, A(:,a)));
            end

            v = zeros(1,T+1);
            
            for t = T:-1:1
                v(t) = r_theta' * adp_basii_reward(s{t}) + gamma * v(t+1);
            end            
            
            if m == 1
                v_theta(:,:,n+1) = v_theta(:,:,n);
                
                %see page 351 for why ".1" (aka, B0 = I * ["a small constant"])
                B                = repmat(eye(VF) * .1, [1 1 T]); 
            end

            
            f = adp_basii_value(s);
            e = dot(v_theta(:,1:T,n+1),f(:,1:T)) - v(1:T);
            
            for t = 1:T
                g                = 1 + f(:,t)'*B(:,:,t)*f(:,t);
                H                = 1/g * B(:,:,t);
                v_theta(:,t,n+1) = v_theta(:,t,n+1) - H * f(:,t) * e(t);
                B(:,:,t)         = B(:,:,t) - 1/g * (B(:,:,t) * (f(:,t) * f(:,t)') * B(:,:,t));
            end
            
        end    
    end
   
    s = s_0;
    fe = zeros([RF 1]);
    for t = 1:T

        fe = fe + gamma^(t-1) * adp_basii_reward(s);
        
        action_values = r_theta' * adp_basii_reward(s) + gamma * v_theta(:,t,n+1)' * adp_basii_value(adp_transition_post_decision(s, A));

        [~, a] = max(action_values);
        s = adp_transition_exogenous_info(adp_transition_post_decision(s, A(:,a)));

    end
    
end

function a = createActionsMatrix()
    % The actions matrix should be 2 x |number of actions| where the first row is dx and the second row is dy.
    % This means each column in the matrix represents a dx/dy pair that is the action taken.

    %all combinations of (dx,dy) for dx,dy \in [-10,10]
    
    dx = [100,50,10,2,0];
    dy = [100,50,10,2,0];
    
    dx = horzcat(dx,0,-dx);
    dy = horzcat(dy,0,-dy);
        
    %dx = 1:2;
    %dy = [1,1];
    
    a = vertcat(reshape(repmat(dx,numel(dx),1), [1,numel(dx)^2]), reshape(repmat(dy',1,numel(dy)), [1,numel(dy)^2]));
end