function f = features(cursorData, targetData)

    %cursorData = [c1_x,c1_y;...;c4_x,c4_y]
    %targetData = [t1_x,t1_y,t1_age;...;tn_x,tn_y,tn_age]
    
    assert(mod(numel(cursorData),2) == 0, 'incorrect amount of cursor history passed in for feature calculation');
    assert(mod(numel(targetData),3) == 0, 'incorrect target data, expected: (x,y,age) for each target');    
    
    numLengths = numel(cursorData)/2;
    numTargets = numel(targetData)/3;
    
    cursorData = reshape(cursorData, [], numLengths);
    targetData = reshape(targetData, [], numTargets);

    targetRadius = 150;%this value comes from targets.js
    targetCount  = size(targetData,2);
    
    %[d1,d2,d3,d4,touched,age]
    f = zeros(numLengths+2,1);
    
    distances = sqrt(sqdist(cursorData, targetData(1:2,:)));
    f(1:numLengths) = sum(distances,2);
    f(numLengths+1) = sum(distances(1,:) < targetRadius);
    f(numLengths+2) = sum(targetData(3,:));       
    
    f = f/targetCount;
    
end