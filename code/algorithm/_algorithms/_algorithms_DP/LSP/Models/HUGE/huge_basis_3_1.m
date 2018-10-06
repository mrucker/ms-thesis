function phi = huge_basis_3_1(state, actions, dic_data, para); persistent v_i v_p v_l a_m; 

    if(isempty(a_m))
        s_a = s_act_4_2();
        a_m = s_a([]);
    end

    if(isempty(v_p))
        [v_i, v_p, ~, v_l] = v_basii_4_9();
        v_p = v_p();


        %full second order polynomial
        v_p2 = v_p;
            for i = 1:size(v_p,1)
                for j = i:size(v_p,1)
                    for k = j:size(v_p,1)
                        v_p2 = vertcat(v_p2, v_p2(i,:).*v_p2(j,:).*v_p2(k,:));
                    end
                end
            end
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