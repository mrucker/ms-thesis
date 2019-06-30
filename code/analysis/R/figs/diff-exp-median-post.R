library("ggplot2");
library("gridExtra");

plot1 <- function(f_df) {
    return(
        ggplot(median_summary(f_df), aes(S, med, colour = R)) +
            my_theme +
            geom_point(aes(shape = R), size = 3) +
            geom_line(aes(group = R)) +
            labs(title = count_title("Median Game Touches", f_df), y = "Median Touches", x = "Game", shape = "Group", color = "Group")
    )
}

plot2 <- function(f_df) {
    return(
        ggplot(f_df, aes(x = TWO_R, y = TWO_T)) +
            my_theme +
            geom_boxplot() +
            labs(x = "Group", y = "Touch Quartiles", title = count_title("Participant Count by Pre-Test Touches", f_df))
    )
}

my_dev(file = "diff-exp1-median-post", width = 1215, height = 475)
grid.arrange(plot1(f1_df), plot2(f1_df), ncol = 2)
dev.off()

my_dev(file = "diff-exp2-median-post", width = 1215, height = 475)
grid.arrange(plot1(f2_df), plot2(f2_df), ncol = 2)
dev.off()