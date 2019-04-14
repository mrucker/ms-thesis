library("multcomp");
library("clinfun");
library("effsize");

kruskal.test(ONE_T ~ TWO_R, data = f2_df)
kruskal.test(TWO_T ~ TWO_R, data = f2_df)

kruskal.test(ONE_T ~ TWO_R, data = f2_df[f2_df$TWO_R != "HH" & f2_df$TWO_R != "HL" & f2_df$TWO_R != "LH",])
kruskal.test(ONE_T ~ TWO_R, data = f2_df[f2_df$TWO_R != "LL",])

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