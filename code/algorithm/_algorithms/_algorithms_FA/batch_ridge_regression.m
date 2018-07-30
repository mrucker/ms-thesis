function [f] = batch_ridge_regression(x, y, lambda , K)
    y_k_l_i = y' * (K(x',x') + eye(size(x,1))*lambda)^-1;
    
    f = @(xi) K(x',xi')' * y_k_l_i' ;
end