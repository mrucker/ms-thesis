library("ggplot2");
library("gridExtra");

plot1 <- function(r_f, name) {
    raw_reward = r_f$reward
    bin_width = .07 / 50

    return(
        ggplot(r_f, aes(x = raw_reward)) +
            my_theme() +
            geom_histogram(binwidth = bin_width) +
            coord_cartesian(xlim=c(-35 * bin_width, 30 * bin_width), ylim=c(0, 1100)) + 
            labs(x = "Reward Value", y = "State Count")
            #labs(x = "Reward Value", y = "State Count", title = bquote(paste("Histogram of ", italic(R)[italic(.(name))], " Raw")))
    )
}

my_dev(file = "rewd-raw", width = 1215, height = 250)
grid.arrange(plot1(R_LL,"LL"), plot1(R_HH,"HH"), ncol = 2)
dev.off()