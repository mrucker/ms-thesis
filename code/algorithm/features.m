function f = features(locationData, historyData, targetData, params)
global d;
    %cursorData = [c1_x,c1_y;...;c4_x,c4_y]
    %targetData = [t1_x,t1_y,t1_age;...;tn_x,tn_y,tn_age]
    
    assert(mod(numel(locationData) ,2) == 0, 'at least one cursor location has only a single x or y');
    assert(mod(numel(historyData)  ,6) == 0, 'incorrect amount of cursor history passed in for feature calculation');
    assert(mod(numel(targetData)   ,3) == 0, 'incorrect target data, expected: (x,y,age) for each target');    
    
    locationCount = numel(locationData)/2;
    targetCount   = numel(targetData)/3;
    
    locationData = reshape(locationData, [], locationCount);
    historyData  = reshape(historyData , [], 3);
    targetData   = reshape(targetData  , [], targetCount);

    targetRadius = 150;%this value comes from targets.js

    x1 = [locationData,historyData];
    x2 = targetData(1:2,:);
    
    targetDistances   = sqrt(dot(x2,x2,1)+dot(x1,x1,1)'-2*(x1'*x2));    
    averageDistances  = mean(targetDistances,2);
    locationDistances = averageDistances(1:end-3)';
    historyDistances  = averageDistances(end-2:end);
    %targetAges        = mean(targetData(3,:));
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
    maxA = params.maxage;  %makes sure age is between [0,1]   (because we average 1000 is the max)

    normalizer = diag(1./sum(F.*(F>0),2)) * F * diag([1/maxD,1/maxD,1/maxD,1/maxD,1/maxT]);
    %normalizer = diag([1/maxD,1/maxD,1/maxD,1/maxD,1/maxA,1/maxT]);

    %normalizer = round(normalizer,4);
    
    %[d1,d2,d3,d4,age,touched]
    %f1 = vertcat(locationDistances, repmat(vertcat(historyDistances,targetAges),1,locationCount), targetTouches);
    
    %[d1,d2,d3,d4,touched]
    f1 = vertcat(locationDistances, repmat(vertcat(historyDistances),1,locationCount), targetTouches);
    f1 = normalizer * f1;    
    %f2 = power(f1,3);
    
    f = f1;
end