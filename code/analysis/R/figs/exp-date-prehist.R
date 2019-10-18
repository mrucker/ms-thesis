library("ggplot2");
library("gridExtra");

plot1 <- function(f_df, breaks) {
    return(
        ggplot(f_df, aes(x = ONE_DT)) +
            my_theme() +
            geom_histogram(bins = 60) +
            scale_x_datetime(date_breaks = "2 day", date_labels = "%b %d, %Y") +
            scale_y_continuous(breaks=c(0,70,140)) +
            facet_grid(rows = vars(TWO_R), labeller = label_bquote(rows = italic(R[.(as.character(TWO_R))]))) +
            labs(x = "Recruitment Time", y = "Participant Count")
    )
}

plot2 <- function(f_df) {
    return(
        ggplot(f_df, aes(x = ONE_DT)) +
            my_theme() +
            geom_histogram(bins = 60) +
            scale_x_datetime(date_breaks = "3 day", date_labels = "%b %d, %Y") +
            scale_y_continuous(breaks=c(0,15,30)) +
            facet_grid(rows = vars(TWO_R), labeller = label_bquote(rows = italic(R[.(as.character(TWO_R))]))) +
            labs(x = "Recruitment Time", y = "Participant Count")
    )
}

plot3 <- function(f_df) {
    return(
        ggplot(f_df, aes(x = ONE_T)) +
            my_theme() +
            geom_bar() +
            scale_y_continuous(breaks=c(0,10,20)) +
            facet_grid(rows = vars(TWO_R), labeller = label_bquote(rows = italic(R[.(as.character(TWO_R))]))) +
            labs(x = "Pretest Performance", y = "Participant Count")
    )
}

my_dev(file = "exp1-date-prehist", width = 1215, height = 350)
grid.arrange(plot1(exp_1), plot3(exp_1), ncol = 2)
dev.off()

my_dev(file = "exp2-date-prehist", width = 1215, height = 350)
grid.arrange(plot2(exp_2), plot3(exp_2), ncol = 2)
dev.off()