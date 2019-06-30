library("ggplot2");
library("plyr");

a_df = a1_df
f_df = f1_df

count_title <- function(title, f_df) {
    return(paste(title, " ", "(n=", prettyNum(dim(f_df)[1], big.mark = ","), ")", sep = ""))
}

median_summary <- function(f_df) {
    v1 = data.frame(T = c(f_df$ONE_T, f_df$TWO_T), S = rep(factor(c("Game 1", "Game 2")), each = dim(f_df)[1]), I = factor(c(as.character(f_df$Input), as.character(f_df$Input))), R = factor(c(as.character(f_df$TWO_R), as.character(f_df$TWO_R)), levels = c("HH", "HL", "CT", "LH", "LL")));
    v2 = ddply(v1, .(I, S, R), summarize, med = median(T), avg = mean(T), var = var(T));

    return (v2)
}

ggplot(median_summary(f_df), aes(S, med, colour = R)) +
    geom_point(aes(shape = R), size = 3) +
    geom_line(aes(group = R)) +
    scale_shape_manual(values = c(17, 16, 8, 18, 15)) +    
    scale_color_grey() +
    labs(title = count_title("Median Game Touches", f_df), y = "Median Touches", x = "Game", shape = "Group", color = "Group");

ggplot(f_df, aes(x = TWO_R, y = TWO_T)) +
    geom_boxplot() +
    labs(x = "Group", y = "Touch Quartiles", title = count_title("Participant Count by Pre-Test Touches", f_df))


ggplot(a_df, aes(Input, ONE_T, colour = Input)) +
    geom_boxplot() +
    scale_color_grey() +
    theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
    labs(x = "Input Devices", y = "Game 1 Touches", title = count_title("Game 1 Touches By Input Device", f_df))

ggplot(f_df, aes(x = ONE_DT, fill = TWO_R)) +
    geom_histogram(bins = 60) +
    scale_fill_grey() +
    scale_x_datetime(date_breaks = "1 day", date_labels = "%b %d") +
    facet_grid(rows = vars(TWO_R)) +
    labs(x = "Date Time", y = "Participants", title = count_title("Participant Count by Date", f_df), fill = "Group")

ggplot(f_df, aes(x = ONE_T, fill = TWO_R)) +
    geom_bar() +
    geom_vline(aes(xintercept = median(ONE_T), col = TWO_R), size = 1, linetype = "dotted") +
    scale_fill_grey() +
    scale_color_grey(start = 0.05, end = 0.65) +
    facet_grid(rows = vars(TWO_R)) +
    labs(x = "Game 1 Touches", y = "Participants", title = count_title("Participant Count by Pre-Test Touches", f_df) , fill = "Group", color = "Median")

ggplot(f_df, aes(x = Age, fill = TWO_R)) +
    geom_bar() +
    scale_fill_grey() +
    facet_grid(rows = vars(TWO_R)) +
    labs(x = "Age", y = "Participants", title = count_title("Participant Count by Age", f_df), fill = "Group")

ggplot(f_df[f_df$Gender != "other",], aes(x = Gender, fill = TWO_R)) +
    geom_bar() +
    scale_fill_grey() +
    facet_grid(~TWO_R) +
    labs(x = "Gender", y = "Participants", title = count_title("Participant Count by Gender", f_df), fill = "Group")

ggplot(f_df[f_df$Area < 2500000,], aes(x = Area, fill = TWO_R)) +
    geom_histogram(bins = 60) +
    scale_fill_grey() +
    facet_grid(rows = vars(TWO_R)) +
    labs(x = expression(paste("Area (pixels" ^ "2", ")")), y = "Participants", title = count_title("Participant Count by Resolution", f_df), fill = "Group")

ggplot(f_df[f_df$Clean_Browser != "chrome mobile" & f_df$Clean_Browser != "firefox for ios" & f_df$Clean_Browser != "opera",], aes(x = Clean_Browser, fill = TWO_R)) +
    geom_bar() +
    scale_fill_grey() +
    facet_grid(rows = vars(TWO_R)) +
    labs(x = "Browser", y = "Participants", title = count_title("Participant Count by Browser", f_df), fill = "Group")

ggplot(f_df, aes(x = Clean_System, fill = TWO_R)) +
    geom_bar() +
    scale_fill_grey() +
    facet_grid(rows = vars(TWO_R)) +
    labs(x = "System", y = "Participants", title = count_title("Participant Count by System", f_df), fill = "Group")


ggplot(f_df, aes(TWO_R, ONE_T, color = Age)) + geom_boxplot()
ggplot(f_df, aes(Gender, ONE_T, color = TWO_R)) + geom_boxplot()

ggplot(f_df, aes(sample = (ONE_T))) + stat_qq() + stat_qq_line() + facet_grid(~TWO_R) + labs(title = count_title("Game 1 QQ-Plot Against Normal", f_df))
ggplot(f_df, aes(sample = (TWO_T))) + stat_qq() + stat_qq_line() + facet_grid(~TWO_R) + labs(title = count_title("Game 2 QQ-Plot Against Normal", f_df))