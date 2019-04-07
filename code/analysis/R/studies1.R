library("ggplot2");
library("plyr");
library("multcomp");
library("clinfun");
library("effsize");

studies1_all = read.csv("../../../data/studies/_misc/studies1.csv", header = TRUE, sep = ",")

studies1_all$TWO_R  = revalue(studies1_all$TWO_R, c("c4op" = "LL", "b4op" = "LH", "1" = "CT", "a3op" = "HL", "b3op"="HH"))
studies1_all$TWO_R  = factor(studies1_all$TWO_R, levels = c("HH", "HL", "CT", "LH", "LL"))

studies1_all$ONE_DT = as.POSIXct(studies1_all$ONE_TS, tz = "", "%Y-%m-%dT%H:%M:%S")

studies1_all$Clean_System = as.character(studies1_all$Clean_System)
studies1_all$Clean_System[grepl("android", studies1_all$Clean_System)] = "android"
studies1_all$Clean_System[grepl("ios", studies1_all$Clean_System)] = "ios"
studies1_all$Clean_System[grepl("fedora", studies1_all$Clean_System)] = "linux"
studies1_all$Clean_System[grepl("linux", studies1_all$Clean_System)] = "linux"
studies1_all$Clean_System[grepl("ubuntu", studies1_all$Clean_System)] = "linux"
studies1_all$Clean_System[grepl("windows 8", studies1_all$Clean_System)] = "windows other"
studies1_all$Clean_System[grepl("windows server", studies1_all$Clean_System)] = "windows other"
studies1_all$Clean_System[grepl("windows xp", studies1_all$Clean_System)] = "windows other"
#studies1_all$Clean_System[grepl("ubuntu", studies1_all$Clean_System)] = "windows other"
studies1_all$Clean_System = factor(studies1_all$Clean_System)

f1_df = studies1_all[
    studies1_all$First == "yes" &
    studies1_all$Input == "mouse" &
    studies1_all$ONE_O >= 430 &
    studies1_all$TWO_O >= 430 &
    studies1_all$ONE_F >= 20  &
    studies1_all$TWO_F >= 20 
    ,]

v1 = data.frame(T = c(f1_df$ONE_T, f1_df$TWO_T), S = rep(factor(c("ONE", "TWO")), each = dim(f1_df)[1]), I = factor(c(as.character(f1_df$Input), as.character(f1_df$Input))), R = factor(c(as.character(f1_df$TWO_R), as.character(f1_df$TWO_R)), levels = c("HH", "HL", "CT", "LH", "LL")));
v2 = ddply(v1, .(I, S, R), summarize, med = median(T), avg = mean(T), var = var(T));

ggplot(v2[v2$I == "mouse" | v2$I == "touchscreen" | v2$I == "touchpad",], aes(S, med, colour = R)) +
    geom_point(aes(shape = R), size = 3) +
    geom_line(aes(group = R)) +
    scale_shape_manual(values = c(17, 16, 8, 18, 15)) +
    facet_grid(~I) +
    scale_color_grey() +
    labs(title="Median Game Touches", legend="Reward", y="Game", x="median touches", shape="Reward", color="Reward");

par(mfrow = c(1, 3))
plot(TWO_R ~ Age, data = f1_df, ylim = c(0, 90))
plot(TWO_T ~ TWO_R, data = f1_df, ylim = c(0, 90))
plot(DIFF  ~ TWO_R, data = f1_df)
par(mfrow = c(1, 1))

ggplot(studies1_all, aes(First, DIFF, colour = First)) +
    geom_boxplot() +
    scale_color_grey() +
    theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
    labs(x = "First Time", y = "Game 2 Touches - Game 1 Touches", title = "Game 2 touches - Game 1 Touches (n=2,161)", colour = "First Time")

ggplot(studies1_all[studies1_all$Input == "mouse" | studies1_all$Input == "touchpad" | studies1_all$Input == "touchscreen",], aes(Input, DIFF, colour = Input)) +
    geom_boxplot() +
    scale_color_grey() +
    theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), legend.title = element_blank()) +
    labs(x = "Devices", y = "Game 2 Touches - Game 1 Touches", title = "Game 2 touches - Game 1 Touches (n=2,141)", colour = "")

ggplot(studies1_all, aes(Input, ONE_T, colour = Input)) +
    geom_boxplot() +
    scale_color_grey() +
    theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
    labs(x = "Devices", y = "Game 1 Touches", title = "Game 1 Touches By Device (n=2,258)", fill = "")

ggplot(studies1_all, aes(x = ONE_DT, fill = TWO_R)) +
    geom_histogram(bins = 60) +
    scale_fill_grey() +
    scale_x_datetime(date_breaks = "1 day", date_labels = "%b %d")
labs(x = "Date Time", y = "Participants", title = "Participant Count by Date (n=2,258)", fill = "")

ggplot(f1_df, aes(x = ONE_DT)) +
    geom_histogram(bins = 60) +
    scale_fill_grey() +
    scale_x_datetime(date_breaks = "1 day", date_labels = "%b %d") +
    facet_grid(rows = vars(TWO_R)) +
    labs(x = "Date Time", y = "Participants", title = "Participant Count by Date (n=2,258)", fill = "")

ggplot(f1_df, aes(x = Age)) +
    geom_bar() +
    scale_fill_grey() +
    facet_grid(rows = vars(TWO_R)) +
    labs(x = "Age", y = "Participants", title = "Participant Count by Age (n=2,258)", fill = "")

ggplot(f1_df[f1_df$Gender != "other",], aes(x = Gender, fill = TWO_R)) +
    geom_bar() +
    scale_fill_grey() +
    facet_grid(~TWO_R) +
    labs(x = "Gender", y = "Participants", title = "Participant Count by Gender (n=2,258)", fill = "")

ggplot(f1_df[f1_df$Clean_Browser != "chrome mobile" & f1_df$Clean_Browser != "firefox for ios" & f1_df$Clean_Browser != "opera",], aes(x = Clean_Browser, fill = TWO_R)) +
    geom_bar() +
    scale_fill_grey() +
    facet_grid(rows = vars(TWO_R)) +
    labs(x = "Browser", y = "Participants", title = "Participant Count by Gender (n=2,258)", fill = "")

ggplot(f1_df, aes(x = Clean_System, fill = TWO_R)) +
    geom_bar() +
    scale_fill_grey() +
    facet_grid(rows = vars(TWO_R)) +
    labs(x = "System", y = "Participants", title = "Participant Count by Gender (n=2,258)", fill = "")

ggplot(f1_df[f1_df$Area < 3000000, ], aes(x = Area, fill = TWO_R)) +
    geom_histogram(bins = 60) +
    scale_fill_grey() +
    facet_grid(rows = vars(TWO_R)) +
    labs(x = "Area (pixels^2)", y = "Participants", title = "Participant Count by Gender (n=2,258)", fill = "")

ggplot(f1_df, aes(TWO_R, ONE_T, color = Age)) + geom_boxplot()
ggplot(f1_df, aes(Gender, ONE_T, color = TWO_R)) + geom_boxplot()

ggplot(f1_df, aes(sample = (ONE_T))) + stat_qq() + stat_qq_line() + facet_grid(~TWO_R) 
ggplot(f1_df, aes(sample = (TWO_T))) + stat_qq() + stat_qq_line() + facet_grid(~TWO_R)

#the kruskal test shows that there is likely not a difference between test one groups
kruskal.test(ONE_T ~ TWO_R, data = f1_df)
kruskal.test(TWO_T ~ TWO_R, data = f1_df)

kruskal.test(ONE_T ~ TWO_R, data = f1_df[f1_df$TWO_R != "LL" & f1_df$TWO_R != "LH",])
kruskal.test(ONE_T ~ TWO_R, data = f1_df[f1_df$TWO_R != "HH" & f1_df$TWO_R != "HL",])

#wilkoxon test shows multiple significant differences
wh_ps = c(
      wilcox.test((f1_df$TWO_T[f1_df$TWO_R == "HH"]), (f1_df$TWO_T[f1_df$TWO_R == "CT"]), alternative = "greater", exact = FALSE, paired = FALSE)$p.value
    , wilcox.test((f1_df$TWO_T[f1_df$TWO_R == "HL"]), (f1_df$TWO_T[f1_df$TWO_R == "CT"]), alternative = "greater", exact = FALSE, paired = FALSE)$p.value
);

wl_ps = c(
      wilcox.test((f1_df$TWO_T[f1_df$TWO_R == "LH"]), (f1_df$TWO_T[f1_df$TWO_R == "CT"]), alternative = "less", exact = FALSE, paired = FALSE)$p.value
    , wilcox.test((f1_df$TWO_T[f1_df$TWO_R == "LL"]), (f1_df$TWO_T[f1_df$TWO_R == "CT"]), alternative = "less", exact = FALSE, paired = FALSE)$p.value
);

p.adjust(wh_ps, method = "holm", n = 2)
p.adjust(wl_ps, method = "holm", n = 2)

jonckheere.test(f1_df$TWO_T, as.numeric(f1_df$TWO_R), alternative = "decreasing")

cliff.delta(f1_df$TWO_T[f1_df$TWO_R == "HH"], f1_df$TWO_T[f1_df$TWO_R == "CT"])
cliff.delta(f1_df$TWO_T[f1_df$TWO_R == "HL"], f1_df$TWO_T[f1_df$TWO_R == "CT"])
cliff.delta(f1_df$TWO_T[f1_df$TWO_R == "LH"], f1_df$TWO_T[f1_df$TWO_R == "CT"])
cliff.delta(f1_df$TWO_T[f1_df$TWO_R == "LL"], f1_df$TWO_T[f1_df$TWO_R == "CT"])