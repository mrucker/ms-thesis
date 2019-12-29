library("ggplot2");
library("gridExtra");

plot1 <- function(n_one_dim_states) {
    v = ddply(irl[(irl$n == n_one_dim_states) & (irl$s <= 100),], .(s, algorithm), summarize, med = median(time), avg = mean(time), var = var(time), se = sd(time) / sqrt(length(time)))

    return(
        ggplot(v, aes(s, avg, colour = algorithm, shape = algorithm)) +
            my_theme() +
            geom_line(size=1.5) +
            geom_point(position=position_jitter(width=3)) +
            coord_cartesian(ylim=c(0,100)) + 
            guides(shape = guide_legend(override.aes = list(linetype = 0))) +
            labs(x = "Number of Expert Samples", y = "Mean Runtime", colour = "Algorithm", shape = "Algorithm")
    )
}

plot2 <- function(n_expert_trajectories) {
    v = ddply(irl[irl$s == n_expert_trajectories,], .(n, algorithm), summarize, med = median(time), avg = mean(time), var = var(time), se = sd(time) / sqrt(length(time)))

    return(
        ggplot(v, aes(n ^ 2, avg, colour = algorithm, shape = algorithm)) +
            my_theme() +
            geom_line(size=1.5) +
            geom_point(position=position_jitter(width=3)) +
            coord_cartesian(ylim=c(0,600)) + 
            guides(shape = guide_legend(override.aes = list(linetype = 0))) +
            labs(x = "Number of States", y = "Mean Runtime", colour = "Algorithm", shape = "Algorithm")
    )
}

my_dev(file = "irl-time", width = 1215, height = 300)
grid.arrange(plot1(15), plot2(100), ncol = 2)
dev.off()