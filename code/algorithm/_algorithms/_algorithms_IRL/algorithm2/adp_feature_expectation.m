function fe = adp_feature_expectation(r_theta, T, s_0, gamma)

    N  = 10; %the bigger N, the more policies we iterate through when trying to find the best policy
    M  = 10; %the bigger M, the better our estimate of v_theta for the given basis functions
    RF = size(r_theta,1);  %the number of basis functions in the reward function
    VF = size(r_theta,1);  %the number of basis functions in the value function approximator
    A  = createActionMatrix();
    B  = cell(1,T);

    v_theta = mat2cell(zeros([VF*T N]), ones(1,T)*VF, ones(1,N));
    
    for n = 1:N 
        s_start = s_0; %I should eventually make this random
        
        for m = 1:M 

            S = cell(1, T);
            S{1} = s_start;
            
            for t = 1:T
                action_values = r_theta' * adp_basii_reward(S{t}) + gamma * v_theta{t,n}' * adp_basii_value(adp_transition_post_decision(S{t}, A));

                [~, a] = max(action_values);

                if(t ~= T)
                    S{t+1} = adp_transition_exogenous_info(adp_transition_post_decision(S{t}, A(:,a)));
                end
            end

            V = zeros(1,T+1);
            
            for t = T:-1:1
                V(t) = r_theta' * adp_basii_reward(S{t}) + gamma * V(t+1);
            end            
            
            if m == 1
                % this is right, I think the idea is that 
                % since policy iteration only changes the policy a little
                % we should start from our previous observations and update from there
                % furthermore, if this is the approach we are taking then we shouldn't erase B
                v_theta(:,n+1) = v_theta(:,n);                
            end
            
            X = adp_basii_value(S)';
            Y = V;
            
            for t = 1:T
                [B{t},v_theta{t,n+1}] = recursive_linear_regression(B{t}, v_theta{t,n+1}, X(t,:), Y(t));
            end
            
        end    
    end
   
    s = s_0;
    fe = zeros([RF 1]);
    for t = 1:T

        fe = fe + gamma^(t-1) * adp_basii_reward(s);
        
        action_values = r_theta' * adp_basii_reward(s) + gamma * v_theta{t,n+1}' * adp_basii_value(adp_transition_post_decision(s, A));

        [~, a] = max(action_values);
        s = adp_transition_exogenous_info(adp_transition_post_decision(s, A(:,a)));

    end
    
end

function a = createActionMatrix()
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