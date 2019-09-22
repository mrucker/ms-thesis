library("ggplot2");
library("gridExtra");

plot1 <- function(f_df) {
    v = rbind(setNames(cbind(f_df[, c("ONE_T", "TWO_R")], "Pre-test"), c("touches", "reward", "test")), setNames(cbind(f_df[, c("TWO_T", "TWO_R")], "Post-test"), c("touches", "reward", "test")))

    labels = sapply(levels(v$reward), function(l) bquote(italic(R[.(l)])))

    return(
        ggplot(v, aes(x = reward, y = touches)) +
            my_theme() +
            geom_boxplot(aes(color = test)) +
            scale_x_discrete(labels = labels) +
            labs(x = "Treatment", y = "Touches", title = count_title("Distribution of Touches by Treatment", f_df))
    )
}

plot2 <- function(f_df) {

    v <- qq_dataframe_against_reward("CT", "TWO_T", f_df)
    v = v[seq(1, nrow(v), by = 5),]
    v$greater = factor(v$sample > v$theoretical, labels = c("Treatment > Control","Treatment < Control"))

    return(
        ggplot(v) +
            my_theme() +
            geom_point(aes(x = theoretical, y = sample, color = v$greater)) +
            #geom_abline(intercept = 0, slope = 1) +
            facet_grid(rows = vars(reward), labeller = label_bquote(rows=italic(R[.(as.character(reward))]))) +
            labs(x = "Control Quantiles", y = "Treatment Quantiles", title = count_title("Q\u2013Q of Treatments vs Control in Post-Test", f_df), color = "", shape="")
    )
}

my_dev(file = "exp1-prepostbox-prepostqq", width = 1215, height = 475)
grid.arrange(plot1(f1_df), plot2(f1_df), ncol = 2)
dev.off()

my_dev(file = "exp2-prepostbox-prepostqq", width = 1215, height = 475)
grid.arrange(plot1(f2_df), plot2(f2_df), ncol = 2)
dev.off()