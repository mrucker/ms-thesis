library("ggplot2");
library("gridExtra");

plot1 <- function(n_one_dim_states) {
    v = ddply(irl[(irl$n == n_one_dim_states) & (irl$s <= 100),], .(s, algorithm), summarize, med = median(time), avg = mean(time), var = var(time), se = sd(time) / sqrt(length(time)))

    return(
        ggplot(v, aes(s, avg, colour = algorithm)) +
            my_theme() +
            geom_point(aes(shape = algorithm), size = 3) +
            geom_line(aes(group = algorithm)) +
            geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
            labs(x = "Trajectory Count", y = "Avg Runtime (sec)", title = sprintf("Runtime By Trajectory Count\n(With %i State MDP)", n_one_dim_states ^ 2), colour = "Algorithm", shape = "Algorithm")
    )
}

plot2 <- function(n_expert_trajectories) {
    v = ddply(irl[irl$s == n_expert_trajectories,], .(n, algorithm), summarize, med = median(time), avg = mean(time), var = var(time), se = sd(time) / sqrt(length(time)))

    return(
        ggplot(v, aes(n ^ 2, avg, colour = algorithm)) +
            my_theme() +
            geom_point(aes(shape = algorithm), size = 3) +
            geom_line(aes(group = algorithm)) +
            geom_errorbar(aes(ymin = avg - se, ymax = avg + se)) +
            labs(x = "State Space Size", y = "Avg Runtime (sec)", title = sprintf("Runtime By State Space Size\n(With %i Expert Trajectories)", n_expert_trajectories), colour = "Algorithm", shape = "Algorithm")
    )
}

my_dev(file = "irl-time", width = 1215, height = 300)
grid.arrange(plot1(15), plot2(50), plot2(100), ncol = 3)
dev.off()