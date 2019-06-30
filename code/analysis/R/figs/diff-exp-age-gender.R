library("ggplot2");
library("gridExtra");

plot1 <- function(f_df) {
    return(
        ggplot(f_df, aes(x = Age)) +
            my_theme +
            geom_bar() +            
            facet_grid(rows = vars(TWO_R)) +
            labs(x = "Age", y = "Participants", title = count_title("Participant Count by Age", f_df), fill = "Group")
    )
}

plot2 <- function(f_df) {
    return(
        ggplot(f_df[f_df$Gender != "other",], aes(x = Gender)) +
            my_theme +
            geom_bar() +
            facet_grid(~TWO_R) +
            labs(x = "Gender", y = "Participants", title = count_title("Participant Count by Gender", f_df), fill = "Group")
    )
}

my_dev(file = "diff-exp1-age-gender", width = 1215, height = 475)
grid.arrange(plot1(f1_df), plot2(f1_df), ncol = 2)
dev.off()