library("multcomp")
library("clinfun")
library("effsize")

#the kruskal test shows that there is likely not a difference between test one groups

new_d1 = exp_1
new_d2 = exp_2

new_d1$exp = "1"
new_d2$exp = "2"

new_d = rbind(new_d1[c("ONE_T", "TWO_R", "TWO_T", "exp")],new_d2[c("ONE_T", "TWO_R", "TWO_T", "exp")])

ggplot(new_d, aes(TWO_R,ONE_T, fill=exp)) + geom_boxplot()
ggplot(new_d, aes(TWO_R,TWO_T, fill=exp)) + geom_boxplot()


kruskal.test(ONE_T ~ TWO_R, data = exp_1)

kruskal.test(ONE_T ~ TWO_R, data = exp_1)
kruskal.test(TWO_T ~ TWO_R, data = exp_1)

kruskal.test(TWO_T ~ TWO_R, data = exp_1[exp_1$TWO_R != "LL" & exp_1$TWO_R != "LH",])
kruskal.test(TWO_T ~ TWO_R, data = exp_1[exp_1$TWO_R != "HH" & exp_1$TWO_R != "HL",])

#wilkoxon test shows multiple significant differences
wh_ps = c(
      wilcox.test((exp_1$TWO_T[exp_1$TWO_R == "HH"]), (exp_1$TWO_T[exp_1$TWO_R == "CT"]), alternative = "greater", exact = FALSE, paired = FALSE)$p.value
    , wilcox.test((exp_1$TWO_T[exp_1$TWO_R == "HL"]), (exp_1$TWO_T[exp_1$TWO_R == "CT"]), alternative = "greater", exact = FALSE, paired = FALSE)$p.value
);

wl_ps = c(
      wilcox.test((exp_1$TWO_T[exp_1$TWO_R == "LH"]), (exp_1$TWO_T[exp_1$TWO_R == "CT"]), alternative = "less", exact = FALSE, paired = FALSE)$p.value
    , wilcox.test((exp_1$TWO_T[exp_1$TWO_R == "LL"]), (exp_1$TWO_T[exp_1$TWO_R == "CT"]), alternative = "less", exact = FALSE, paired = FALSE)$p.value
);

p.adjust(wh_ps, method = "holm", n = 2)
p.adjust(wl_ps, method = "holm", n = 2)

jonckheere.test(exp_1$TWO_T, as.numeric(exp_1$TWO_R), alternative = "decreasing")

treament_cliff(exp_1, "HH", "CT")
treament_cliff(exp_1, "HL", "CT")
treament_cliff(exp_1, "LH", "CT")
treament_cliff(exp_1, "LL", "CT")

n_mean_median_var(exp_1, "HH")
n_mean_median_var(exp_1, "HL")
n_mean_median_var(exp_1, "LH")
n_mean_median_var(exp_1, "LL")
n_mean_median_var(exp_1, "CT")

