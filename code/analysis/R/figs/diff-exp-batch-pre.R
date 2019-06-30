library("ggplot2");
library("gridExtra");

file1 = sprintf("%s/diff-exp1-batch-pre.png", figs_path)
file2 = sprintf("%s/diff-exp2-batch-pre.png", figs_path)

plot1 <- function(f_df) {
    return(
        ggplot(f_df, aes(x = ONE_DT, fill = TWO_R)) +
            geom_histogram(bins = 60) +
            scale_fill_grey() +
            scale_x_datetime(date_breaks = "1 day", date_labels = "%b %d") +
            facet_grid(rows = vars(TWO_R)) +
            labs(x = "Date Time", y = "Participants", title = count_title("Participant Count by Date", f_df), fill = "Group")
    )
}

plot2 <- function(f_df) {
    return(
        ggplot(f_df, aes(x = ONE_T, fill = TWO_R)) +
            geom_bar() +
            geom_vline(aes(xintercept = median(ONE_T), col = TWO_R), size = 1, linetype = "dotted") +
            scale_fill_grey() +
            scale_color_grey(start = 0.05, end = 0.65) +
            facet_grid(rows = vars(TWO_R)) +
            labs(x = "Game 1 Touches", y = "Participants", title = count_title("Participant Count by Pre-Test Touches", f_df), fill = "Group", color = "Median")
    )
}

png(file = file1, width = 1215, height = 475)
grid.arrange(plot1(f1_df), plot2(f1_df), ncol = 2)
dev.off()

png(file = file2, width = 1215, height = 475)
grid.arrange(plot1(f2_df), plot2(f2_df), ncol = 2)
dev.off()