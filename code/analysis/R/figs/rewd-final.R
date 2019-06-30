library("ggplot2");
library("gridExtra");

plot1 <- function(r_f, name) {

    return(
        ggplot(LL, aes(x = ((reward * (reward < quantile(reward, .97)) + quantile(reward, .97) * (reward >= quantile(reward, .97)) - reward[1]) * (reward > reward[1])), fill = worth_f)) +
            my_theme +
            geom_histogram(binwidth = .0001) +
            labs(x = "Reward Value", y = "Count", title = sprintf("Clipped and Shifted Reward Distribution for %s", name) , fill = "")
    )
}

my_dev(file="rewd-final", width=1215, height=475)
grid.arrange(plot1(LL,"LL"), plot1(HH,"HH"), ncol = 2)
dev.off()