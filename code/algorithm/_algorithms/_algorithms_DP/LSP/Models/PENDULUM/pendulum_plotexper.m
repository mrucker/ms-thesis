function pendulum_plotexper(experfile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright 2000-2002 
%
% Michail G. Lagoudakis (mgl@cs.duke.edu)
% Ronald Parr (parr@cs.duke.edu)
%
% Department of Computer Science
% Box 90129
% Duke University
% Durham, NC 27708
% 
%
% pendulum_plotexper(experfile)
%
% Plots the experimental data stored in "experfile"
% The "experfile" should contain the matrices allprob and allstep
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

  
  load(experfile);
  
  prob = mean(allprob,1); 
  prob_std = std(allprob,0,1);
  prob_ebs = 1.96 * prob_std ./ sqrt(size(allprob,1));
  
  step = mean(allstep);
  step_std = std(allstep,0,1);
  step_ebs = 1.96 * step_std ./ sqrt(size(allstep,1));
  
  minstep = min(allstep,[],1);
  maxstep = max(allstep,[],1); 
  
  myxaxis = [epi(1)-20 epi(length(epi))+20];
  
  figure(20);
  clf;
  plot(epi,allprob);
  axis([myxaxis -0.09 1.09]);
  title('Probability of success (all repeats)');
  xlabel('Number of training episodes');
  ylabel('Probability');
  
  
  
  figure(21);
  clf;
  plot(epi,prob,'b-');
  hold on
  errorbar(epi,prob,prob_ebs,'r+');
  axis([myxaxis -0.09 1.09]);
  title('Average probability of success');
  xlabel('Number of training episodes');
  ylabel('Probability');
  
  

  figure(22);
  clf;
  plot(epi,allstep);
  tmp = axis;
  axis([myxaxis 0 tmp(4)]);
  title('Number of balancing steps (all repeats)');
  xlabel('Number of training episodes');
  ylabel('Steps');
  
  

  figure(23);
  clf;
  plot(epi,step,'b-');
  hold on
  errorbar(epi,step,step_ebs,'r+');
  tmp = axis;
  axis([myxaxis 0 tmp(4)]);
  title('Average number of balancing steps');
  xlabel('Number of training episodes');
  ylabel('Steps');
  
  

  
  figure(24);
  clf;
  plot(epi,minstep,'b-');
  hold on
  plot(epi,maxstep,'r-');
  tmp = axis;
  axis([myxaxis 0 tmp(4)]);
  title('Worst and best policy: average number of balancing steps');
  xlabel('Number of training episodes');
  ylabel('Steps');
  
