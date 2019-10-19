library("ggplot2");
library("gridExtra");

plot1 <- function(f_df) {
    
    x_scale=500000
    
    return(
        ggplot(f_df[f_df$Area < 2500000,], aes(x = Area)) +
            my_theme() +
            geom_histogram(bins = 60) +
            scale_y_continuous(breaks=c(0,25,50)) +
            scale_x_continuous(breaks=c(1*x_scale,2*x_scale,3*x_scale,4*x_scale), labels = scales::scientific) +
            facet_grid(rows = vars(TWO_R), labeller = label_bquote(rows = italic(R[.(as.character(TWO_R))]))) +
            labs(x = expression(paste("Playing Field Area (px" ^ "2", ")")), y = "Participant Count")
    )
}

plot2 <- function(f_df) {
    
    f_df = f_df[f_df$Clean_Browser != "chrome mobile" & f_df$Clean_Browser != "firefox for ios" & f_df$Clean_Browser != "opera",]
    
    f_df$Clean_Browser = gsub("chrome", "Chrome", f_df$Clean_Browser)
    f_df$Clean_Browser = gsub("safari", "Safari", f_df$Clean_Browser)
    f_df$Clean_Browser = gsub("firefox", "Firefox", f_df$Clean_Browser)
    f_df$Clean_Browser = gsub("ie", "IE", f_df$Clean_Browser)
    f_df$Clean_Browser = gsub("microsoft edge", "Edge", f_df$Clean_Browser)
    
    return(
        ggplot(f_df, aes(x = Clean_Browser)) +
            my_theme() +
            geom_bar() +
            scale_y_continuous(breaks=c(0,100,200)) +
            facet_grid(rows = vars(TWO_R), labeller = label_bquote(rows = italic(R[.(as.character(TWO_R))]))) +
            labs(x = "Web Browser", y = "Participant Count")
    )
}

my_dev(file = "exp1-resolution-browser", width = 1215, height = 350)
grid.arrange(plot1(exp_1), plot2(exp_1), ncol = 2)
dev.off()