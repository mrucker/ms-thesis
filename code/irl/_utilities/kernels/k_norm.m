function k = k_norm()
    k = @(x1,x2) (sqdist(x1,x2)).^(1/2);
end