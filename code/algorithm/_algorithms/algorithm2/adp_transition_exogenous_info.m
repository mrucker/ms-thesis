function x2 = adp_transition_exogenous_info(x1)

    adp_assert_states(x1);
    
    x2 = x1;
            
    width  = x1(9);
    height = x1(10);
    radius = x1(11);
    
    x2 = create_new_targets(x2, width, height, radius);
end



function x2 = create_new_targets(x1, width, height, radius)
    
    %the actual web app uses an exponential interarrival time to have continous arrivals
    %for easier calculation in matlab I'm using repeated bernoulli trials since n is large and p is small
    %p = @(k,t) exp(-t/200) * ((t/200)^k)/factorial(k); p(2,33) -- https://planetcalc.com/7044/
    
    
    n = 33;     %could appear at any ms tick
    p = (1/200);%this is the poisson lambda???? Yes, I think so. That is, 1/200'th of a target arrives each milisecond
    
    targets_to_create = binornd(n,p);
        
    x2 = x1;
    
    for i = 1:targets_to_create
        
        x   = (width  - radius*2) * rand + radius;
        y   = (height - radius*2) * rand + radius;
        age = 10; %we make age 10 because 10+(33*30) = 1000
        
        x2 = [x2; x; y; age];
    end
    
end