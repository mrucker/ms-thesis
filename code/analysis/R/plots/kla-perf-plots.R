library("ggplot2");
library("plyr");

v = ddply(kla, .(iteration, algorithm), summarize, med = median(time), avg = mean(time), var = var(time), se = sd(time) / sqrt(length(time)))
ggplot(v, aes(iteration, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm), size = 3) +
    geom_line(aes(group = algorithm)) +
    scale_color_grey() +
    geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
    labs(x = "Iteration", y = "Avg Runtime (sec)", title = "Average Runtime By Iteration")

v = ddply(kla, .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))
ggplot(v, aes(iteration, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm), size = 3) +
    geom_line(aes(group = algorithm)) +
    scale_color_grey() +
    geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
    labs(x = "Iteration", y = "Avg Value", title = "Average Value By Iteration")

v = ddply(kla, .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))
v$algorithm = revalue(v$algorithm, c("random" = "Random", "kla, exploit, W=2" = "KLA, Exploit, W=2", "kla, explore, W=2" = "KLA, Explore, W=2", "lspi" = "LSPI", "klspi" = "KLSPI"))
v = v[!grepl("kla", v$algorithm), ]
ggplot(v, aes(iteration, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm)) +
    geom_line(aes(group = algorithm)) +
    geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
    labs(x = "Iteration", y = "Avg Value", title = "Average Value By Iteration", colour = "Algorithms", shape = "Algorithms")

v = ddply(kla[grepl("kla", kla$algorithm),], .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))
v$algorithm = gsub("kla, e", "KLA, E", v$algorithm)
ggplot(v, aes(iteration, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm)) +
    geom_line(aes(group = algorithm)) +
    geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
    labs(x = "Iteration", y = "Avg Value", title = "Average Value By Iteration", colour="Algorithms", shape="Algorithms")