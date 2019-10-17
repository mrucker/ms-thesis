library("ggplot2");
library("gridExtra");

plot1 <- function(f_df) {
    return(
        ggplot(f_df, aes(sample = (ONE_T))) +
        my_theme() +
        stat_qq() +
        stat_qq_line() +
        facet_grid(cols = vars(TWO_R), labeller = label_bquote(cols = italic(R[.(as.character(TWO_R))]))) +
        labs(title = count_title("Pretest Q-Q Plot Against Normal", f_df))
    )
}

plot2 <- function(f_df) {
    return(
        ggplot(f_df, aes(sample = (TWO_T))) +
        my_theme() +
        stat_qq() +
        stat_qq_line() +
        facet_grid(cols = vars(TWO_R), labeller = label_bquote(cols = italic(R[.(as.character(TWO_R))]))) +
        labs(title = count_title("Posttest Q-Q Plot Against Normal", f_df))
    )
}

my_dev(file = "exp1-qq-normal", width = 1215, height = 475)
grid.arrange(plot1(exp_1), plot2(exp_1), nrow = 2)
dev.off()