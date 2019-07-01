library("ggplot2");
library("gridExtra");

plot1 <- function(r_f, name) {

    return(
        ggplot(r_f, aes(x = (reward - reward[1]), fill = worth_f)) +
            my_theme() +
            geom_histogram(binwidth = .0005) +
            labs(x = "Reward Value", y = "Count", title = sprintf("Shifted Reward Distribution for %s",name), fill = "")
    )
}

my_dev(file = "rewd-shift", width = 1215, height = 475)
grid.arrange(plot1(LL,"LL"), plot1(HH,"HH"), ncol = 2)
dev.off()