library("ggplot2");
library("gridExtra");

plot1 <- function(kla) {
    v = ddply(kla[grepl("kla", kla$algorithm),], .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))
    v$algorithm = gsub("kla, e", "KLA, E", v$algorithm)

    return (
        ggplot(v, aes(iteration, avg, colour = algorithm)) +
            my_theme() +
            geom_point(aes(shape = algorithm), size = 2) +
            geom_line(aes(group = algorithm)) +
            #geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
            labs(x = "Iteration", y = "Avg Value", title = "Average Value By Iteration", colour = "Algorithms", shape = "Algorithms")
    )
}

plot2 <- function(kla) {
    v = ddply(kla, .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))
    v$algorithm = revalue(v$algorithm, c("random" = "Random", "kla, exploit, W=2" = "KLA, Exploit, W=2", "kla, explore, W=2" = "KLA, Explore, W=2", "lspi" = "LSPI", "klspi" = "KLSPI"))
    v = v[!grepl("kla", v$algorithm),]

    return(
        ggplot(v, aes(iteration, avg, colour = algorithm)) +
            my_theme() +
            geom_point(aes(shape = algorithm), size = 2) +
            geom_line(aes(group = algorithm)) +
            geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
            labs(x = "Iteration", y = "Avg Value", title = "Average Value By Iteration", colour = "Algorithms", shape = "Algorithms")
    )
}

my_dev(file = "kla-perf", width = 1215, height = 300)
grid.arrange(plot1(kla), plot2(kla), ncol = 2)
dev.off()