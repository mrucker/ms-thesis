function samples = chainuniformsamples()

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
% samples = chainuniformsamples()
%
% Collects samples from the chain uniformly over (state,action)
% Assumes dynamics: 0.9 and 0.1 for success and failure
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  S = chainstates;
  A = chainactions;
  rew = chainreward;

  num = 0;

  for s=1:1:S
    for a=1:A
      for i=1:10
	num = num + 1;
	
	if (i<10)
	  samples(num).state = s;
	  samples(num).action = a;
	  samples(num).reward = rew(s);
	  if a==2
	    samples(num).nextstate = min(S,s+1);
	  else
	    samples(num).nextstate = max(1,s-1);
	  end
	  samples(num).absorb = 0;
	elseif (i==10)
	  samples(num).state = s;
	  samples(num).action = a;
	  samples(num).reward = rew(s);
	  if a==1
	    samples(num).nextstate = min(S,s+1);
	  else
	    samples(num).nextstate = max(1,s-1);
	  end
	  samples(num).absorb = 0;
	else
	  samples(num).state = s;
	  samples(num).action = a;
	  samples(num).reward = rew(s);
	  samples(num).nextstate = 0;
	  samples(num).absorb = 1;
	end
	
      end
    end
  end
  
  return
  
                
