function [theta] = linear_regression_batch(X, Y)

    assert(size(X,1) == size(Y,1), 'there must be one and only one outcome for each observation');
    assert(isInvertible(X'*X)    , 'not enough observations to create a single solution');

    theta = (X'*X)^(-1) * X' * Y;
end

function i = isInvertible(X)
    i = rcond(X) > .000001;
end