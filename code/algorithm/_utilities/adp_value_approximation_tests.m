addpath('../_utilities/');

n = 5;
g = .9;
N = 10;
M = 50;
T = 50;

state_matrix  = vertcat(reshape(repmat(1:n,n,1), [1,n^2]), reshape(repmat((1:n)',1,n), [1,n^2]));
basii_matrix  = exp(-sqrt(dot(state_matrix,state_matrix,1)+dot(state_matrix,state_matrix,1)'-2*(state_matrix'*state_matrix)));
reward_matrix = rand([n n])*100;
action_matrix = [1 0; 0 1; -1 0; 0 -1]';


rewards = @(s) reward_matrix(s(2), s(1));
actions = @(s) action_matrix(:, all((s + action_matrix) < (n + 1) .* (s + action_matrix > 0)));

s_1 = @() round(rand([2,1]) * (n-1)) + 1;

transition_post = @(s,a) s+a;
transition_pre  = @(s,a) s+a;

value_basii = @(s) basii_matrix(:, [5;1]' *(s +[-1;0]));

v_theta = adp_value_approximation(s_1, actions, rewards, value_basii, transition_post, transition_pre, g, N, M, T);

approx_value = v_theta' * value_basii(state_matrix);
actual_value = mar_value_iteration(transition_matrix(state_matrix, action_matrix), repmat(reshape(reward_matrix, 25, 1), [1 4]), g);

[approx_value', actual_value]

function trans_matrix = transition_matrix(state_matrix, action_matrix)
    n = sqrt(size(state_matrix, 2));
    trans_matrix  = zeros(n^2, n^2, size(action_matrix,2));
    
    
    for s_i = 1:size(state_matrix,2)
        for a_i = 1:size(action_matrix,2)

            s = state_matrix (:, s_i);
            a = action_matrix(:, a_i);

            trans_s = s+a;

            if all(trans_s < (n + 1) .* (trans_s > 0))
                trans_matrix(s_i, sub2ind([n,n], trans_s(1), trans_s(2)), a_i) = 1;
            end
        end
    end
end

function [V, policy, iter, cpu_time] = mar_value_iteration(P, R, discount, epsilon, max_iter, V0)

    iter = 0;

    S_N = size(R,1);
    A_N = size(R,2);

    Q = zeros(S_N, A_N);

    if(nargin < 4)
        epsilon = .01;
    end

    if(nargin < 5)
        max_iter = 1000;
    end

    if(nargin < 6)
        V = zeros(S_N, 001);
    else
        V = V0;
    end

%     if nargin < 5
%         if discount ~= 1
%             max_iter = mdp_value_iteration_bound_iter(P, R, discount, epsilon, V);            
%         else
%             max_iter = 1000;
%         end;
%     end

    if discount ~= 1
        epsilon = epsilon * (1-discount)/discount; %[(Powell 64) I have no idea why they apply this transformation]
    end;

    done = false;

    while ~done

        v    = V;
        iter = iter + 1;

        for a_i = 1:A_N
            Q(:, a_i) = R(:,a_i) + P(:,:,a_i)*discount*V;
            V = max(V, Q(:,a_i)); %I think adding this line makes this closer to the Gauss-Seidel variation (Powell 64)
        end

        [V, policy] = max(Q, [], 2);

        d = abs(V-v);
        %max(d)          < epsilon [Checking for convergence. We should only converge on V*.]
        %max(d) - min(d) < epsilon [(Powell 65) The idea is that this gives us an optimal policy though maybe not V*]

        done = max(d) - min(d) < epsilon;
        done = done || iter == max_iter;
    end

    cpu_time = 0;
end

