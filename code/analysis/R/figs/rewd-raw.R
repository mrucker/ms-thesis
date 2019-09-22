library("ggplot2");
library("gridExtra");

plot1 <- function(r_f, name) {
    raw_reward = r_f$reward
    bin_width = .07 / 50

    return(
        ggplot(r_f, aes(x = raw_reward)) +
            my_theme() +
            geom_histogram(binwidth = bin_width) +
            xlim(-35 * bin_width, 30 * bin_width) +
            ylim(0, 1100) +
            labs(x = "Reward Value", y = "Count", title = bquote(paste("Distribution of ", italic(R)[italic(.(name))], " Raw")))
    )
}

my_dev(file = "rewd-raw", width = 1215, height = 300)
grid.arrange(plot1(LL,"LL"), plot1(HH,"HH"), ncol = 2)
dev.off()