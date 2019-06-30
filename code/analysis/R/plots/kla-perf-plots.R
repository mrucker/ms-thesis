library("ggplot2");
library("plyr");

v = ddply(kla2, .(iteration, algorithm), summarize, med = median(time), avg = mean(time), var = var(time), se = sd(time) / sqrt(length(time)))
ggplot(v, aes(iteration, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm), size=3) +
    geom_line(aes(group = algorithm)) +
    scale_color_grey() +
    labs(x = "Iteration", y = "Avg Runtime (sec)", title = "Average Runtime By Iteration (n=287)")

v = ddply(kla2, .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))
ggplot(v, aes(iteration, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm), size=3) +
    geom_line(aes(group = algorithm)) +
    scale_color_grey() +
    #geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
    labs(x = "Iteration", y = "Avg Value", title = "Average Value By Iteration (n=287)")