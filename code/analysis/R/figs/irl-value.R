library("ggplot2");
library("gridExtra");

plot1 <- function(n_one_dim_states) {
    v = ddply(irl[(irl$n == n_one_dim_states) & (irl$s <= 100),], .(s, algorithm), summarize, med = median(1 - value), avg = mean(1 - value), var = var(1 - value), se = sd(1 - value) / sqrt(length(value)))

    return(
        ggplot(v, aes(s, avg, colour = algorithm, shape = algorithm)) +
            my_theme() +
            geom_line() +
            geom_point() +
            coord_cartesian(ylim=c(0,0.8)) + 
            scale_y_continuous(labels = scales::percent) +
            guides(shape = guide_legend(override.aes = list(linetype = 0))) +
            labs(x = "Number of Expert Samples", y = "Mean Value Loss", colour = "Algorithm", shape = "Algorithm")
            #labs(x = bquote(paste("M")), y = bquote(frac(paste(E[d]^pi[E] ,"[", V[E], "]", "-", E[d]^pi[IRL] ,"[", V[E], "]"), paste(E[d]^pi[E] ,"[", V[E], "]"))) , title = bquote(paste("% of Value Loss by # of Expert Samples M")), colour = "Algorithm", shape = "Algorithm")
    )
}

plot2 <- function(n_expert_trajectories) {
    v = ddply(irl[irl$s == n_expert_trajectories,], .(n, algorithm), summarize, med = median(1 - value), avg = mean(1 - value), var = var(time), se = sd(1 - value) / sqrt(length(value)))

    return(        
        ggplot(v, aes(n ^ 2, avg, colour = algorithm, shape=algorithm)) +
            my_theme() +
            geom_line() +
            geom_point() +
            coord_cartesian(ylim=c(0,0.8)) + 
            scale_y_continuous(labels = scales::percent) +
            guides(shape = guide_legend(override.aes = list(linetype = 0))) +
            labs(x = "Number of States", y = "Mean Value Loss", colour = "Algorithm", shape = "Algorithm")
            #labs(x = bquote(paste("|", italic(S), "|")), y = bquote(frac(paste(E[d]^pi[E] ,"[", V[E], "]", "-", E[d]^pi[IRL],"[", V[E], "]"),paste(E[d]^pi[E], "[", V[E], "]"))) , title = bquote(paste("% of Value Loss by # of States ", "|", italic(S), "|")), colour = "Algorithm", shape = "Algorithm")
    )
}

my_dev(file = "irl-value", width = 1215, height = 300)
grid.arrange(plot1(15), plot2(100), ncol = 2)
dev.off()