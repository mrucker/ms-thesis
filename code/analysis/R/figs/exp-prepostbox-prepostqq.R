library("ggplot2");
library("gridExtra");

plot1 <- function(f_df) {
    v = rbind(setNames(cbind(f_df[, c("ONE_T", "TWO_R")], "Pretest"), c("touches", "reward", "test")), setNames(cbind(f_df[, c("TWO_T", "TWO_R")], "Posttest"), c("touches", "reward", "test")))

    labels = sapply(levels(v$reward), function(l) bquote(italic(R[.(l)])))

    return(
        ggplot(v, aes(x = reward, y = touches)) +
            my_theme() +
            geom_boxplot(aes(color = test, fill=test)) +
            scale_x_discrete(labels = labels) +
            labs(x = "Treatment", y = "Performance", color="", fill="")
    )
}

plot2 <- function(f_df) {

    v <- qq_dataframe_against_reward("CT", "TWO_T", f_df)
    v = v[seq(1, nrow(v), by = 2),]
    v$greater = factor(v$sample > v$theoretical, labels = c("Increase","Decrease"))

    return(
        ggplot(v) +
            my_theme() +
            geom_point(aes(x = theoretical, y = sample, color = v$greater), size=2, position=position_jitter(width=1)) +
            facet_grid(rows = vars(reward), labeller = label_bquote(rows=italic(R[.(as.character(reward))]))) +
            labs(x = "Posttest Control Performance Quantile", y = "Posttest Performance Qunatile", color = "Performance", shape="Performance")
    )
}

my_dev(file = "exp1-prepostbox-prepostqq", width = 1215, height = 475)
grid.arrange(plot1(exp_1), plot2(exp_1), ncol = 2)
dev.off()

my_dev(file = "exp2-prepostbox-prepostqq", width = 1215, height = 475)
grid.arrange(plot1(exp_2), plot2(exp_2), ncol = 2)
dev.off()