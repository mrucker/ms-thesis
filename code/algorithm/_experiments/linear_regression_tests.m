o_cnt = 20000;
p_cnt = 100; %plotting only works for 1 & 2

X = rand([o_cnt p_cnt]) * 10;
T = rand([p_cnt 1]) * 10;

Y = X * T + 5 + 6*randn(o_cnt, 1);

%batch regression method
tic
t_b = linear_regression_batch(X,Y);
toc

B   = [];
t_r = [];
%recursive regression method
tic
for i = 1:o_cnt
    [B, t_r] = linear_regression_recursive(B, t_r, X(i,:), Y(i));
end
toc

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


%[T, t_b, t_r]