function phi = pendulum_kernel_rbf(state, action, dic_data, para)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright 2005-2007 
%
% Xin Xu (xuxin_mail@263.net)
% Michail G. Lagoudakis (mgl@cs.duke.edu)
% Ronald Parr (parr@cs.duke.edu)
%
% Department of Computer Science
% Box 90129
% Duke University, NC 27708
% 
%
% phi = pendulum_kernel_rbf(state, action)
%
% Computes a number of radial basis functions (on "state") with means
% spread uniformly over the chain. This block of basis functions is
% duplicated for each action. The "action" determines which segment
% will be active.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % numbasis = (nrbfx*nrbfy+1) * pend_actions ;

    pend_actions = 3;
    mypi  =  acos(-1);

    if  nargin<2
        phi =  2*3; 
        return; 
    end

    if nargin == 2
        feature_dim=2*3; 
        state_feature=zeros(feature_dim,1);

        state_feature((action-1)*2+1,1)=state(1);  % others to be zeros
        state_feature((action-1)*2+2,1)=state(2);  % others to be zeros

        phi = state_feature;
        return;
    end

    kernel_dim=size(dic_data,1);
    %%% Initialize the kernel vector
    phi = zeros(kernel_dim,1);

    if  abs(state(1)) > (mypi/2.0) 
        return;
    end

    width = para;

    %%% Compute the state feature of state-action pairs
    feature_dim=2*3; 
    state_feature=zeros(feature_dim,1);

    state_feature((action-1)*2+1,1)=state(1);  % others to be zeros
    state_feature((action-1)*2+2,1)=state(2);  % others to be zeros

    %%% Compute the RBFs
    for i=1:kernel_dim
        phi(i,1) = exp(-norm(state_feature-transpose(dic_data(i,:)))^2/width^2);
    end
return
  
