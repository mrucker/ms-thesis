library("ggplot2");
library("gridExtra");

#ylim = c(.2,1.35)
ylim = c(.2,3.00)

size     = 4
position = position=position_jitter(height=0.02, width=0.1)

plot1 <- function(kla) {
    kla = kla[(grepl("W=3", kla$algorithm) & grepl("Monte", kla$algorithm) & grepl("explore", kla$algorithm)) | grepl("klspi", kla$algorithm) | grepl("lspi", kla$algorithm),]
    kla = kla[kla$iteration > 0, ]
    
    kla$algorithm = gsub("^kla.*", "KLA", kla$algorithm)
    kla$algorithm = gsub("^klspi.*", "KLSPI", kla$algorithm)
    kla$algorithm = gsub("^lspi.*", "LSPI", kla$algorithm)

    return (
        ggplot(kla, aes(iteration, value, group=algorithm)) +
            my_theme(legend.position = c(0.66, 0.23), legend.key.width = unit(3,"cm")) +
            geom_smooth(aes(linetype=algorithm), color="black") +
            coord_cartesian(ylim=ylim) + 
            labs(x = "Policy Iteration", y = "Expected Value", linetype = "Algorithm", color="Algorithm")
    )
}

plot2 <- function(kla) {
    kla = kla[grepl("kla", kla$algorithm) & grepl("W=3", kla$algorithm) & grepl("explore", kla$algorithm),]
    kla = kla[kla$iteration > 0, ]
    
    kla$algorithm = gsub("^.*bootstrap.*"  , "Bootstrap"  , kla$algorithm)
    kla$algorithm = gsub("^.*Monte Carlo.*", "Monte Carlo", kla$algorithm)
    
    kla$algorithm = factor(kla$algorithm, levels = c("Monte Carlo","Bootstrap"))
    
    return(
        ggplot(kla, aes(iteration, value, group=algorithm)) +
            my_theme(legend.position = c(0.66, 0.23), legend.key.width = unit(3,"cm")) +
            geom_smooth(aes(linetype=algorithm), color="black") +
            coord_cartesian(ylim=ylim) + 
            labs(x = "Policy Iteration", y = "Expected Value", linetype = "KLA T=3, W=3, Explore")
    )
}

plot3 <- function(kla) {
    kla = kla[grepl("kla", kla$algorithm) & grepl("W=3", kla$algorithm) & grepl("Monte", kla$algorithm),]
    kla = kla[kla$iteration > 0, ]
    
    kla$algorithm = gsub("^.*explore.*", "Explore"  , kla$algorithm)
    kla$algorithm = gsub("^.*exploit.*", "Exploit", kla$algorithm)
    
    kla$algorithm = factor(kla$algorithm, levels = c("Explore","Exploit"))
    
    return(
        ggplot(kla, aes(iteration, value, group=algorithm)) +
            my_theme(legend.position = c(0.66, 0.23), legend.key.width = unit(3,"cm")) +
            geom_smooth(aes(linetype=algorithm), color="black") +
            coord_cartesian(ylim=ylim) + 
            labs(x = "Policy Iteration", y = "Expected Value", linetype = "KLA T=3, W=3, Monte Carlo")
    )
}

plot4 <- function(kla) {
    kla = kla[grepl("kla", kla$algorithm) & grepl("Monte", kla$algorithm) & grepl("explore", kla$algorithm),]
    kla = kla[kla$iteration > 0, ]
    
    kla$algorithm = gsub("^.*W=1.*", "T=3, W=1", kla$algorithm)
    kla$algorithm = gsub("^.*W=2.*", "T=3, W=2", kla$algorithm)
    kla$algorithm = gsub("^.*W=3.*", "T=3, W=3", kla$algorithm)
    
    kla$algorithm = factor(kla$algorithm, levels = c("T=3, W=1", "T=3, W=2", "T=3, W=3"))
    
    return(
        ggplot(kla, aes(iteration, value, group=algorithm)) +
            my_theme(legend.position = c(0.66, 0.23), legend.key.width = unit(3,"cm")) +
            coord_cartesian(ylim=ylim) + 
            geom_smooth(aes(linetype=algorithm), color="black") +
            labs(x = "Policy Iteration", y = "Expected Value", linetype = "KLA Monte Carlo, Explore")
    )
}

my_dev(file = "kla-perf-1", width = 1215, height = 300)
grid.arrange(plot1(kla), plot2(kla), ncol = 2)
dev.off()

my_dev(file = "kla-perf-2", width = 1215, height = 300)
grid.arrange(plot3(kla), plot4(kla), ncol = 2)
dev.off()