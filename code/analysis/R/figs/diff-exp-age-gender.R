library("ggplot2");
library("gridExtra");

file1 = sprintf("%s/diff-exp1-age-gender.png", figs_path)

plot1 <- function(f_df) {
    return(
        ggplot(f_df, aes(x = Age)) +
            geom_bar() +
            scale_fill_grey() +
            facet_grid(rows = vars(TWO_R)) +
            labs(x = "Age", y = "Participants", title = count_title("Participant Count by Age", f_df), fill = "Group")
    )
}

plot2 <- function(f_df) {
    return(
        ggplot(f_df[f_df$Gender != "other",], aes(x = Gender)) +
            geom_bar() +
            scale_fill_grey() +
            facet_grid(~TWO_R) +
            labs(x = "Gender", y = "Participants", title = count_title("Participant Count by Gender", f_df), fill = "Group")
    )
}

png(file = file1, width = 1215, height = 475)
grid.arrange(plot1(f1_df), plot2(f1_df), ncol = 2)
dev.off()