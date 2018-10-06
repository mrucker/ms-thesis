function chainplotval(policy, old_policy, idx)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright 2000-2002 
%
% Michail G. Lagoudakis (mgl@cs.duke.edu)
% Ronald Parr (parr@cs.duke.edu)
%
% Department of Computer Science
% Box 90129
% Duke University, NC 27708
% 
%
% function chainplotval(policy, old_policy, idx)
%
% Display some useful information. Compares the learned evaluation
% ("policy") of "old_policy" with the exact evaluation of
% "old_policy". idx is the number of the current iteration. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  S = chainstates;
  rows=5;
  cols=2;
  
  if (idx > rows*cols)
    disp(['Cannot display more than ' num2str(rows*cols) ' iterations']);
    return
  end
  
  
  [V V1 V2 VVV] = chainsolve(old_policy);

  Q1 =zeros(S,1);
  Q2 =zeros(S,1);

  for s=1:S
    
    ppp(s) = policy_function(policy, s);
    Q1(s) = Qvalue(s, 1, policy);
    Q2(s) = Qvalue(s, 2, policy);
    
    if (V2(s) > V1(s))
      opt(s) = 2;
    else
      opt(s) = 1;
    end
    
  end
  
  QQQ = max(Q1, Q2);
  
  
  %%%% Display Q value functions
  
  figure(1);
  if idx==1, clf; end
  
  subplot(rows,cols,idx), 
  plot([1:S], Q1, 'b-' , [1:S], Q2, 'r--' , ...
       [1:S], V1, 'b.-', [1:S], V2, 'r.--');
  
  subplot(rows,cols,idx), 
  xlabel(strcat('Iteration ',num2str(idx)) );
  
  subplot(rows,cols,idx), 
  axis([1 S min([0, min(QQQ), min(Q1), min(Q2),  min(V1), min(V2)]) ...
	max( [1, max(QQQ), max(Q1),  max(Q2), max(V1), max(V2)] ) ]);

  
  %%%% Display V value functions
  
  figure(2);
  if idx==1, clf; end
  
  subplot(rows,cols,idx), plot([1:S], QQQ, 'm-', [1:S], VVV, 'm.-');
  subplot(rows,cols,idx), xlabel(strcat('Iteration ',num2str(idx)) );
  subplot(rows,cols,idx), axis([1 S min( [0, min(QQQ), min(VVV)] ) ...
		    max( [1, max(QQQ), max(VVV)] ) ]);
  
  
  %%%% Display policies
  
  figure(3);
  if idx==1, clf; end
  subplot(rows,cols,idx), imagesc([1:S],[1:2],[ppp; opt],[0.6 2]);
  subplot(rows,cols,idx), xlabel(strcat('Iteration ',num2str(idx)) );
  hold on 
  subplot(rows,cols,idx), line([1,S],[1.5,1.5]);
  
  drawnow;
  
  
  return
