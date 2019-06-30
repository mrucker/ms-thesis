library("ggplot2");
library("plyr");

#I'd still like to run performance tests against projection and kernel-projection when reward is linear combination of features

p = read.csv("../../../data/algorithm/perf-irl.csv", header = TRUE, sep = ",")

p$algorithm = revalue(p$algorithm, c("an" = "PIRL", "algorithm5" = "KPIRL", "gpirl" = "GPIRL"))
p$s_f = factor(p$s)

dim(p)
colnames(p)

##############Runtime Charts##############
v = ddply(p[p$s == 50,], .(n, algorithm), summarize, med = median(time), avg = mean(time), var = var(time), se = sd(time) / sqrt(length(time)))
ggplot(v, aes(n ^ 2, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm), size = 3) +
    geom_line(aes(group = algorithm)) +
    geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
    scale_color_grey() +
    labs(x = "State Space Size", y = "Avg Runtime (sec)", title = "Runtime By State Space Size (50 Trajectories)", colour = "Algorithm", shape = "Algorithm")

v = ddply(p[p$s == 100,], .(n, algorithm), summarize, med = median(time), avg = mean(time), var = var(time), se = sd(time) / sqrt(length(time)))
ggplot(v, aes(n ^ 2, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm), size = 3) +
    geom_line(aes(group = algorithm)) +
    geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
    scale_color_grey() +
    labs(x = "State Space Size", y = "Avg Runtime (sec)", title="Runtime By State Space Size (100 Trajectories)", colour="Algorithm", shape="Algorithm")

v = ddply(p[p$n == 15,], .(s_f, algorithm), summarize, med = median(time), avg = mean(time), var = var(time), se = sd(time) / sqrt(length(time)))
ggplot(v, aes(s_f, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm), size = 3) +
    geom_line(aes(group = algorithm)) +
    geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
    scale_color_grey() +
    labs(x = "Trajectory Count", y = "Avg Runtime (sec)", title = "Runtime By Trajectory Count (225 States)", colour = "Algorithm", shape = "Algorithm")

##############Lost Value Charts##############
v = ddply(p[p$s == 50,], .(n, algorithm), summarize, med = median(1 - value), avg = mean(1 - value), var = var(time), se = sd(1 - value) / sqrt(length(value)))
ggplot(v, aes(n ^ 2, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm), size = 3) +
    geom_line(aes(group = algorithm)) +
    geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
    scale_y_continuous(labels = scales::percent) +
    geom_point(aes(shape = algorithm)) +
    scale_color_grey() +
    labs(x = "State Space Size", y = "Lost Value (%)", title = "Lost Value By State Space Size (50 Trajectories)", colour = "Algorithm", shape = "Algorithm")

v = ddply(p[p$s == 100,], .(n, algorithm), summarize, med = median(1 - value), avg = mean(1 - value), var = var(time), se = sd(1 - value) / sqrt(length(value)))
ggplot(v, aes(n ^ 2, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm), size = 3) +
    geom_line(aes(group = algorithm)) +
    geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
    scale_y_continuous(labels = scales::percent) +
    geom_point(aes(shape = algorithm)) +
    scale_color_grey() +
    labs(x = "State Space Size", y = "Lost Value (%)", title = "Lost Value By State Space Size (100 Trajectories)", colour = "Algorithm", shape = "Algorithm")

v = ddply(p[p$n == 15,], .(s, algorithm), summarize, med = median(1 - value), avg = mean(1 - value), var = var(1 - value), se = sd(1 - value) / sqrt(length(value)))
ggplot(v, aes(s, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm), size = 3) +
    geom_line(aes(group = algorithm)) +
    geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
    scale_y_continuous(labels = scales::percent) +
    geom_point(aes(shape = algorithm)) +
    scale_color_grey() +
    labs(x = "Trajectory Count", y = "Lost Value (%)", title = "Lost Value By Trajectory Count (225 States)", colour = "Algorithm", shape = "Algorithm")

