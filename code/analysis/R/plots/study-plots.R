library("ggplot2");
library("plyr");

exp_n = exp_1

ggplot(median_summary(exp_n), aes(S, med, colour = R)) +
    geom_point(aes(shape = R), size = 3) +
    geom_line(aes(group = R)) +
    scale_shape_manual(values = c(17, 16, 8, 18, 15)) +    
    scale_color_grey() +
    labs(title = count_title("Median Game Touches", exp_n), y = "Median Touches", x = "Game", shape = "Group", color = "Group");

ggplot(exp_n, aes(x = TWO_R, y = TWO_T)) +
    geom_boxplot() +
    labs(x = "Group", y = "Touch Quartiles", title = count_title("Participant Count by Pre-Test Touches", exp_n))

ggplot(exp_n, aes(x = ONE_DT, fill = TWO_R)) +
    geom_histogram(bins = 60) +
    scale_fill_grey() +
    scale_x_datetime(date_breaks = "1 day", date_labels = "%b %d") +
    facet_grid(rows = vars(TWO_R)) +
    labs(x = "Date Time", y = "Participants", title = count_title("Participant Count by Date", exp_n), fill = "Group")

ggplot(exp_n, aes(x = ONE_T, fill = TWO_R)) +
    geom_bar() +
    geom_vline(aes(xintercept = median(ONE_T), col = TWO_R), size = 1, linetype = "dotted") +
    scale_fill_grey() +
    scale_color_grey(start = 0.05, end = 0.65) +
    facet_grid(rows = vars(TWO_R)) +
    labs(x = "Game 1 Touches", y = "Participants", title = count_title("Participant Count by Pre-Test Touches", exp_n) , fill = "Group", color = "Median")

ggplot(exp_n, aes(x = Age, fill = TWO_R)) +
    geom_bar() +
    scale_fill_grey() +
    facet_grid(rows = vars(TWO_R)) +
    labs(x = "Age", y = "Participants", title = count_title("Participant Count by Age", exp_n), fill = "Group")

ggplot(exp_n[exp_n$Gender != "other",], aes(x = Gender, fill = TWO_R)) +
    geom_bar() +
    scale_fill_grey() +
    facet_grid(~TWO_R) +
    labs(x = "Gender", y = "Participants", title = count_title("Participant Count by Gender", exp_n), fill = "Group")

ggplot(exp_n[exp_n$Area < 2500000,], aes(x = Area, fill = TWO_R)) +
    geom_histogram(bins = 60) +
    scale_fill_grey() +
    facet_grid(rows = vars(TWO_R)) +
    labs(x = expression(paste("Area (pixels" ^ "2", ")")), y = "Participants", title = count_title("Participant Count by Resolution", exp_n), fill = "Group")

ggplot(exp_n[exp_n$Clean_Browser != "chrome mobile" & exp_n$Clean_Browser != "firefox for ios" & exp_n$Clean_Browser != "opera",], aes(x = Clean_Browser, fill = TWO_R)) +
    geom_bar() +
    scale_fill_grey() +
    facet_grid(rows = vars(TWO_R)) +
    labs(x = "Browser", y = "Participants", title = count_title("Participant Count by Browser", exp_n), fill = "Group")

ggplot(exp_n, aes(x = Clean_System, fill = TWO_R)) +
    geom_bar() +
    scale_fill_grey() +
    facet_grid(rows = vars(TWO_R)) +
    labs(x = "System", y = "Participants", title = count_title("Participant Count by System", exp_n), fill = "Group")


ggplot(exp_n, aes(TWO_R, ONE_T, color = Age)) + geom_boxplot()
ggplot(exp_n, aes(Gender, ONE_T, color = TWO_R)) + geom_boxplot()

ggplot(exp_n, aes(sample = (ONE_T))) + stat_qq() + stat_qq_line() + facet_grid(~TWO_R) + labs(title = count_title("Game 1 QQ-Plot Against Normal", exp_n))
ggplot(exp_n, aes(sample = (TWO_T))) + stat_qq() + stat_qq_line() + facet_grid(~TWO_R) + labs(title = count_title("Game 2 QQ-Plot Against Normal", exp_n))

v = rbind(setNames(cbind(exp_n[, c("ONE_T", "TWO_R")], "Pre-test"), c("Touches", "Reward", "Test")), setNames(cbind(exp_n[, c("TWO_T", "TWO_R")], "Post-test"), c("Touches", "Reward", "Test")))
ggplot(v, aes(x = Reward, y = Touches)) +
    geom_boxplot(aes(fill = Test)) +
    labs(x = "Reward", y = "Touches", title = count_title("Distribution of Touches by Treatment", exp_n))

v = rbind(setNames(cbind(exp_n[, c("ONE_T", "TWO_R")], "Pre-test"), c("Touches", "Reward", "Test")), setNames(cbind(exp_n[, c("TWO_T", "TWO_R")], "Post-test"), c("Touches", "Reward", "Test")))
ggplot(v, aes(x = Touches, color = Test, fill = Test)) +
    geom_density(alpha = .25) +
    facet_grid(rows = vars(Reward)) +
    labs(x = "Touches", y = "Density", title = count_title("Distribution of Touches by Test", exp_n))

v <- qq_dataframe_against_reward("CT", "TWO_T", exp_n)
ggplot(v) +
    geom_point(aes(x = theoretical, y = sample, color = sample > theoretical)) +
    geom_abline(intercept = 0, slope = 1) +
    facet_grid(rows = vars(reward))
