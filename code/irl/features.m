function f = features(locationData, historyData, targetData)

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
    averageDistances  = sum(targetDistances,2)/targetCount;    
    locationDistances = averageDistances(1:end-3)';
    historyDistances  = averageDistances(end-2:end);
    targetTouches     = sum(targetDistances(1:end-3,:) < targetRadius,2)'/targetCount;
    targetAges        = sum(targetData(3,:))/targetCount;
    
    %[d1,d2,d3,d4,age,touched]
    f = vertcat(locationDistances, repmat(vertcat(historyDistances,targetAges),1,locationCount), targetTouches); 
end