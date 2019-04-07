library("ggplot2");
library("plyr");
library("multcomp");
library("clinfun");
library("effsize");

studies2_all = read.csv("../../../data/studies/_misc/studies2.csv", header = TRUE, sep = ",")

studies2_all$TWO_R  = revalue(studies2_all$TWO_R, c("c4op" = "LL", "b4op" = "LH", "1" = "CT", "a3op" = "HL", "b3op" = "HH"))
studies2_all$TWO_R  = factor(studies2_all$TWO_R, levels = c("HH", "HL", "CT", "LH", "LL"))
studies2_all$ONE_DT = as.POSIXct(studies2_all$ONE_TS, tz = "", "%Y-%m-%dT%H:%M:%S")
studies2_all$Age    = factor(studies2_all$Age)
studies2_all$Gender = factor(studies2_all$Gender)

f2_df = studies2_all[
    studies2_all$First == "yes" &
    studies2_all$Input == "mouse" &
    studies2_all$ONE_O >= 430 &
    studies2_all$TWO_O >= 430 &
    studies2_all$ONE_F >= 20 &
    studies2_all$TWO_F >= 20
    ,]

v1 = data.frame(T = c(f2_df$ONE_T, f2_df$TWO_T), S = rep(factor(c("ONE", "TWO")), each = dim(f2_df)[1]), I = factor(c(as.character(f2_df$Input), as.character(f2_df$Input))), R = factor(c(as.character(f2_df$TWO_R), as.character(f2_df$TWO_R)), levels = c("HH", "HL", "CT", "LH", "LL")));
v2 = ddply(v1, .(I, S, R), summarize, med = median(T), avg = mean(T), var = var(T));

ggplot(v2[v2$I == "mouse" | v2$I == "touchscreen" | v2$I == "touchpad",], aes(S, med, colour = R)) +
    geom_point(aes(shape = R), size = 3) +
    geom_line(aes(group = R)) +
    scale_shape_manual(values = c(17, 16, 8, 18, 15)) +
    facet_grid(~I) +
    scale_color_grey() +
    labs(title = "Median Game Touches", legend = "Reward", y = "Game", x = "median touches", shape = "Reward", color = "Reward");

ggplot(studies2_all, aes(First, DIFF, colour = First)) +
    geom_boxplot() +
    scale_color_grey() +
    theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
    labs(x = "First Time", y = "Game 2 Touches - Game 1 Touches", title = "Game 2 touches - Game 1 Touches (n=2,161)", colour = "First Time")

ggplot(studies2_all[studies2_all$Input == "mouse" | studies2_all$Input == "touchpad" | studies2_all$Input == "touchscreen",], aes(Input, DIFF, colour = Input)) +
    geom_boxplot() +
    scale_color_grey() +
    theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), legend.title = element_blank()) +
    labs(x = "Devices", y = "Game 2 Touches - Game 1 Touches", title = "Game 2 touches - Game 1 Touches (n=2,141)", colour = "")

ggplot(studies2_all, aes(Input, ONE_T, colour = Input)) +
    geom_boxplot() +
    scale_color_grey() +
    theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
    labs(x = "Devices", y = "Game 1 Touches", title = "Game 1 Touches By Device (n=3,898)", fill = "")

ggplot(f2_df, aes(x = ONE_DT)) +
    geom_histogram(bins = 60) +
    scale_fill_grey() +
    scale_x_datetime(date_breaks = "1 day", date_labels = "%b %d") +
    facet_grid(rows = vars(TWO_R)) +
    labs(x = "Date Time", y = "Participants", title = "Participant Count by Date (n=2,258)", fill = "")

ggplot(f2_df, aes(x = Age)) +
    geom_bar() +
    scale_fill_grey() +
    facet_grid(rows = vars(TWO_R)) +
    labs(x = "Age", y = "Participants", title = "Participant Count by Age (n=2,258)", fill = "")

ggplot(f2_df[f2_df$Gender != "other",], aes(x = Gender, fill = TWO_R)) +
    geom_bar() +
    scale_fill_grey() +
    facet_grid(~TWO_R) +
    labs(x = "Gender", y = "Participants", title = "Participant Count by Gender (n=2,258)", fill = "")

ggplot(f2_df, aes(TWO_R, ONE_T, color = Age)) + geom_boxplot()

ggplot(data = f2_df) + geom_boxplot(aes(x = TWO_R, y = ONE_T, color = TWO_R))
ggplot(data = f2_df) + geom_boxplot(aes(x = TWO_R, y = TWO_T, color = TWO_R))
ggplot(data = f2_df) + geom_boxplot(aes(x = TWO_R, y = TWO_T-ONE_T, color = TWO_R))

ggplot(f2_df, aes(x = Gender)) + geom_bar() + facet_grid(~TWO_R)
ggplot(f2_df, aes(x = Age)) + geom_bar() + facet_grid(~TWO_R)
ggplot(f2_df, aes(x = Browser)) + geom_bar() + facet_grid(~TWO_R)

kruskal.test(ONE_T ~ TWO_R, data = f2_df)
kruskal.test(TWO_T ~ TWO_R, data = f2_df)

kruskal.test(ONE_T ~ TWO_R, data = f2_df[f2_df$TWO_R != "HH" & f2_df$TWO_R != "HL" & f2_df$TWO_R != "LH",])
kruskal.test(ONE_T ~ TWO_R, data = f2_df[f2_df$TWO_R != "LL",])

ggplot(f2_df, aes(sample = (ONE_T))) + stat_qq() + stat_qq_line() + facet_grid(~TWO_R)
ggplot(f2_df, aes(sample = (TWO_T))) + stat_qq() + stat_qq_line() + facet_grid(~TWO_R)

median(f2_df$ONE_T[f2_df$TWO_R == "HH"])
median(f2_df$ONE_T[f2_df$TWO_R == "LH"])
median(f2_df$ONE_T[f2_df$TWO_R == "CT"])

wilcox.test(f2_df$ONE_T[f2_df$TWO_R == "HH"], f2_df$TWO_T[f2_df$TWO_R == "HH"], alternative = "two.sided", exact = FALSE, paired = TRUE)$p.value
wilcox.test(f2_df$ONE_T[f2_df$TWO_R == "HL"], f2_df$TWO_T[f2_df$TWO_R == "HL"], alternative = "two.sided", exact = FALSE, paired = TRUE)$p.value
wilcox.test(f2_df$ONE_T[f2_df$TWO_R == "LH"], f2_df$TWO_T[f2_df$TWO_R == "LH"], alternative = "two.sided", exact = FALSE, paired = TRUE)$p.value
wilcox.test(f2_df$ONE_T[f2_df$TWO_R == "CT"], f2_df$TWO_T[f2_df$TWO_R == "CT"], alternative = "two.sided", exact = FALSE, paired = TRUE)$p.value
wilcox.test(f2_df$ONE_T[f2_df$TWO_R == "LL"], f2_df$TWO_T[f2_df$TWO_R == "LL"], alternative = "two.sided", exact = FALSE, paired = TRUE)$p.value

wilcox.test(f2_df$ONE_T[f2_df$TWO_R == "HH"], f2_df$ONE_T[f2_df$TWO_R == "CT"], alternative = "two.sided", exact = FALSE, paired = FALSE)$p.value
wilcox.test(f2_df$ONE_T[f2_df$TWO_R == "HL"], f2_df$ONE_T[f2_df$TWO_R == "CT"], alternative = "two.sided", exact = FALSE, paired = FALSE)$p.value
wilcox.test(f2_df$ONE_T[f2_df$TWO_R == "LH"], f2_df$ONE_T[f2_df$TWO_R == "CT"], alternative = "two.sided", exact = FALSE, paired = FALSE)$p.value
wilcox.test(f2_df$ONE_T[f2_df$TWO_R == "LL"], f2_df$ONE_T[f2_df$TWO_R == "CT"], alternative = "two.sided", exact = FALSE, paired = FALSE)$p.value

wilcox.test((f2_df$TWO_T[f2_df$TWO_R == "HH"]), (f2_df$TWO_T[f2_df$TWO_R == "CT"]), alternative = "greater", exact = FALSE, paired = FALSE)$p.value
wilcox.test((f2_df$TWO_T[f2_df$TWO_R == "HL"]), (f2_df$TWO_T[f2_df$TWO_R == "CT"]), alternative = "greater", exact = FALSE, paired = FALSE)$p.value
wilcox.test((f2_df$TWO_T[f2_df$TWO_R == "LH"]), (f2_df$TWO_T[f2_df$TWO_R == "CT"]), alternative = "greater", exact = FALSE, paired = FALSE)$p.value
wilcox.test((f2_df$TWO_T[f2_df$TWO_R == "LL"]), (f2_df$TWO_T[f2_df$TWO_R == "CT"]), alternative = "less"   , exact = FALSE, paired = FALSE)$p.value

wilcox.test((f2_df$TWO_T[f2_df$TWO_R == "HH" | f2_df$TWO_R == "LH" | f2_df$TWO_R == "HL"]), (f2_df$TWO_T[f2_df$TWO_R == "CT"]), alternative = "greater", exact = FALSE, paired = FALSE)$p.value

jonckheere.test(f2_df$ONE_T, as.numeric(f2_df$TWO_R), alternative = "decreasing")

cliff.delta(f2_df$TWO_T[f2_df$TWO_R == "HH"], f2_df$TWO_T[f2_df$TWO_R == "CT"])
cliff.delta(f2_df$TWO_T[f2_df$TWO_R == "HL"], f2_df$TWO_T[f2_df$TWO_R == "CT"])
cliff.delta(f2_df$TWO_T[f2_df$TWO_R == "LH"], f2_df$TWO_T[f2_df$TWO_R == "CT"])
cliff.delta(f2_df$TWO_T[f2_df$TWO_R == "LL"], f2_df$TWO_T[f2_df$TWO_R == "CT"])