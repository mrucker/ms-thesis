function  [nextstate, reward, absorb, prob, rewfun] = ...
    chain_simulator(state, action)

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
% [nextstate, reward, absorb, prob, rewfun] = ...
%                               chain_simulator(state, action)
%
% A simulator for the chain domain.
%
% In addition to the typical output (nextstate, reward, absorb) it
% return the transition model of the chain
% prob(state,action,nextstate) and the reward functions
% rewfun. These are not used by LSPI is any way, but are used by
% chainsolve to get exact solutions for comparison. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

  persistent S;
  persistent M;
  persistent pr;
  persistent rew;

  
  if  isempty(pr)
    
    S = chainstates;
    A = chainactions;
    pr=zeros(S,A,S);
    succprob=0.9;
    failprob=0.1;
    
    for (i=1:S)
      pr(i,1,max(1,i-1)) = succprob;
      pr(i,1,min(S,i+1)) = failprob;
      pr(i,2,min(S,i+1)) = succprob;
      pr(i,2,max(1,i-1)) = failprob;
    end
    
    rew = chainreward;
  
  end
    
  
  if nargin==0
    
    nextstate = randint(S);
    reward = 0;
    absorb=0;
    
    prob = pr;
    rewfun = rew;
    
    return
    
  elseif nargin==1
    
    nextstate = state;
    reward = rew(state);
    absorb=0;
    
    return
    
  end
  
  rrr = rand;
  totprob=0;
  for j=state-1:state+1
    newstate = max(1, min(S, j) );
    totprob = totprob + pr(state,action,newstate);
    if (rrr<=totprob)
      nextstate = newstate;
      break;
    end
  end
  
  reward = rew(state);
  absorb=0;
  
  return
  
