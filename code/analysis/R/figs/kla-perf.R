library("ggplot2");
library("gridExtra");

plot1 <- function(kla) {
    n = dim(kla[kla$iteration == 3 & kla$algorithm == "KLSPI",])[1]
    v = ddply(kla, .(iteration, algorithm), summarize, med = median(time), avg = mean(time), var = var(time), se = sd(time) / sqrt(length(time)))

    return(
    ggplot(v, aes(iteration, avg, colour = algorithm)) +
        my_theme() +
        geom_point(aes(shape = algorithm), size = 3) +
        geom_line(aes(group = algorithm)) +
        geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
        labs(x = "Iteration", y = "Avg Runtime (sec)", title = sprintf("Average Cumulative Runtime By Iteration",n))
    )
}

plot2 <- function(kla) {
    n = dim(kla[kla$iteration == 3 & kla$algorithm == "KLSPI",])[1]
    v = ddply(kla, .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))

    return(
        ggplot(v, aes(iteration, avg, colour = algorithm)) +
            my_theme() +
            geom_point(aes(shape = algorithm), size = 3) +
            geom_line(aes(group = algorithm)) +
            geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
            labs(x = "Iteration", y = "Avg Value", title = "Average Expected Value By Iteration", color = "Algorithm", shape = "Algorithm")
    )
}

my_dev(file = "kla-perf", width = 1215, height = 300)
grid.arrange(plot1(kla), plot2(kla), ncol = 2)
dev.off()