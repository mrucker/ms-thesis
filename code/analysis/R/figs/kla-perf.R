library("ggplot2");
library("gridExtra");

legend.title = "Algorithms & Parameters"

size     = 4
position = position=position_jitter(height=0.02, width=0.1)

plot1 <- function(kla) {
    kla = kla[(grepl("W=2", kla$algorithm) & grepl("Monte", kla$algorithm) & !grepl("T=10", kla$algorithm) & grepl("explore", kla$algorithm)) | (grepl("bandwidth=1.0", kla$algorithm) & grepl("mu=0.3", kla$algorithm)) | grepl("polynomial=2", kla$algorithm),]
    kla = kla[kla$iteration > 1, ]
    
    kla$algorithm = gsub("^kla.*", "KLA", kla$algorithm)
    kla$algorithm = gsub("^klspi.*", "KLSPI", kla$algorithm)
    kla$algorithm = gsub("^lspi.*", "LSPI", kla$algorithm)

    return (
        ggplot(kla, aes(iteration, value, group=algorithm)) +
            my_theme(legend.position = c(0.66, 0.23), legend.key.width = unit(3,"cm")) +
            geom_smooth(aes(linetype=algorithm), color="black") +
            coord_cartesian(ylim=c(.2,1.35)) + 
            labs(x = "Policy Iteration", y = "Expected Value", linetype = "Algorithm", color="Algorithm")
    )
}

plot2 <- function(kla) {
    kla = kla[grepl("kla", kla$algorithm) & !grepl("T=10", kla$algorithm) & grepl("W=2", kla$algorithm) & grepl("explore", kla$algorithm),]
    
    kla$algorithm = gsub("^.*bootstrap.*"  , "Bootstrap"  , kla$algorithm)
    kla$algorithm = gsub("^.*Monte Carlo.*", "Monte Carlo", kla$algorithm)
    
    return(
        ggplot(kla, aes(iteration, value, group=algorithm)) +
            my_theme(legend.position = c(0.66, 0.23), legend.key.width = unit(3,"cm")) +
            geom_smooth(aes(linetype=algorithm), color="black") +
            coord_cartesian(ylim=c(.2,1.35)) + 
            labs(x = "Policy Iteration", y = "Expected Value", linetype = "KLA Sample Value")
    )
}

plot3 <- function(kla) {
    kla = kla[grepl("kla", kla$algorithm) & !grepl("T=10", kla$algorithm) & grepl("W=2", kla$algorithm) & grepl("Monte Carlo", kla$algorithm),]
    kla = kla[kla$iteration > 1, ]
    
    kla$algorithm = gsub("^.*explore.*", "Explore"  , kla$algorithm)
    kla$algorithm = gsub("^.*exploit.*", "Exploit", kla$algorithm)
    
    return(
        ggplot(kla, aes(iteration, value, group=algorithm)) +
            my_theme(legend.position = c(0.66, 0.23), legend.key.width = unit(3,"cm")) +
            geom_smooth(aes(linetype=algorithm), color="black") +
            coord_cartesian(ylim=c(.2,1.35)) + 
            labs(x = "Policy Iteration", y = "Expected Value", linetype = "KLA Sample Action")
    )
}

plot4 <- function(kla) {
    kla = kla[grepl("kla", kla$algorithm) & grepl("Monte", kla$algorithm) & (grepl("W=2", kla$algorithm) | grepl("W=1", kla$algorithm))  & grepl("explore", kla$algorithm),]
    kla = kla[kla$iteration > 1, ]
    
    kla$algorithm = gsub("^.*T=10.*", "T=10, W=2", kla$algorithm)
    kla$algorithm = gsub("^.*W=1.*" , "T=04, W=1", kla$algorithm)
    kla$algorithm = gsub("^.*kla.*" , "T=04, W=2", kla$algorithm)

    return(
        ggplot(kla, aes(iteration, value, group=algorithm)) +
            my_theme(legend.position = c(0.66, 0.23), legend.key.width = unit(3,"cm")) +
            coord_cartesian(ylim=c(.2,1.35)) + 
            geom_smooth(aes(linetype=algorithm), color="black") +
            labs(x = "Policy Iteration", y = "Expected Value", linetype = "KLA Sample Length")
    )
}

my_dev(file = "kla-perf-1", width = 1215, height = 300)
grid.arrange(plot1(kla), plot2(kla), ncol = 2)
dev.off()

my_dev(file = "kla-perf-2", width = 1215, height = 300)
grid.arrange(plot3(kla), plot4(kla), ncol = 2)
dev.off()