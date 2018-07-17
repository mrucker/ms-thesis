function [B, theta] = linear_regression_recursive(B, theta, x, y)
        
    if ~any(theta)
        %see page 351 in ADP for why ".1" (aka, B0 = I * ["a small constant"])
        %this never seemed to give me good approximations no matter how many observations I fed in 
        %B = [eye(size(x,1)) * .01;
        
        B = [B;x,y];

        if size(B,1) >= size(B,2)-1
            X = B(:,1:end-1);
            Y = B(:,end);
            
            if isInvertible(X'*X)
                %the first time we do a batch update
                %after this we only do recursive updates
                B     = (X'*X)^(-1);
                theta = B * X' * Y;
            end
        end
        
        return;
    end

    assert(iscolumn(theta) && isnumeric(theta), 'theta must be a numeric column vector')
    assert(isrow(x)        && isnumeric(x)    , 'x must be a numeric row vector')
    assert(isscalar(y)     && isnumeric(y)    , 'y must be a numeric scalar')
    assert(size(theta,1) == size(x,2)         , 'theta and x must be equal dimension');

    x = x'; %all the equations below assumes x and y are column vectors;

    l     = 1;
    e     = theta' * x - y;
    g     = l + x'*B*x;
    H     = 1/g * B;
    
    %update steps
    theta = theta - H * x * e;
    B     = (1/l)*(B - 1/g * (B * (x * x') * B));

end

function i = isInvertible(X)
    i = rcond(X) > .000001;
end