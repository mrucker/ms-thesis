library("ggplot2");
library("plyr");
library("multcomp");
library("clinfun");

studies_all        = read.csv("../../../data/studies/_misc/studies2.csv", header = TRUE, sep = ",")

studies_all$Reward = studies_all$TWO_R

studies_all$Reward = revalue(studies_all$Reward, c("c4op" = "LL", "b4op" = "LH", "1" = "CT", "a3op" = "HL", "b3op"="HH"))
studies_all$Reward = factor(studies_all$Reward, levels = c("LL", "LH", "CT", "HL", "HH"))

#f_df = studies_all[studies_all$First == "yes",]
f_df = studies_all[studies_all$First == "yes" & studies_all$Input == "mouse",]

v1 = data.frame(T = c(f_df$ONE_T, f_df$TWO_T), S = rep(factor(c("ONE", "TWO")), each = dim(f_df)[1]), I = factor(c(as.character(f_df$Input), as.character(f_df$Input))), R = factor(c(as.character(f_df$Reward), as.character(f_df$Reward)), levels = c('LL', 'LH', 'CT', 'HL', 'HH')));
v2 = ddply(v1, .(I, S, R), summarize, med = median(T), avg = mean(T), var = var(T));

ggplot(v2[v2$I == "mouse" | v2$I == "touchscreen" | v2$I == "touchpad",], aes(S, med, colour = R)) +
    geom_point(aes(shape = R), size = 3) +
    geom_line(aes(group = R)) +
    scale_shape_manual(values = c(17, 16, 8, 18, 15)) +
    facet_grid(~I) +
    scale_color_grey() +
    labs(title="Median Game Touches", legend="Reward", y="Game", x="median touches", shape="Reward", color="Reward");

v3 = data.frame(T = c(f_df$ONE_T, f_df$TWO_T), S = rep(factor(c("ONE", "TWO")), each = dim(f_df)[1]), G = factor(c(as.character(f_df$Study), as.character(f_df$Study)), levels = c('c45a', 'c45b', 'c45c', 'c45d', 'c45e', 'c45f', 'c45g', 'c45h', 'c45i')), R = factor(c(as.character(f_df$Reward), as.character(f_df$Reward)), levels = c('LL', 'LH', 'CT', 'HL', 'HH')))
v4 = ddply(v3, .(S, G), summarize, med = median(T), avg = mean(T), Ru = unique(R))

ggplot(v4, aes(S, med, colour = Ru)) + geom_point() + geom_line(aes(group = G))

par(mfrow = c(1, 3))
plot(ONE_T ~ Reward, data = f_df, ylim = c(0, 90))
plot(TWO_T ~ Reward, data = f_df, ylim = c(0, 90))
plot(DIFF  ~ Reward, data = f_df)
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

ggplot(studies_1st[studies_1st$Input == "touchpad" ,], aes(Input, DIFF, colour = Reward)) +
    geom_boxplot() +
    #theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), legend.title = element_blank()) +
    labs(x = "Devices", y = "Game 2 Touches - Game 1 Touches", title = "Game 2 touches - Game 1 Touches (n=2,141)", colour = "")

ggplot(studies_all, aes(Input, ONE_T, colour = Input)) +
    geom_boxplot() +
    scale_color_grey() +
    theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
    labs(x = "Devices", y = "Game 1 Touches",  title = "Game 1 Touches By Device (n=2,161)", fill = "")

mean(f_df$DIFF[f_df$Reward == "HH"])
sd(f_df$DIFF[f_df$Reward == "LL"])

ggplot(f_df, aes(sample = (ONE_T))) + stat_qq() + stat_qq_line() + facet_grid(~Reward) 
ggplot(f_df, aes(sample = (TWO_T))) + stat_qq() + stat_qq_line() + facet_grid(~Reward)

qqnorm(f_df$TWO_T)

#the kruskal test shows that there is likely not a difference between test one groups
summary(aov((ONE_T) ~ Reward, data = f_df[f_df$Reward != "LL" & f_df$Reward != "LH",]))
summary(aov((ONE_T) ~ Reward, data = f_df[f_df$Reward != "HH" & f_df$Reward != "HL",]))

summary(aov(sqrt(TWO_T) ~ Reward, data = f_df[f_df$Reward != "LL" & f_df$Reward != "LH",]))
summary(aov(sqrt(TWO_T) ~ Reward, data = f_df[f_df$Reward != "HH" & f_df$Reward != "HL",]))

summary(aov((TWO_T) ~ Reward, data = f_df[f_df$Reward == "HH" | f_df$Reward == "LL",]))

kruskal.test(ONE_T ~ Reward, data = f_df[f_df$Reward != "LL" & f_df$Reward != "LH",])
kruskal.test(ONE_T ~ Reward, data = f_df[f_df$Reward != "HH" & f_df$Reward != "HL",])

kruskal.test(ONE_T ~ Reward, data = f_df[f_df$Reward == "HH" | f_df$Reward == "LL",])

kruskal.test(TWO_T ~ Reward, data = f_df[f_df$Reward != "LL" & f_df$Reward != "LH",])
kruskal.test(TWO_T ~ Reward, data = f_df[f_df$Reward != "HH" & f_df$Reward != "HL",])

kruskal.test(TWO_T ~ Reward, data = f_df[f_df$Reward == "HH" | f_df$Reward == "CT",])
kruskal.test(ONE_T ~ Reward, data = f_df[f_df$Reward == "HH" | f_df$Reward == "CT",])
kruskal.test(ONE_T ~ Reward, data = f_df[f_df$Reward == "LL" | f_df$Reward == "CT",])

kruskal.test(ONE_T ~ Reward, data = f_df)
kruskal.test(TWO_T ~ Reward, data = f_df)

wilcox.test((f_df$ONE_T[f_df$Reward == "LL"]), (f_df$ONE_T[f_df$Reward == "LH"]), alternative = "less", exact = FALSE)$p.value
wilcox.test((f_df$TWO_T[f_df$Reward == "LL"]), (f_df$TWO_T[f_df$Reward == "LH"]), alternative = "less", exact = FALSE)$p.value

anova(aov(ONE_T ~ Reward, dat = f_df))
anova(aov(TWO_T ~ Reward, dat = f_df))

wilcox.test((f_df$ONE_T[f_df$Reward == "LL"]), (f_df$ONE_T[f_df$Reward == "LH"]), alternative = "less", exact = FALSE)$p.value
wilcox.test((f_df$TWO_T[f_df$Reward == "LL"]), (f_df$TWO_T[f_df$Reward == "LH"]), alternative = "less"   , exact = FALSE)$p.value
wilcox.test((f_df$TWO_T[f_df$Reward == "CT"]), (f_df$TWO_T[f_df$Reward == "LL"]), alternative = "greater", exact = FALSE)$p.value

#wilkoxon test shows multiple significant differences
w0_ps = c(
    kruskal.test(ONE_T ~ Reward, data = f_df)$p.value
);

w1_ps = c(
      wilcox.test((f_df$TWO_T[f_df$Reward == "CT"]), (f_df$TWO_T[f_df$Reward == "LL"]), alternative = "greater", exact = FALSE)$p.value
    , wilcox.test((f_df$TWO_T[f_df$Reward == "CT"]), (f_df$TWO_T[f_df$Reward == "LH"]), alternative = "greater", exact = FALSE)$p.value
);

w2_ps = c(
      wilcox.test((f_df$TWO_T[f_df$Reward == "CT"]), (f_df$TWO_T[f_df$Reward == "HL"]), alternative = "less", exact = FALSE)$p.value
    , wilcox.test((f_df$TWO_T[f_df$Reward == "CT"]), (f_df$TWO_T[f_df$Reward == "HH"]), alternative = "less", exact = FALSE)$p.value
);


p.adjust(w0_ps, method = "holm", n = 1)
p.adjust(w1_ps, method = "holm", n = 2)
p.adjust(w2_ps, method = "holm", n = 2)

kruskal.test(ONE_T ~ Reward, data = f_df)$p.value
jonckheere.test(f_df$TWO_T, as.numeric(f_df$Reward), alternative = "increasing")
p.adjust(w1_ps, method = "holm", n = 2)

as.numeric(f_df$Reward)
wilcox.test(ONE_T ~ Reward, data = f_df[f_df$Reward == "CT" | f_df$Reward == "HH",])

kruskal.test(ONE_T ~ Reward, data = f_df[f_df$Reward == "CT" | f_df$Reward == "HH",])
kruskal.test(ONE_T ~ Reward, data = f_df)

help(p.adjust)

tky = as.data.frame(TukeyHSD(aov(sqrt(TWO_T) ~ Reward, data = f_df))$Reward)
tky$pair = rownames(tky)

# Plot pairwise TukeyHSD comparisons and color by significance level
ggplot(tky, aes(colour = cut(`p adj`, c(0, 0.01, 0.05, 1),
                           label = c("p<0.01", "p<0.05", "Non-Sig")))) +
                           geom_hline(yintercept = 0, lty = "11", colour = "grey30") +
                           geom_errorbar(aes(pair, ymin = lwr, ymax = upr), width = 0.2) +
                           geom_point(aes(pair, diff)) +
                           labs(colour = "")



w3_ps = c(
      wilcox.test((f_df$TWO_T[f_df$Reward == "CT"]), (f_df$TWO_T[f_df$Reward == "LL"]), alternative = "greater", conf.int = TRUE)$p.value
    , wilcox.test((f_df$TWO_T[f_df$Reward == "CT"]), (f_df$TWO_T[f_df$Reward == "LH"]), alternative = "greater", conf.int = TRUE)$p.value
    , wilcox.test((f_df$TWO_T[f_df$Reward == "CT"]), (f_df$TWO_T[f_df$Reward == "HL"]), alternative = "less", conf.int = TRUE)$p.value
    , wilcox.test((f_df$TWO_T[f_df$Reward == "CT"]), (f_df$TWO_T[f_df$Reward == "HH"]), alternative = "less", conf.int = TRUE)$p.value
    , wilcox.test((f_df$TWO_T[f_df$Reward == "HL"]), (f_df$TWO_T[f_df$Reward == "HH"]), alternative = "two.sided", conf.int=TRUE)$p.value
    , wilcox.test((f_df$TWO_T[f_df$Reward == "HL"]), (f_df$TWO_T[f_df$Reward == "LH"]), alternative = "greater"  , conf.int=TRUE)$p.value
    , wilcox.test((f_df$TWO_T[f_df$Reward == "HL"]), (f_df$TWO_T[f_df$Reward == "LL"]), alternative = "greater"  , conf.int=TRUE)$p.value
    , wilcox.test((f_df$TWO_T[f_df$Reward == "HH"]), (f_df$TWO_T[f_df$Reward == "LH"]), alternative = "greater"  , conf.int=TRUE)$p.value
    , wilcox.test((f_df$TWO_T[f_df$Reward == "HH"]), (f_df$TWO_T[f_df$Reward == "LL"]), alternative = "greater"  , conf.int=TRUE)$p.value
    , wilcox.test((f_df$TWO_T[f_df$Reward == "LH"]), (f_df$TWO_T[f_df$Reward == "LL"]), alternative = "greater"  , conf.int=TRUE)$p.value
);

p.adjust(w3_ps, method = "BH", n = length(w3_ps))

cliff.delta(f_df[f_df$Reward == "LL", "TWO_T"], f_df[f_df$Reward == "CT", "TWO_T"])