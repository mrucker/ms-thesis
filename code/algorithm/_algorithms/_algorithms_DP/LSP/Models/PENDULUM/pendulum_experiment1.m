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
% A script that runs the following experiment "rep" times,
% averages the results, plots them, and saves them in "experiment1":
%
%    1. Collect training data from n=[0:epistp:maxepi] episodes 
%    2. Run LSPI on those data until convergence or max 15 iterations
%    3. Evaluate the resulting policy in each case (pendulum_evalpol)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all
basis = 'pendulum_kernel_rbf';
domain = 'pendulum';
discount = 0.95;
rep = 50;
maxepi = 200;
maxsteps =50;
epistp = 120;
epi = [0:epistp:maxepi];
n = length(epi);

success_steps = 2000;   % 5 minutes
howmany = 20;

%allprob = zeros(rep,n);
%allstep = zeros(rep,n);

for r=1:rep
  
  new_samples = collect_samples(domain, maxepi, maxsteps);
  for i=1:10
    numepi = i* 5;
    disp('###########################################################');
    disp(['Current Run: ' num2str(r) ' out of ' num2str(rep)]);
    disp(['Number of training episodes: ' numepi]);
    
    epi =1; 
    j = 0;
    while epi <= numepi
        j = j+1;
        sam(j)=new_samples(j);
        if new_samples(j).absorb == 1
            epi = epi +1;
        end
    end
    
    [allpol(r,i), alllspipol, sam, Dic, para] = pendulum_learn(10, 10^-5, ...
						  sam, numepi, 100, ...
						  discount, basis);
  
    [allprob(r,i), allstep(r,i)] = pendulum_evalpol(allpol(r,i), ...
						    howmany, success_steps, Dic, para(1));
    
  end
  
  save temp_exper1 r allprob allstep epi allpol sam alllspipol
  
end


prob = mean(allprob,1); 
prob_std = std(allprob,0,1);
prob_ebs = 1.96 * prob_std ./ sqrt(size(allprob,1));

step = mean(allstep);
step_std = std(allstep,0,1);
step_ebs = 1.96 * step_std ./ sqrt(size(allstep,1));
  
minstep = min(allstep,[],1);
maxstep = max(allstep,[],1); 
  

save experiment1 basis discount rep epi success_steps howmany r ...
    allprob allstep prob step minstep maxstep

pendulum_plotexper('experiment1');
