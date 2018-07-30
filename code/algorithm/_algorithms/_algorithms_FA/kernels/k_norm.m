function k = k_norm()
    k = @(x1,x2) (sqrt(dot(x1,x1,1)'+dot(x2,x2,1)-2*(x1'*x2))).^(1/2);
end