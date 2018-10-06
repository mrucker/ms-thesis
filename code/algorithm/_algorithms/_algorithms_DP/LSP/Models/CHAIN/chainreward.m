function reward = chainreward()

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
% reward = chainreward()
%
% Defines the reward function of all states
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  S = chainstates;
  
  reward=zeros(S,1);
  
  reward(1)=1;
  reward(S)=1;
  
  %reward(10)=1;
  %reward(11)=1;
  
  %reward(floor((S+1)/2))=1;
  %reward(ceil((S+1)/2))=1;
  
  % your choice ... 
  
  return
