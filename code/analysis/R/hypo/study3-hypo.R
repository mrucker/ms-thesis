library("multcomp");
library("clinfun");
library("effsize");

kruskal.test(ONE_T ~ TWO_R, data = exp_3)
kruskal.test(TWO_T ~ TWO_R, data = exp_3)

wilcox.test((exp_3$ONE_T[exp_3$TWO_R == "HH" | exp_3$TWO_R == "HL" | exp_3$TWO_R == "LH"]), (exp_3$ONE_T[exp_3$TWO_R == "CT"]), alternative = "two.sided", exact = FALSE, paired = FALSE)$p.value
wilcox.test((exp_3$TWO_T[exp_3$TWO_R == "HH" | exp_3$TWO_R == "HL" | exp_3$TWO_R == "LH"]), (exp_3$TWO_T[exp_3$TWO_R == "CT"]), alternative = "greater"  , exact = FALSE, paired = FALSE)$p.value

wilcox.test((exp_3$TWO_T[exp_3$TWO_R == "HH"]), (exp_3$TWO_T[exp_3$TWO_R == "CT"]), alternative = "greater", exact = FALSE, paired = FALSE)$p.value
wilcox.test((exp_3$TWO_T[exp_3$TWO_R == "HL"]), (exp_3$TWO_T[exp_3$TWO_R == "CT"]), alternative = "greater", exact = FALSE, paired = FALSE)$p.value
wilcox.test((exp_3$TWO_T[exp_3$TWO_R == "LH"]), (exp_3$TWO_T[exp_3$TWO_R == "CT"]), alternative = "greater", exact = FALSE, paired = FALSE)$p.value
wilcox.test((exp_3$TWO_T[exp_3$TWO_R == "LL"]), (exp_3$TWO_T[exp_3$TWO_R == "CT"]), alternative = "less"   , exact = FALSE, paired = FALSE)$p.value

jonckheere.test(exp_3$ONE_T, as.numeric(exp_3$TWO_R), alternative = "decreasing")

cliff.delta(exp_3[exp_3$TWO_R == "HH", "TWO_T"], exp_3[exp_3$TWO_R == "CT", "TWO_T"])
cliff.delta(exp_3[exp_3$TWO_R == "HL", "TWO_T"], exp_3[exp_3$TWO_R == "CT", "TWO_T"])
cliff.delta(exp_3[exp_3$TWO_R == "LH", "TWO_T"], exp_3[exp_3$TWO_R == "CT", "TWO_T"])
cliff.delta(exp_3[exp_3$TWO_R == "LL", "TWO_T"], exp_3[exp_3$TWO_R == "CT", "TWO_T"])