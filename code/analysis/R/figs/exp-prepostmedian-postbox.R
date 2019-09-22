library("ggplot2");
library("gridExtra");

plot1 <- function(f_df) {

    legend.labels = sapply(levels(f_df$TWO_R), function(l) bquote(italic(R[.(l)])))

    return(
        ggplot(median_summary(f_df), aes(S, med, colour = R)) +
            my_theme(legend.labels = legend.labels) +
            geom_point(aes(shape = R), size = 3) +
            geom_line(aes(group = R)) +
            labs(title = count_title("Median Game Touches", f_df), y = "Median Touches", x = "Game", shape = "Treatment", color = "Treatment")            
    )
}

plot2 <- function(f_df) {
    return(
        ggplot(f_df, aes(x = TWO_R, y = ONE_T)) +
            my_theme() +
            geom_boxplot() +
            labs(x = "Treatment", y = "Touches", title = count_title("Distribution of Pre-Test Touches", f_df))
    )
}

plot3 <- function(f_df) {

    labels = sapply(levels(f_df$TWO_R), function(l) bquote(italic(R[.(l)])))

    return(
        ggplot(f_df, aes(x = TWO_R, y = TWO_T)) +
            my_theme() +
            geom_boxplot() +
            scale_x_discrete(labels = labels) +
            labs(x = "Treatment", y = "Touches", title = count_title("Distribution of Post-Test Touches", f_df))
    )
}

my_dev(file = "exp1-prepostmedian-postbox", width = 1215, height = 475)
grid.arrange(plot1(f1_df), plot3(f1_df), ncol = 2)
dev.off()

my_dev(file = "exp2-prepostmedian-postbox", width = 1215, height = 475)
grid.arrange(plot1(f2_df), plot3(f2_df), ncol = 2)
dev.off()