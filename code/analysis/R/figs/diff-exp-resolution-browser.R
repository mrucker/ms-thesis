library("ggplot2");
library("gridExtra");

file1 = sprintf("%s/diff-exp1-resolution-browser.png", figs_path)

plot1 <- function(f_df) {
    return(
        ggplot(f_df[f_df$Area < 2500000,], aes(x = Area)) +
            geom_histogram(bins = 60) +
            scale_fill_grey() +
            facet_grid(rows = vars(TWO_R)) +
            labs(x = expression(paste("Area (pixels" ^ "2", ")")), y = "Participants", title = count_title("Participant Count by Resolution", f_df), fill = "Group")
    )
}

plot2 <- function(f_df) {
    return(
        ggplot(f_df[f_df$Clean_Browser != "chrome mobile" & f_df$Clean_Browser != "firefox for ios" & f_df$Clean_Browser != "opera",], aes(x = Clean_Browser)) +
            geom_bar() +
            scale_fill_grey() +
            facet_grid(rows = vars(TWO_R)) +
            labs(x = "Browser", y = "Participants", title = count_title("Participant Count by Browser", f_df), fill = "Group")
    )
}

png(file = file1, width = 1215, height = 475)
grid.arrange(plot1(f1_df), plot2(f1_df), ncol = 2)
dev.off()