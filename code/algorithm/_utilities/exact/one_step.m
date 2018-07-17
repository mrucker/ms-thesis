function P = one_step(states, state2index, actions, time_on_screen, expected_interarrival)
    P = cell(1,size(actions,2));

    for a_i = 1:size(actions,2)
        P{a_i} = sparse(size(states,2), size(states,2));
    end
    
    ticks = 33;
    max_targs = size(states(:,1),1) - 11;

    tst_pmf = my_pmf(ticks, max_targs, time_on_screen, expected_interarrival);
    t = my_pmf(1, 4, 2, 2);
    sub_pmf = my_sub_pmf(ticks, max_targs, time_on_screen);
    add_pmf = my_add_pmf(ticks, expected_interarrival);
    %sub_add = vertcat(reshape(repmat([0 1 2 3], [4, 1]), [1, 16]), repmat([0 1 2 3], [1 4]));
    
    %I need a way to turn a state into its index
    for a_i = 1:size(actions,2)
        for s_i = 1:size(states,2)

            a = actions(:,a_i);
            s = states (:,s_i);

            %first update state, this is deterministic so we can calculate simply
            s(3:8) = s(1:6);
            s(1:2) = a;

            P{a_i}(s_i,:) = my_sub_add(P{a_i}(s_i,:), s, sub_pmf, add_pmf, state2index);
        end
    end
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

function P = my_sub_add(P, s, sub_pmf, add_pmf, state2index)

    sub_pmf = sub_pmf(sum(s(12:end)) + 1, :);

    x = s(12:end);
    a = dec2bin((1:2^numel(x))-1)' - '0';

    sub_counts     = sum(a-x == -1);
    add_counts     = sum(a-x == +1);
    sub_add_counts = sum(a+x == +2);
    
    %sub_prob = 1 - (999/1000)^33;
    %add_prob = 
    
    sub_spot_count = sum(x == 1);
    add_spot_count = sum(x == 0);

    sub_normalizer = 1./[1, my_nchoosek(sub_spot_count,1:sub_spot_count)];
    add_normalizer = 1./[1, my_nchoosek(add_spot_count,1:add_spot_count)];

    states   = vertcat(repmat(s(1:11), [1 2^numel(x)]), a);
    states_i = state2index(states);
        
    %keep_prob = (1 - 1/1000)^33;
    %take_prob = 1/1000 * ((1-(1-1/1000)^33)/(1-(1-1/1000)));
    
    states_p = floor(sub_pmf(sub_counts+1) .* sub_normalizer(sub_counts+1) .* add_pmf(add_counts+1) .* add_normalizer(add_counts+1) * 10000) / 10000;
    %states_p = floor( add_pmf(add_counts+1) .* (1/6) .^ add_counts .* * 10000) / 10000

    states_i = states_i(states_p > 0);
    states_p = states_p(states_p > 0); %I just hope this keeps them in order
    
    P(states_i) = P(states_i) + states_p;
end

function pmf = my_pmf(ticks, max_targs, time_on_screen, expected_interarrival)
    
    %adds  \in [0, max_adds]
    %subs  \in [0, max_subs]
    
    %puts  \in [0, max_adds]
    %stays \in [0, max_subs]

    max_adds = ticks;
    max_subs = max_targs;
    
    add_cnt = 0:max_adds;
    sub_cnt = 0:max_subs;
    
    add_prob = 1/expected_interarrival;
    sub_prob = 1/time_on_screen;
    sty_prob = 1 - sub_prob;
    put_prob = 1/max_targs;

    add_pmf = my_nchoosek(max_adds, add_cnt) .* add_prob.^add_cnt .* (1-add_prob).^(max_adds-add_cnt);
    sub_pmf = ((1-sty_prob^ticks)/(1-sty_prob) * sub_prob).^(sub_cnt);
    put_pmf = put_prob.^(add_cnt); %this could be improved to take into consideration add > put (that is we place on top of ourselves)
    sty_pmf = sty_prob.^(ticks*sub_cnt);

    pmf = @(adds,subs,stays) add_pmf(adds+1) * put_pmf(adds+1) * sub_pmf(subs+1) * sty_pmf(stays+1);
end