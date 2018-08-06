function [ss] = W_estimation_bias(T, P, W)

    chain_T = cell2mat(arrayfun(@(s_i)T{P(s_i)}(s_i,:), 1:size(P,1), 'UniformOutput', false)');
    
    % a really quick and dirty approximation
    % we first normalize to remove bad approximations of T
    % then we look 100 steps into the future to find the staedy state
    chain_T = chain_T ./ sum(chain_T,2);
    
    ss = 0;
    
    for w = 1:W        
        ss = ss + 1/size(P,1) * full(sum(chain_T^(w-1)));
    end
    
    ss = ss';
end