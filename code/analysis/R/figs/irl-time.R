library("dplyr");
library("ggplot2");
library("gridExtra");

plot1 <- function(n_states) {

    data = irl %>% 
        filter(n == n_states, s <= 100) %>%
        group_by(s, algorithm) %>% 
        summarise(
            cnt = n(), 
            med = median(time), 
            avg = mean(time), 
            var = var(time), 
            sem = sqrt(var(time) / n())
        )
    
    plot = ggplot(data, aes(s, avg, colour = algorithm, shape = algorithm)) +
        my_theme() +
        geom_line(size=1.5) +
        geom_point(position=position_jitter(width=3)) +
        coord_cartesian(ylim=c(0,100)) + 
        guides(shape = guide_legend(override.aes = list(linetype = 0))) +
        labs(x = "Number of Expert Samples", y = "Mean Runtime", colour = "Algorithm", shape = "Algorithm")
    

    return(plot)
}

plot2 <- function(n_experts) {
    
    data = irl %>% 
        filter(s == n_experts) %>%
        group_by(n, algorithm) %>% 
        summarise(
            cnt = n(), 
            med = median(time), 
            avg = mean(time), 
            var = var(time), 
            sem = sqrt(var(time) / n())
        )

    plot = ggplot(data, aes(n ^ 2, avg, colour = algorithm, shape = algorithm)) +
        my_theme() +
        geom_line(size=1.5) +
        geom_point(position=position_jitter(width=3)) +
        coord_cartesian(ylim=c(0,600)) + 
        guides(shape = guide_legend(override.aes = list(linetype = 0))) +
        labs(x = "Number of States", y = "Mean Runtime", colour = "Algorithm", shape = "Algorithm")
    
    return(plot)
}

my_dev(file = "irl-time", width = 1215, height = 300)
grid.arrange(plot1(15), plot2(100), ncol = 2)
dev.off()