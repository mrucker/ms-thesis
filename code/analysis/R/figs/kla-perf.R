library("ggplot2");
library("gridExtra");

legend.title = "Algorithms & Parameters"

plot1 <- function(kla) {
    v = ddply(kla[(grepl("W=2", kla$algorithm) & grepl("Monte", kla$algorithm) & !grepl("T=10", kla$algorithm)) | (grepl("bandwidth=1.0", kla$algorithm) & grepl("mu=0.3", kla$algorithm)) | grepl("polynomial=2", kla$algorithm),], .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))
    v$algorithm = gsub("kla", "KLA", v$algorithm)
    v$algorithm = gsub("klspi", "KLSPI", v$algorithm)
    v$algorithm = gsub("lspi", "LSPI", v$algorithm)

    return (
        ggplot(v, aes(iteration, avg, colour = algorithm)) +
            my_theme(legend.position = c(0.56, 0.28)) +
            geom_point(aes(shape = algorithm), size = 2) +
            geom_line(aes(group = algorithm)) +
        #geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
        labs(x = "Policy Iteration", y = "Expected Value", title = "Expected Value By Policy Iteration", colour = legend.title, shape = legend.title)
    )
}

plot2 <- function(kla) {
    v = ddply(kla[grepl("kla, ", kla$algorithm) & !grepl("T=10", kla$algorithm) & grepl("W=2", kla$algorithm),], .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))
    v$algorithm = gsub("kla", "KLA", v$algorithm)

    return(
        ggplot(v, aes(iteration, avg, colour = algorithm)) +
            my_theme(legend.position = c(0.56, 0.28)) +
            geom_point(aes(shape = algorithm)) +
            geom_line(aes(group = algorithm)) +
        #geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
        labs(x = "Policy Iteration", y = "Expected Value", title = "Expected Value By Policy Iteration", colour = legend.title, shape = legend.title)
    )
}

plot3 <- function(kla) {
    v = ddply(kla[grepl("kla, ", kla$algorithm) & !grepl("T=10", kla$algorithm) & grepl("Monte Carlo", kla$algorithm) & grepl("explore", kla$algorithm),], .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))
    v$algorithm = gsub("kla", "KLA", v$algorithm)

    return(
        ggplot(v, aes(iteration, avg, colour = algorithm)) +
            my_theme(legend.position = c(0.56, 0.28)) +
            geom_point(aes(shape = algorithm)) +
            geom_line(aes(group = algorithm)) +
        #geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
        labs(x = "Policy Iteration", y = "Expected Value", title = "Expected Value By Policy Iteration as W Varies", colour = legend.title, shape = legend.title)
    )
}
plot3(kla)

plot4 <- function(kla) {
    v = ddply(kla[grepl("kla", kla$algorithm) & grepl("Monte", kla$algorithm) & grepl("W=2", kla$algorithm) & grepl("explore", kla$algorithm),], .(iteration, algorithm), summarize, med = median(value), avg = mean(value), var = var(time), se = sd(value) / sqrt(length(time)))

    v$algorithm = gsub("kla", "KLA", v$algorithm)
    v$algorithm = gsub("W=2", "W=2, T=04", v$algorithm)
    v$algorithm = gsub("T=04, T=10", "T=10", v$algorithm)

    return(
        ggplot(v, aes(iteration, avg, colour = algorithm)) +
            my_theme(legend.position = c(0.56, 0.28)) +
            geom_point(aes(shape = algorithm)) +
            geom_line(aes(group = algorithm)) +
        #geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
        labs(x = "Policy Iteration", y = "Expected Value", title = "Expected Value By Policy Iteration As T Varies", colour = legend.title, shape = legend.title)
    )
}

my_dev(file = "kla-perf-1", width = 1215, height = 300)
grid.arrange(plot1(kla), plot2(kla), ncol = 2)
dev.off()

my_dev(file = "kla-perf-2", width = 1215, height = 300)
grid.arrange(plot3(kla), plot4(kla), ncol = 2)
dev.off()