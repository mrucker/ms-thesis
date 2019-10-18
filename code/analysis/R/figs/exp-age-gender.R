library("ggplot2");
library("gridExtra");

plot1 <- function(f_df) {
    
    f_df$Age = gsub(" years old", "", f_df$Age)

    return(
        ggplot(f_df, aes(x = Age)) +
            my_theme() +
            geom_bar() +
            facet_grid(rows = vars(TWO_R), labeller = label_bquote(rows = italic(R[.(as.character(TWO_R))]))) +
            labs(x = "Age", y = "Participant Count")
    )
}

plot2 <- function(f_df) {
    
    f_df$Gender = gsub("^male"  , "M", f_df$Gender)
    f_df$Gender = gsub("^female", "F", f_df$Gender)
    
    return(
        ggplot(f_df[f_df$Gender != "other",], aes(x = Gender)) +
            my_theme() +
            geom_bar() +
            facet_grid(cols = vars(TWO_R), labeller = label_bquote(cols = italic(R[.(as.character(TWO_R))]))) +
            labs(x = "Gender", y = "Participant Count")
    )
}

my_dev(file = "exp1-age-gender", width = 1215, height = 350)
grid.arrange(plot1(exp_1), plot2(exp_1), ncol = 2)
dev.off()