function b = adp_basii_value(states)

    %assumed state = [x, y, dx, dy, ddx,ddy, dddx,dddy, r, \forall targets {x, y, age}]
    assert(all(cellfun(@(o) isnumeric(o) && isrow(o), states)), 'each state must be a numeric row vector');
    assert(all(cellfun(@(o) mod(numel(o), 3) == 0   , states)), 'each state must have 8 cursor features + 1 radius feature + 3x target features');

    %basis = [x,y, dx,dy, ddx,ddy, dddx,dddy, touch]
    b = zeros(numel(states), 9);

    for i = 1:numel(states)
        s = states{i};

        r = s(9);
        t = s(10:end);        
        t = reshape(t, [], numel(t)/3);

        x1 = s(1:2)';
        x2 = t(1:2,:);

        touch_count = sum(sqrt(dot(x2,x2,1)+dot(x1,x1,1)'-2*(x1'*x2)) <= r);

        % distance from center,
        % distance from three nearest targets,
        % direction changes required for optimal 3 target path
        b(i,:) = [s(1:8), touch_count];
    end
end