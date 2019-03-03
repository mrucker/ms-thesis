library("ggplot2");
library("plyr");
library("multcomp");
library("clinfun");
library("effsize");

studies_all = read.csv("../../../data/studies/_misc/studies1.csv", header = TRUE, sep = ",")

studies_all$TWO_R = revalue(studies_all$TWO_R, c("c4op" = "LL", "b4op" = "LH", "1" = "CT", "a3op" = "HL", "b3op"="HH"))
studies_all$TWO_R = factor(studies_all$TWO_R, levels = c("HH", "HL", "CT", "LH", "LL"))

f_df = studies_all[studies_all$First == "yes" & studies_all$Input == "mouse",]

v1 = data.frame(T = c(f_df$ONE_T, f_df$TWO_T), S = rep(factor(c("ONE", "TWO")), each = dim(f_df)[1]), I = factor(c(as.character(f_df$Input), as.character(f_df$Input))), R = factor(c(as.character(f_df$TWO_R), as.character(f_df$TWO_R)), levels = c("HH", "HL", "CT", "LH", "LL")));
v2 = ddply(v1, .(I, S, R), summarize, med = median(T), avg = mean(T), var = var(T));

ggplot(v2[v2$I == "mouse" | v2$I == "touchscreen" | v2$I == "touchpad",], aes(S, med, colour = R)) +
    geom_point(aes(shape = R), size = 3) +
    geom_line(aes(group = R)) +
    scale_shape_manual(values = c(17, 16, 8, 18, 15)) +
    facet_grid(~I) +
    scale_color_grey() +
    labs(title="Median Game Touches", legend="Reward", y="Game", x="median touches", shape="Reward", color="Reward");

par(mfrow = c(1, 3))
plot(TWO_R ~ Age, data = f_df, ylim = c(0, 90))
plot(TWO_T ~ TWO_R, data = f_df, ylim = c(0, 90))
plot(DIFF  ~ TWO_R, data = f_df)
par(mfrow = c(1, 1))

ggplot(studies_all, aes(First, DIFF, colour = First)) +
    geom_boxplot() +
    scale_color_grey() +
    theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
    labs(x = "First Time", y = "Game 2 Touches - Game 1 Touches", title = "Game 2 touches - Game 1 Touches (n=2,161)", colour = "First Time")

ggplot(studies_all[studies_all$Input == "mouse" | studies_all$Input == "touchpad" | studies_all$Input == "touchscreen",], aes(Input, DIFF, colour = Input)) +
    geom_boxplot() +
    scale_color_grey() +
    theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), legend.title = element_blank()) +
    labs(x = "Devices", y = "Game 2 Touches - Game 1 Touches", title = "Game 2 touches - Game 1 Touches (n=2,141)", colour = "")

ggplot(studies_all, aes(Input, ONE_T, colour = Input)) +
    geom_boxplot() +
    scale_color_grey() +
    theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
    labs(x = "Devices", y = "Game 1 Touches",  title = "Game 1 Touches By Device (n=2,161)", fill = "")

ggplot(f_df, aes(TWO_R, ONE_T, color = Age)) + geom_boxplot()
ggplot(f_df, aes(Gender, ONE_T, color = TWO_R)) + geom_boxplot()

ggplot(f_df, aes(sample = (ONE_T))) + stat_qq() + stat_qq_line() + facet_grid(~TWO_R) 
ggplot(f_df, aes(sample = (TWO_T))) + stat_qq() + stat_qq_line() + facet_grid(~TWO_R)

#the kruskal test shows that there is likely not a difference between test one groups
kruskal.test(ONE_T ~ TWO_R, data = f_df)
kruskal.test(TWO_T ~ TWO_R, data = f_df)

kruskal.test(ONE_T ~ TWO_R, data = f_df[f_df$TWO_R != "LL" & f_df$TWO_R != "LH",])
kruskal.test(ONE_T ~ TWO_R, data = f_df[f_df$TWO_R != "HH" & f_df$TWO_R != "HL",])

#wilkoxon test shows multiple significant differences
wh_ps = c(
      wilcox.test((f_df$TWO_T[f_df$TWO_R == "HH"]), (f_df$TWO_T[f_df$TWO_R == "CT"]), alternative = "greater", exact = FALSE, paired = FALSE)$p.value
    , wilcox.test((f_df$TWO_T[f_df$TWO_R == "HL"]), (f_df$TWO_T[f_df$TWO_R == "CT"]), alternative = "greater", exact = FALSE, paired = FALSE)$p.value
);

wl_ps = c(
      wilcox.test((f_df$TWO_T[f_df$TWO_R == "LH"]), (f_df$TWO_T[f_df$TWO_R == "CT"]), alternative = "less", exact = FALSE, paired = FALSE)$p.value
    , wilcox.test((f_df$TWO_T[f_df$TWO_R == "LL"]), (f_df$TWO_T[f_df$TWO_R == "CT"]), alternative = "less", exact = FALSE, paired = FALSE)$p.value
);

p.adjust(wh_ps, method = "holm", n = 2)
p.adjust(wl_ps, method = "holm", n = 2)

jonckheere.test(f_df$ONE_T, as.numeric(f_df$TWO_R), alternative = "decreasing")
cliff.delta(f_df[f_df$TWO_R == "LL","TWO_T"], f_df[f_df$TWO_R == "CT","TWO_T"])