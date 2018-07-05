function x2 = adp_transition_exogenous_info(x1)

    %I should have x1 contain width, height and radius
    
    width  = x1(9);
    height = x1(10);
    radius = x1(11);

    %assumes that 33 ms will pass in transition (aka, 30 observations per second)    
    %assumed state = [x, y, dx, dy, ddx, ddy, dddx, dddy, w, h, r, \forall targets {x, y, age}]
    
    isRightDataTypes = isnumeric(x1) && isrow(x1);
    isRightDimension = numel(x1) == 11 || (numel(x1) > 11 && mod(numel(x1)-11, 3) == 0);
    
    assert(isRightDataTypes, 'each state must be a numeric row vector');
    assert(isRightDimension, 'each state must have 8 cursor features + [1 radius feature + 3x target features]');

    x2 = x1;
    
    x2 = create_new_targets(x2, width, height, radius);
end



function x2 = create_new_targets(x1, width, height, radius)
    
    %the actual web app uses an exponential interarrival time to have continous arrivals
    %for easier calculation in matlab I'm using repeated bernoulli trials since n is large and p is small
    %p = @(k,t) exp(-t/200) * ((t/200)^k)/factorial(k); p(2,33) -- https://planetcalc.com/7044/
    
    
    n = 33;%could appear at any ms tick
    p = (1/200);%this is the poisson lambda???? Yes, I think so. That is, 1/200'th of a target arrives each milisecond
    
    targets_to_create = binornd(n,p);
        
    x2 = x1;
    
    for i = 1:targets_to_create
        
        x   = (width  - radius*2) * rand + radius;
        y   = (height - radius*2) * rand + radius;
        age = 10; %we make age 10 because 10+(33*30) = 1000
        
        x2 = [x2, x, y, age];
    end
    
end