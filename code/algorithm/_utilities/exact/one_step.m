function P = one_step(states, state2index, actions, ticks, time_on_screen, expected_interarrival)
    P = cell(1,size(actions,2));

    for a_i = 1:size(actions,2)
        P{a_i} = sparse(size(states,2), size(states,2));
    end

    max_targs = size(states(:,1),1) - 11;

    add_sub_sty_pmf = my_add_sub_sty_pmf(ticks, max_targs, time_on_screen, expected_interarrival);

    for a_i = 1:size(actions,2)
        for s_i = 1:size(states,2)

            a = actions(:,a_i);
            s = states (:,s_i);

            %first update state, this is deterministic so we can calculate simply
            s(3:8) = s(1:6);
            s(1:2) = a;

            P{a_i}(s_i,:) = my_sub_add(P{a_i}(s_i,:), s, add_sub_sty_pmf, state2index);
        end
    end
end

function P = my_sub_add(P, s, add_sub_sty_pmf, state2index)

    x = s(12:end);
    a = dec2bin((1:2^numel(x))-1)' - '0';

    add_k = sum(a-x == +1);
    sub_k = sum(a-x == -1);
    sty_k = sum(a+x == +2);

    states   = vertcat(repmat(s(1:11), [1 size(a,2)]), a);
    states_i = state2index(states);

    states_p = arrayfun(@(s_i) factorial(add_k(s_i)) * add_sub_sty_pmf(add_k(s_i), sub_k(s_i), sty_k(s_i)), 1:size(a,2));

    if all(x == 1)
        add_k = add_k + 1;
        states_p = states_p + arrayfun(@(s_i) factorial(add_k(s_i)) * add_sub_sty_pmf(add_k(s_i), sub_k(s_i), sty_k(s_i)), 1:size(a,2));        
    end
    
    states_i = states_i(states_p > 0);
    states_p = states_p(states_p > 0); %I just hope this keeps them in order
    
    P(states_i) = P(states_i) + states_p;
end

function pmf = my_add_sub_sty_pmf(ticks, max_targs, time_on_screen, expected_interarrival)
    
    %adds  \in [0, max_adds]
    %subs  \in [0, max_subs]
    
    %puts  \in [0, max_adds]
    %stays \in [0, max_subs]
    
    add_n = ticks;
    add_k = 0:add_n;

    add_prob = 1/expected_interarrival;

    sub_prob = 1/time_on_screen;
    sty_prob = 1 - sub_prob;

    %This is the probability of k being added in n ticks at k specific locations.

    add_k_prob = my_nchoosek(add_n, add_k) .* add_prob.^add_k .* (1-add_prob).^(add_n-add_k);
    add_k_prob = [add_k_prob, zeros(1,50)]; %we add a bunch of zeros in case somebody tries to add more than is possible   
    
    %intentionally changed my put distribution so that it no longer
    %considers with replacement. This makes calculations much faster and
    %simpler since I don't have to enumerate combinations.
    %for historical purposes the old pmf was (1/max_targs).^(add_k);
    put_k_prob = tril(ones(ticks+10, max_targs+1));
    for adds = 0:(ticks+9)
        for open  = 0:max_targs
            if(open >= adds)
                put_k_prob(adds+1,open+1) = factorial(open-adds)/factorial(open);
            end
        end
    end
    
    %Two outcomes can happen to a target in a step, it either goes away or
    %stays. Therefore these add up to one. However, because targets operate
    %independently at each tick and once they are gone they stay gone, we
    %don't need nchoosek. We just need the partial geometric series for all
    %sequences that end in a subtraction event. We can then raise this to a
    %power since each target's probability is independent of all others.
    sub_ticks_prob = sub_prob * (1-sty_prob^ticks)/(1-sty_prob);
    sty_ticks_prob = sty_prob^ticks;

    pmf = @(add_k,sub_k,sty_k) add_k_prob(add_k+1) * put_k_prob(add_k + 1, max_targs - (sub_k + sty_k) + 1) * sub_ticks_prob^(sub_k) * sty_ticks_prob^(sty_k);
end

function v = my_nchoosek(n,k)
    v = factorial(n)./(factorial(n-k) .* factorial(k));
end

function add_pmf = my_add_pmf(ticks, expected_interarrival)
    add_cnt          = 0:ticks;
    add_combinations = my_nchoosek(ticks, add_cnt);
    add_probability  = (1/expected_interarrival).^add_cnt .* (1-(1/expected_interarrival)).^(ticks-add_cnt);
    add_pmf          = add_combinations .* add_probability;
    
    %useful, so I'll keep them, but ultimately not needed
    %add_cdf          = add_pmf * triu(ones(chances+1));
    %adds = 1-find(rand < add_cdf,1);
end

%First, we'll calculate the probabilities that any existing
%target disappear. To approximate this without age, we'll say a
%target has a 1/1000 chance of disappearing at any given tick
%and between each time step 33 ticks occur. So in each step a
%target has r = (999/1000)^33 chance of remaining giving 1-r.
function sub_pmf = my_sub_pmf(ticks, max_targs, time_on_screen)
    keep_prob = (1 - 1/time_on_screen)^ticks;
    take_prob = (1 - keep_prob);

    sub_pmf = zeros(max_targs+1);
    
    for targs = 0:max_targs
        sub                = 0:targs;
        sub_combinations   = my_nchoosek(targs, sub);
        sub_probability    = take_prob.^sub .* keep_prob.^(targs-sub);
        sub_pmf(targs+1,:) = [sub_combinations .* sub_probability, zeros(1,max_targs-targs)];
    end
end