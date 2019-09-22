library("ggplot2");
library("gridExtra");

plot1 <- function(r_f, name) {

    raw_reward      = r_f$reward
    no_touch_reward = r_f$reward[1]
    aff_reward      = raw_reward - no_touch_reward
    clp_aff_reward = pmax(0, pmin(quantile(aff_reward, .97), aff_reward))

    bin_width = .07 / 50

    return(
        ggplot(r_f, aes(x = clp_aff_reward, fill = worth_f)) +
            my_theme() +
            xlim(-20 * bin_width, 45 * bin_width) +
            ylim(0, 1100) +
            geom_histogram(binwidth = bin_width) +
            labs(x = "Reward Value", y = "Count", fill = "", title = bquote(paste("Distribution of ",italic(R)[italic(.(name))], " Clipped and Shifted")))
    )
}

my_dev(file="rewd-clip", width=1215, height=300)
grid.arrange(plot1(LL,"LL"), plot1(HH,"HH"), ncol = 2)
dev.off()