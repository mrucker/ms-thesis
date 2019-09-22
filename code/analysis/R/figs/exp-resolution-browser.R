library("ggplot2");
library("gridExtra");

plot1 <- function(f_df) {
    return(
        ggplot(f_df[f_df$Area < 2500000,], aes(x = Area)) +
            my_theme() +
            geom_histogram(bins = 60) +
            facet_grid(rows = vars(TWO_R), labeller = label_bquote(rows = italic(R[.(as.character(TWO_R))]))) +
            labs(x = expression(paste("Area (pixels" ^ "2", ")")), y = "Participants", title = count_title("Participant Count by Screen Resolution", f_df), fill = "Group")
    )
}

plot2 <- function(f_df) {
    return(
        ggplot(f_df[f_df$Clean_Browser != "chrome mobile" & f_df$Clean_Browser != "firefox for ios" & f_df$Clean_Browser != "opera",], aes(x = Clean_Browser)) +
            my_theme() +
            geom_bar() +
            facet_grid(rows = vars(TWO_R), labeller = label_bquote(rows = italic(R[.(as.character(TWO_R))]))) +
            labs(x = "Browser", y = "Participants", title = count_title("Participant Count by Web Browser", f_df), fill = "Group")
    )
}

my_dev(file = "exp1-resolution-browser", width = 1215, height = 475)
grid.arrange(plot1(exp_1), plot2(exp_1), ncol = 2)
dev.off()