library("ggplot2");
library("gridExtra");

plot1 <- function(kla) {
    n = dim(kla[kla$iteration == 3 & kla$algorithm == "KLSPI",])[1]
    v = ddply(kla, .(iteration, algorithm), summarize, med = median(time), avg = mean(time), var = var(time), se = sd(time) / sqrt(length(time)))

    return(
    ggplot(v, aes(iteration, avg)) +
        my_theme() +
        geom_point(aes(shape = algorithm), size = 3) +
        geom_line(aes(group = algorithm)) +
        labs(x = "Iteration", y = "Avg Runtime (sec)", title = sprintf("Average Runtime By Iteration (n=%i)",n))
    )
}

plot2 <- function(kla) {
    n = dim(kla[kla$iteration == 3 & kla$algorithm == "KLSPI",])[1]
    v = ddply(kla, .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))

    return(
        ggplot(v, aes(iteration, avg)) +
            my_theme() +
            geom_point(aes(shape = algorithm), size = 3) +
            geom_line(aes(group = algorithm)) +
            #geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
            labs(x = "Iteration", y = "Avg Value", title = sprintf("Average Runtime By Iteration (n=%i)", n))
    )
}

plot3 <- function(kla) {
    n = dim(kla[kla$iteration == 3 & kla$algorithm == "KLSPI",])[1]
    v = ddply(kla, .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))

    return(
        ggplot(v, aes(iteration, avg, colour = algorithm)) +
            my_theme() +
            geom_point(aes(shape = algorithm), size = 3) +
            geom_line(aes(group = algorithm)) +
            labs(x = "Iteration", y = "Avg Value", title = sprintf("Average Runtime By Iteration (n=%i)", n))
    )
}

my_dev(file = "kla-perf2", width = 1215, height = 300)
grid.arrange(plot1(kla2), plot2(kla2), ncol = 2)
dev.off()

my_dev(file = "kla-perf3", width = 1215, height = 300)
grid.arrange(plot1(kla3), plot2(kla3), ncol = 2)
dev.off()

my_dev(file = "kla-perf4", width = 1215, height = 300)
grid.arrange(plot1(kla4), plot3(kla4), ncol = 2)
dev.off()