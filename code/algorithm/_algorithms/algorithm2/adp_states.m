function s = adp_states(observations)    

    %assumed observation = [c_x, c_y, t_r \forall targets {x, y, age}]
    assert(all(cellfun(@(o) isnumeric(o) && isrow(o), observations)), 'each observation must be a numeric row vector');
    assert(all(cellfun(@(o) mod(numel(o), 3) == 0   , observations)), 'each observation must have 2 cursor features and 5x target features');

    %states = [x,y, dx,dy, ddx,ddy, dddx,dddy, radius, targets*3]
    states    = cell(1, numel(observations)+1);
    states{1} = [0,0,0,0,0,0,0,0,0];

    %calculates all my cursor basis, now I need to calculate touch basis
    for i = 1:numel(observations)
        o = observations{i};
        s = states{i};

        x = s(1:8);
        u = o(1:2);
        r = o(3);
        t = o(4:end);
        
        states{i+1} = [adp_transition(x,u,false), r, t];
    end

    s = states;
end