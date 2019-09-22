library("multcomp");
library("clinfun");
library("effsize");

#the kruskal test shows that there is likely not a difference between test one groups
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

cliff.delta(exp_1$TWO_T[exp_1$TWO_R == "HH"], exp_1$TWO_T[exp_1$TWO_R == "CT"])$estimate
cliff.delta(exp_1$TWO_T[exp_1$TWO_R == "HL"], exp_1$TWO_T[exp_1$TWO_R == "CT"])$estimate
cliff.delta(exp_1$TWO_T[exp_1$TWO_R == "LH"], exp_1$TWO_T[exp_1$TWO_R == "CT"])$estimate
cliff.delta(exp_1$TWO_T[exp_1$TWO_R == "LL"], exp_1$TWO_T[exp_1$TWO_R == "CT"])$estimate