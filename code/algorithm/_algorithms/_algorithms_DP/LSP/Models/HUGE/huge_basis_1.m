function phi = huge_basis_1(state, ~, dic_data, para); persistent v_i v_p v_l a_m; 

    if(isempty(a_m))
        s_a = s_act_4_2();
        a_m = s_a([]);
    end

    if(isempty(v_p))
        [v_i, v_p, ~, v_l] = v_basii_4_9();
        v_p = v_p();               
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