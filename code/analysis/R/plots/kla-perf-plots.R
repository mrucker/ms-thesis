library("ggplot2");
library("plyr");

v = ddply(kla[grepl("kla", kla$algorithm) & grepl("W=2", kla$algorithm),], .(iteration, algorithm), summarize, med = median(time), avg = mean(time), var = var(time), se = sd(time) / sqrt(length(time)))
ggplot(v, aes(iteration, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm), size = 3) +
    geom_line(aes(group = algorithm)) +
    geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
    labs(x = "Iteration", y = "Avg Runtime (sec)", title = "Average Runtime By Iteration")

v = ddply(kla[grepl("lspi", kla$algorithm) & !grepl("klspi", kla$algorithm),], .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))
v$algorithm = gsub("lspi", "LSPI", v$algorithm)
ggplot(v, aes(iteration, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm)) +
    geom_line(aes(group = algorithm)) +
    #geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
    labs(x = "Iteration", y = "Avg Value", title = "Average Value By Iteration", colour = "Algorithms", shape = "Algorithms")

v = ddply(kla[grepl("klspi", kla$algorithm) & grepl("mu=0.30", kla$algorithm),], .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))
v$algorithm = gsub("klspi", "KLSPI", v$algorithm)
ggplot(v, aes(iteration, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm)) +
    geom_line(aes(group = algorithm)) +
    #geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
    labs(x = "Iteration", y = "Avg Value", title = "Average Value By Iteration", colour = "Algorithms", shape = "Algorithms")

v = ddply(kla[grepl("kla", kla$algorithm) & !grepl("T=10", kla$algorithm) & grepl("Monte Carlo", kla$algorithm) & grepl("explore", kla$algorithm),], .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))
v$algorithm = gsub("kla", "KLA", v$algorithm)
ggplot(v, aes(iteration, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm)) +
    geom_line(aes(group = algorithm)) +
    geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
    labs(x = "Iteration", y = "Avg Value", title = "Average Value By Iteration", colour = "Algorithms", shape = "Algorithms")

v = ddply(kla[grepl("kla", kla$algorithm) & grepl("Monte Carlo", kla$algorithm) & grepl("W=2", kla$algorithm),], .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))
v$algorithm = gsub("kla", "KLA", v$algorithm)
ggplot(v, aes(iteration, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm)) +
    geom_line(aes(group = algorithm)) +
    geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
    labs(x = "Iteration", y = "Avg Value", title = "Average Value By Iteration", colour = "Algorithms", shape = "Algorithms")

v = ddply(kla[grepl("kla, ", kla$algorithm) & !grepl("T=10", kla$algorithm) & grepl("W=2", kla$algorithm),], .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))
v$algorithm = gsub("kla", "KLA", v$algorithm)
ggplot(v, aes(iteration, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm)) +
    geom_line(aes(group = algorithm)) +
    #geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
    labs(x = "Iteration", y = "Avg Value", title = "Average Value By Iteration", colour = "Algorithms", shape = "Algorithms")

v = ddply(kla[ (grepl("W=2", kla$algorithm) & !grepl("T=10", kla$algorithm)) | (grepl("bandwidth=1.0", kla$algorithm) & grepl("mu=0.3", kla$algorithm)) | grepl("polynomial=2", kla$algorithm),], .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))
v$algorithm = gsub("kla", "KLA", v$algorithm)
v$algorithm = gsub("klspi", "KLSPI", v$algorithm)
v$algorithm = gsub("lspi", "LSPI", v$algorithm)
ggplot(v, aes(iteration, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm)) +
    geom_line(aes(group = algorithm)) +
    #geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
    labs(x = "Iteration", y = "Avg Value", title = "Average Value By Iteration", colour = "Algorithms", shape = "Algorithms")

v = ddply(kla[(grepl("W=2", kla$algorithm) & grepl("Monte", kla$algorithm) & !grepl("T=10", kla$algorithm)) | (grepl("bandwidth=1.0", kla$algorithm) & grepl("mu=0.3", kla$algorithm)) | grepl("polynomial=2", kla$algorithm),], .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))
v$algorithm = gsub("kla", "KLA", v$algorithm)
v$algorithm = gsub("klspi", "KLSPI", v$algorithm)
v$algorithm = gsub("lspi", "LSPI", v$algorithm)
ggplot(v, aes(iteration, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm)) +
    geom_line(aes(group = algorithm)) +
    #geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
    labs(x = "Iteration", y = "Avg Value", title = "Average Value By Iteration", colour = "Algorithms", shape = "Algorithms")

v = ddply(kla[grepl("kla", kla$algorithm) & grepl("Monte", kla$algorithm) & (grepl("T=10", kla$algorithm) | grepl("W=2", kla$algorithm)),], .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))
v$algorithm = gsub("kla", "KLA", v$algorithm)
ggplot(v, aes(iteration, avg, colour = algorithm)) +
    geom_point(aes(shape = algorithm)) +
    geom_line(aes(group = algorithm)) +
    #geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
    labs(x = "Iteration", y = "Avg Value", title = "Average Value By Iteration", colour = "Algorithms", shape = "Algorithms")