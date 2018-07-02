function v = adp_finite_basii(observations)

    %assumed observation = [c_x, c_y, t_r \forall targets {x, y, age}]
    assert(all(cellfun(@(o) isnumeric(o) && isrow(o), observations)), 'each observation must be a numeric row vector');
    assert(all(cellfun(@(o) mod(numel(o), 3) == 0   , observations)), 'each observation must have 2 cursor features and 5x target features');

    %basis = [x,y, dx,dy, ddx,ddy, dddx,dddy, touch]
    basii = [0,0, 0,0, 0,0, 0,0, 0];
    
    B = [ 
        1 0 1 0 1 0 1 0 0;
        0 1 0 1 0 1 0 1 0;
    ];

    A = -[
        0 0 1 0 1 0 1 0 0;
        0 0 0 1 0 1 0 1 0;
        0 0 0 0 1 0 1 0 0;
        0 0 0 0 0 1 0 1 0;
        0 0 0 0 0 0 1 0 0;
        0 0 0 0 0 0 0 1 0;
        0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0;
    ];
    
    %calculates all my cursor basis, now I need to calculate touch basis
    for i = 1:numel(observations)
        o = observations{i};
        
        c = o(1:2);
        r = o(3);
        t = o(4:end);
        
        t = reshape(t, [], numel(t)/3);
                        
        basii(end+1,:) = basii(end, :) * A + c * B;
        basii(end  ,9) = sum(sqrt(dot(x2,x2,1)+dot(x1,x1,1)'-2*(x1'*x2)) <= r);
    end
    
    b = basii;
    
end