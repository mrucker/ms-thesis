function f = features(cursorData, targetData)

    %cursorData = [c1_x,c1_y;...;c4_x,c4_y]
    %targetData = [t1_x,t1_y,t1_age;...;tn_x,tn_y,tn_age]
    
    assert(numel(cursorData)        == 8, 'incorrect amount of cursor history passed in for feature calculation');
    assert(mod(numel(targetData),3) == 0, 'incorrect target data, expected: (x,y,age) for each target');
    
    cursorData = reshape(cursorData, [], numel(cursorData)/2);
    targetData = reshape(targetData, [], numel(targetData)/3);

    targetRadius = 150;%this value comes from targets.js
    targetCount  = size(targetData,2);
    
    %[d1,d2,d3,d4,touched,age]
    f = [0,0,0,0,0,0]';
    
    distances = sqrt(sqdist(cursorData, targetData(1:2,:)));
    f(1:4)    = sum(distances,2);
    f(5)      = sum(distances(1,:) < targetRadius);
    f(6)      = sum(targetData(3,:));       
    f         = f/targetCount;
    
end