library("ggplot2");
library("gridExtra");

plot1 <- function(r_f, name) {
    
    return(
        ggplot(r_f, aes(x = reward)) +
            my_theme +
            geom_histogram(binwidth = .0005) +
            #geom_vline(aes(xintercept = mean(reward)), color = "black", linetype = "dashed", size = 1) +
            labs(x = "Reward Value", y = "Count", title = sprintf("Raw Reward Distribution for %s", name))
    )
}

my_dev(file = "rewd-raw", width = 1215, height = 475)
grid.arrange(plot1(LL,"LL"), plot1(HH,"HH"), ncol = 2)
dev.off()