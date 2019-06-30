library("visualize");

visualize.pois(100, lambda = 2)
visualize.exp(.1, 1 / 5)

tau = 15000;
lambda = 1 / 200;

visualize.pois(0,lambda = lambda * tau)
visualize.pois(-1,lambda = lambda * 1000)