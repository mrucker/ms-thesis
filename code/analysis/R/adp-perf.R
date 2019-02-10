library("ggplot2");
library("plyr");

#perf-adp1.csv is a comparison of KLA, LSPI and KLSPI with KLA set to 30 30 5 2 and using state_init = 20

#Probably just want this one
#perf-adp2.csv is a comparison of KLA, LSPI and KLSPI with KLA set to 30 90 3 4 and using state_init = 3
#perf-adp3.csv is a comparison of KLA, LSPI and KLSPI with KLA set to 30 90 3 4 and using state_init = 20
#perf-adp4.csv is a comparison of KLA, LSPI and KLSPI with KLA set to 30 90 3 4 and using state_init = 20

max(p$reward)

p = rbind(read.csv("data/perf-adp3.csv", header = TRUE, sep = ","), read.csv("data/perf-adp4.csv", header = TRUE, sep = ","));
p = read.csv("data/perf-adp4.csv", header = TRUE, sep = ",");
p$algorithm = revalue(p$algorithm, c("algorithm_13ks" = "algorithm_13k", "algorithm_13kx" = "KLA(Long)" , "algorithm_lsp" = "LSPI", "algorithm_ksp"="KLSPI"))

unique(p$reward)

v = ddply(p, .(iteration, algorithm), summarize, med = median(time), avg = mean(time), var = var(time), se = sd(time) / sqrt(length(time)))
ggplot(v, aes(iteration, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm), size=3) +
    geom_line(aes(group = algorithm)) +
    scale_color_grey() +
    labs(x = "Iteration", y = "Avg Runtime (sec)", title = "Average Runtime By Iteration (n=287)")

v = ddply(p, .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))
ggplot(v[v$algorithm != "KLA(Long)",], aes(iteration, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm), size=3) +
    geom_line(aes(group = algorithm)) +
    scale_color_grey() +
    geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
    labs(x = "Iteration", y = "Avg Value", title = "Average Value By Iteration (n=287)")