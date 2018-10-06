function phi = huge_basis_2(state, ~, dic_data, para); persistent v_i v_p v_l a_m; 

    if(isempty(a_m))
        s_a = s_act_4_2();
        a_m = s_a([]);
    end

    if(isempty(v_p))
        [v_i, v_p, ~, v_l] = v_basii_4_9();
        v_p = v_p();
        
        %RBF Transformation
        %features are no longer linear, but no interaction effects
        v_p2 = v_p;
            LEVELS_N = [3 3 3 3 3 3 1 1 1 6];
            LEVELS_S = [1/2 1/2 1/2 1/2 1/2 1/2 .001 .001 .001 2/5];

            v_p2 = cell2mat(arrayfun(@(r) repmat(v_p2(r,:),LEVELS_N(r),1), 1:numel(LEVELS_N), 'UniformOutput',false)');        
            v_s  = cell2mat(arrayfun(@(r) LEVELS_S(r)*ones(LEVELS_N(r),1), 1:numel(LEVELS_N), 'UniformOutput',false)');
            v_c  = [0/2 1/2 2/2 0/2 1/2 2/2 0/2 1/2 2/2 0/2 1/2 2/2 0/2 1/2 2/2 0/2 1/2 2/2 1/1 1/1 1/1 0/5 1/5 2/5 3/5 4/5 5/5]';

            v_p2 = v_p2 - v_c;
            v_p2 = power(v_p2,2);
            v_p2 = v_p2 ./(2*power(v_s,2));
            v_p2 = exp(-v_p2);
        v_p = v_p2;
    end
    
    if(nargin == 0)
        phi = size(v_p,1);
    end        
    
    if(nargin == 1 && isempty(state))
        phi = v_p;%this is here for my own policy_function
    end

    if(nargin == 1 && ~isempty(state))
        phi = v_i(v_l(state));%this is here for my own policy_function
    end

    if(nargin==2)
        phi = v_p(:,v_i(v_l(state)));
    end
    
    if(nargin > 2)
        %(state, action, dic_data, para)
    end
end