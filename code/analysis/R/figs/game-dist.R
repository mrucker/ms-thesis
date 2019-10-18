library("visualize");

visualize.pois(100, lambda = 2)
visualize.exp(.1, 1 / 5)

tau    = 15000;
lambda = 1 / 200;

visualize.pois(0 , lambda = lambda * tau)
visualize.pois(-1, lambda = lambda * 1000)

my_dev(file = "game-dist-1", width = 607, height = 475, type="png")
visualize.pois(-1, lambda = lambda * tau)
dev.off()

my_dev(file = "game-dist-2", width = 607, height = 475, type="png")
visualize.pois(-1, lambda = lambda * 1000)
dev.off()