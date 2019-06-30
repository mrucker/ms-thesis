library("ggplot2");
library("gridExtra");

file1 = sprintf("%s/diff-exp1-qq-plot.png", figs_path)

plot1 <- function(f_df) {
    return(
        ggplot(f_df, aes(sample = (ONE_T))) + stat_qq() + stat_qq_line() + facet_grid(~TWO_R) + labs(title = count_title("Game 1 QQ-Plot Against Normal", f_df))
    )
}

plot2 <- function(f_df) {
    return(
        ggplot(f_df, aes(sample = (TWO_T))) + stat_qq() + stat_qq_line() + facet_grid(~TWO_R) + labs(title = count_title("Game 2 QQ-Plot Against Normal", f_df))
    )
}

png(file = file1, width = 1215, height = 475)
grid.arrange(plot1(f1_df), plot2(f1_df), nrow = 2)
dev.off()