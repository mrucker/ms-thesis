function K = my_kernel(U,V)
    K = double(all(U == V,2));
end