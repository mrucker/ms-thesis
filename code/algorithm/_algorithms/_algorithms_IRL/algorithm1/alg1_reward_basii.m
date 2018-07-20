function f = alg1_reward_basii(states, params)
    %Simply adding the function call increased runtime by 8 seconds

    A = [
      1  0 -1  0  0  0  0  0; %x(t-1)
      0  1  0 -1  0  0  0  0; %y(t-1)
      1  0 -2  0  1  0  0  0; %x(t-2)
      0  1  0 -2  0  1  0  0; %y(t-2)
      1  0 -3  0  3  0 -1  0; %x(t-3)
      0  1  0 -3  0  3  0 -1; %y(t-3)
    ];
    
    huge_states_assert(states);   

    %I'm going to assume all states have equal radius and targets
    %This assumption comes from simply knowing how my algorithm works
    targetRadius    = states(11,1);
    targetData      = reshape(states(12:end, 1), 3, []);
    targetLocations = targetData(1:2,:);
        
    %I'm also going to assume all states have equal derivatives
    %This assumption comes from simply knowing how my algorithm works

    cursorDerivatives = states(1:8,1);
    cursorCurrent     = states(1:2,:);
    cursorHistory     = reshape(A * cursorDerivatives, 2, []);
    cursorLocations   = [cursorCurrent, cursorHistory];

    x1 = cursorLocations;
    x2 = targetLocations;

    targetDistances = sqrt(dot(x1,x1,1)'+dot(x2,x2,1)-2*(x1'*x2));
    
    averageDistances  = mean(targetDistances,2);
    locationDistances = averageDistances(1:end-3)';
    historyDistances  = averageDistances(end-2:end);
    targetTouches     = mean(targetDistances(1:end-3,:) < targetRadius,2)';
    
        % Initialize variables.    
    F = [
      1  0  0  0  0; %distance
      1 -1  0  0  0; %velocity
      1 -2  1  0  0; %acceleration
      1 -3  3 -1  0; %jerk
      0  0  0  0  1; %touched
    ];

    maxD = params.maxdist; %makes sure all distances \in [0,1]
    maxT = 1;              %makes sure touches between [0,1]  (because we average 1 is the max)

    normalizer = diag(1./sum(F.*(F>0),2)) * F * diag([1/maxD,1/maxD,1/maxD,1/maxD,1/maxT]);    
    
    %[d1,d2,d3,d4,touched]
    f1 = vertcat(locationDistances, repmat(vertcat(historyDistances), 1, size(states,2)), targetTouches);
    f1 = normalizer * f1;
    
    %in the case that there are no targets set everything to 0
    f1(isnan(f1)) = 0;
    
    f = f1;
end