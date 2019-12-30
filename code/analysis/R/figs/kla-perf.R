library("dplyr");
library("stringr");
library("forcats"); #for fct_relevel()
library("ggplot2");
library("gridExtra");


#ylim = c(.2,1.35)
ylim  = c(0,1.5)
start = 1

size     = 4
position = position=position_jitter(height=0.02, width=0.1)

plot1 <- function() {
    data = kla %>% 
        filter(str_detect(algorithm, "kla.*Monte.*explore.*W=3|klspi|lspi"), iteration >= start) %>%
        mutate(algorithm = factor(str_to_upper(str_replace(algorithm, ",.*", "")))) %>%
        group_by(iteration,algorithm) %>%
        summarise(
            cnt = n(),
            avg = mean(value),
            var = var(value),
            sem = sqrt(var(value)/n())
        )
    
    data$algorithm = fct_relevel(data$algorithm, "KLA", "KLSPI", "LSPI")

    plot = ggplot(data, aes(iteration, avg, group=algorithm, linetype=algorithm)) +
        my_theme(legend.position = c(0.66, 0.23), legend.key.width = unit(3,"cm")) +
        geom_ribbon(aes(ymin=avg-sem, ymax=avg+sem)) +
        geom_line() +
        coord_cartesian(ylim=ylim) + 
        labs(x = "Policy Iteration", y = "Expected Value", linetype = "Algorithm", color="Algorithm")
    
    return (plot)
}

plot2 <- function() {
    data = kla %>%
        filter(str_detect(algorithm, "kla.*explore.*W=3"), iteration >= start ) %>%
        mutate(algorithm = factor(str_to_title(str_replace(algorithm, "^.*, (.*),.*,.*$", "\\1")))) %>%
        group_by(iteration,algorithm) %>%
        summarise(
            cnt = n(),
            avg = mean(value),
            var = var(value),
            sem = sqrt(var(value)/n())
        )
    
    data$algorithm = fct_relevel(data$algorithm, "Monte Carlo", "Bootstrap")

    plot = ggplot(data, aes(iteration, avg, group=algorithm, linetype=algorithm)) +
        my_theme(legend.position = c(0.66, 0.23), legend.key.width = unit(3,"cm")) +
        geom_ribbon(aes(ymin=avg-sem, ymax=avg+sem)) +
        geom_line() +
        coord_cartesian(ylim=ylim) + 
        labs(x = "Policy Iteration", y = "Expected Value", linetype = "KLA T=3, W=3, Explore")
    
    return(plot)
}

plot3 <- function() {
    
    data = kla %>% 
        filter(str_detect(algorithm, "kla.*Monte.*W=3"), iteration >= start ) %>%
        mutate(algorithm = factor(str_to_title(str_replace(algorithm, "^.*,.*, (.*),.*$", "\\1")))) %>%
        group_by(iteration,algorithm) %>%
        summarise(
            cnt = n(),
            avg = mean(value),
            var = var(value),
            sem = sqrt(var(value)/n())
        )
    
    data$algorithm = fct_relevel(data$algorithm, "Explore", "Exploit")

    plot = ggplot(data, aes(iteration, avg, group=algorithm, linetype=algorithm)) +
        my_theme(legend.position = c(0.66, 0.23), legend.key.width = unit(3,"cm")) +
        geom_ribbon(aes(ymin=avg-sem, ymax=avg+sem)) +
        geom_line() +
        coord_cartesian(ylim=ylim) + 
        labs(x = "Policy Iteration", y = "Expected Value", linetype = "KLA T=3, W=3, Monte Carlo")
    
    return(plot)
}

plot4 <- function() {
    
    data = kla %>% 
        filter(str_detect(algorithm, "kla.*Monte.*explore"), iteration >= start ) %>%
        mutate(algorithm = factor(str_replace(algorithm, "^.*,.*,.*, (.*)$", "\\1"))) %>%
        group_by(iteration,algorithm) %>%
        summarise(
            cnt = n(),
            avg = mean(value),
            var = var(value),
            sem = sqrt(var(value)/n())
        )
    
    data$algorithm = fct_relevel(data$algorithm, "W=3", "W=2", "W=1")
    
    plot = ggplot(data, aes(iteration, avg, group=algorithm, linetype=algorithm)) +
        my_theme(legend.position = c(0.66, 0.23), legend.key.width = unit(3,"cm")) +
        geom_ribbon(aes(ymin=avg-sem, ymax=avg+sem)) +
        geom_line() +
        coord_cartesian(ylim=ylim) +
        labs(x = "Policy Iteration", y = "Expected Value", linetype = "KLA T=3, Monte Carlo, Explore")
    
    return(plot)
}

my_dev(file = "kla-perf-1", width = 1215, height = 300)
grid.arrange(plot1(), plot2(), ncol = 2)
dev.off()

my_dev(file = "kla-perf-2", width = 1215, height = 300)
grid.arrange(plot3(), plot4(), ncol = 2)
dev.off()