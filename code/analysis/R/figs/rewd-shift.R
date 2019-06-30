library("ggplot2");
library("gridExtra");

file = sprintf("%s/rewd-shift.png", figs_path)

plot1 <- function(r_f, name) {

    return(
        ggplot(r_f, aes(x = (reward - reward[1]), fill = worth_f)) +
            geom_histogram(binwidth = .0005) +
            scale_fill_grey() +
            labs(x = "Reward Value", y = "Count", title = sprintf("Shifted Reward Distribution for %s",name), fill = "")
    )
}

png(file = file, width = 1215, height = 475)
grid.arrange(plot1(LL,"LL"), plot1(HH,"HH"), ncol = 2)
dev.off()