library("ggplot2");
library("gridExtra");

plot1 <- function(f_df) {
    return(
        ggplot(f_df, aes(x = ONE_DT)) +
            my_theme() +
            geom_histogram(bins = 60) +
            scale_x_datetime(date_breaks = "1 day", date_labels = "%b %d") +
            facet_grid(rows = vars(TWO_R), labeller = label_bquote(rows = italic(R[.(as.character(TWO_R))]))) +
            labs(x = "Date Time", y = "Participants", title = count_title("Participant Count by Date", f_df), fill = "Group")
    )
}

plot2 <- function(f_df) {
    return(
        ggplot(f_df, aes(x = ONE_T)) +
            my_theme() +
            geom_bar() +
            #geom_vline(aes(xintercept = median(ONE_T), col = TWO_R), size = 1, linetype = "dotted") +
            facet_grid(rows = vars(TWO_R), labeller = label_bquote(rows = italic(R[.(as.character(TWO_R))]))) +
            labs(x = "Pre-Test Touches", y = "Participants", title = count_title("Participant Count by Pre-Test Touches", f_df), fill = "Group", color = "Median")
    )
}

my_dev(file = "exp1-date-prehist", width = 1215, height = 475)
grid.arrange(plot1(exp_1), plot2(exp_1), ncol = 2)
dev.off()

my_dev(file = "exp2-date-prehist", width = 1215, height = 475)
grid.arrange(plot1(exp_2), plot2(exp_2), ncol = 2)
dev.off()