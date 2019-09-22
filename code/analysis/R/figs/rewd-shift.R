library("ggplot2");
library("gridExtra");

plot1 <- function(r_f, name) {

    raw_reward      = r_f$reward
    no_touch_reward = r_f$reward[1]
    aff_reward      = raw_reward - no_touch_reward

    bin_width = .07 / 50

    return(
        ggplot(r_f, aes(x = aff_reward, fill = worth_f)) +
            my_theme() +
            geom_histogram(binwidth = bin_width) +
            xlim(-20 * bin_width, 45 * bin_width) +
            ylim(0, 1100) +
            labs(x = "Reward Value", y = "Count", fill = "", title = bquote(paste("Histogram of ",italic(R)[italic(.(name))], " Shifted")))
    )
}

my_dev(file = "rewd-shift", width = 1215, height = 300)
grid.arrange(plot1(R_LL,"LL"), plot1(R_HH,"HH"), ncol = 2)
dev.off()