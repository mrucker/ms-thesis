o_cnt = 1000;
p_cnt = 4; %plotting only works for 1 & 2

X = rand([o_cnt p_cnt]) * 10;
T = rand([p_cnt 1]) * 10;
Y = X * T + 5 + 6*randn(o_cnt, 1);

%batch regression method
t_b = (X'*X)^(-1) * X' * Y;

t_r = [];
B   = [];
%recursive regression method
for i = 1:o_cnt
    [B, t_r] = recursive_linear_regression(B, t_r, X(i,:), Y(i));
end

if p_cnt == 1
    t_x = 0:.1:10; 
    plot(X,Y, 'o', t_x,t_x*t_b, ':', t_x,t_x*t_r, '--');
    legend('data','batch fit','recursive fit');
elseif p_cnt == 2
    t_x = 0:.1:10;
    t_x = vertcat(reshape(repmat(t_x,numel(t_x),1), [1,numel(t_x)^2]), reshape(repmat(t_x',1,numel(t_x)), [1,numel(t_x)^2]))';
    plot3(X(:,1),X(:,2),Y, 'o', t_x(:,1),t_x(:,2),t_x*t_b, ':', t_x(:,1),t_x(:,2),t_x*t_r, '--');
    legend('data','batch fit','recursive fit');    
end

[T, t_b, t_r]