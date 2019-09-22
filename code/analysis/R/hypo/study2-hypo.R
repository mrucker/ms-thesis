library("multcomp");
library("clinfun");
library("effsize");

kruskal.test(ONE_T ~ TWO_R, data = exp_2)
kruskal.test(TWO_T ~ TWO_R, data = exp_2)

kruskal.test(ONE_T ~ TWO_R, data = exp_2[exp_2$TWO_R != "HH" & exp_2$TWO_R != "HL" & exp_2$TWO_R != "LH",])
kruskal.test(ONE_T ~ TWO_R, data = exp_2[exp_2$TWO_R != "LL",])

median(exp_2$ONE_T[exp_2$TWO_R == "HH"])
median(exp_2$ONE_T[exp_2$TWO_R == "LH"])
median(exp_2$ONE_T[exp_2$TWO_R == "CT"])

wilcox.test(exp_2$ONE_T[exp_2$TWO_R == "HH"], exp_2$TWO_T[exp_2$TWO_R == "HH"], alternative = "two.sided", exact = FALSE, paired = TRUE)$p.value
wilcox.test(exp_2$ONE_T[exp_2$TWO_R == "HL"], exp_2$TWO_T[exp_2$TWO_R == "HL"], alternative = "two.sided", exact = FALSE, paired = TRUE)$p.value
wilcox.test(exp_2$ONE_T[exp_2$TWO_R == "LH"], exp_2$TWO_T[exp_2$TWO_R == "LH"], alternative = "two.sided", exact = FALSE, paired = TRUE)$p.value
wilcox.test(exp_2$ONE_T[exp_2$TWO_R == "CT"], exp_2$TWO_T[exp_2$TWO_R == "CT"], alternative = "two.sided", exact = FALSE, paired = TRUE)$p.value
wilcox.test(exp_2$ONE_T[exp_2$TWO_R == "LL"], exp_2$TWO_T[exp_2$TWO_R == "LL"], alternative = "two.sided", exact = FALSE, paired = TRUE)$p.value

wilcox.test(exp_2$ONE_T[exp_2$TWO_R == "HH"], exp_2$ONE_T[exp_2$TWO_R == "CT"], alternative = "two.sided", exact = FALSE, paired = FALSE)$p.value
wilcox.test(exp_2$ONE_T[exp_2$TWO_R == "HL"], exp_2$ONE_T[exp_2$TWO_R == "CT"], alternative = "two.sided", exact = FALSE, paired = FALSE)$p.value
wilcox.test(exp_2$ONE_T[exp_2$TWO_R == "LH"], exp_2$ONE_T[exp_2$TWO_R == "CT"], alternative = "two.sided", exact = FALSE, paired = FALSE)$p.value
wilcox.test(exp_2$ONE_T[exp_2$TWO_R == "LL"], exp_2$ONE_T[exp_2$TWO_R == "CT"], alternative = "two.sided", exact = FALSE, paired = FALSE)$p.value

wilcox.test((exp_2$TWO_T[exp_2$TWO_R == "HH"]), (exp_2$TWO_T[exp_2$TWO_R == "CT"]), alternative = "greater", exact = FALSE, paired = FALSE)$p.value
wilcox.test((exp_2$TWO_T[exp_2$TWO_R == "HL"]), (exp_2$TWO_T[exp_2$TWO_R == "CT"]), alternative = "greater", exact = FALSE, paired = FALSE)$p.value
wilcox.test((exp_2$TWO_T[exp_2$TWO_R == "LH"]), (exp_2$TWO_T[exp_2$TWO_R == "CT"]), alternative = "greater", exact = FALSE, paired = FALSE)$p.value
wilcox.test((exp_2$TWO_T[exp_2$TWO_R == "LL"]), (exp_2$TWO_T[exp_2$TWO_R == "CT"]), alternative = "less"   , exact = FALSE, paired = FALSE)$p.value

wilcox.test((exp_2$TWO_T[exp_2$TWO_R == "HH" | exp_2$TWO_R == "LH" | exp_2$TWO_R == "HL"]), (exp_2$TWO_T[exp_2$TWO_R == "CT"]), alternative = "greater", exact = FALSE, paired = FALSE)$p.value

jonckheere.test(exp_2$ONE_T, as.numeric(exp_2$TWO_R), alternative = "decreasing")

cliff.delta(exp_2$TWO_T[exp_2$TWO_R == "HH"], exp_2$TWO_T[exp_2$TWO_R == "CT"])$estimate
cliff.delta(exp_2$TWO_T[exp_2$TWO_R == "HL"], exp_2$TWO_T[exp_2$TWO_R == "CT"])$estimate
cliff.delta(exp_2$TWO_T[exp_2$TWO_R == "LH"], exp_2$TWO_T[exp_2$TWO_R == "CT"])$estimate
cliff.delta(exp_2$TWO_T[exp_2$TWO_R == "LL"], exp_2$TWO_T[exp_2$TWO_R == "CT"])$estimate