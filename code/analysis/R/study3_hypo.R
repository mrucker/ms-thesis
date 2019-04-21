library("multcomp");
library("clinfun");
library("effsize");

kruskal.test(ONE_T ~ TWO_R, data = f3_df)
kruskal.test(TWO_T ~ TWO_R, data = f3_df)

wilcox.test((f3_df$ONE_T[f3_df$TWO_R == "HH" | f3_df$TWO_R == "HL" | f3_df$TWO_R == "LH"]), (f3_df$ONE_T[f3_df$TWO_R == "CT"]), alternative = "two.sided", exact = FALSE, paired = FALSE)$p.value
wilcox.test((f3_df$TWO_T[f3_df$TWO_R == "HH" | f3_df$TWO_R == "HL" | f3_df$TWO_R == "LH"]), (f3_df$TWO_T[f3_df$TWO_R == "CT"]), alternative = "greater"  , exact = FALSE, paired = FALSE)$p.value

wilcox.test((f3_df$TWO_T[f3_df$TWO_R == "HH"]), (f3_df$TWO_T[f3_df$TWO_R == "CT"]), alternative = "greater", exact = FALSE, paired = FALSE)$p.value
wilcox.test((f3_df$TWO_T[f3_df$TWO_R == "HL"]), (f3_df$TWO_T[f3_df$TWO_R == "CT"]), alternative = "greater", exact = FALSE, paired = FALSE)$p.value
wilcox.test((f3_df$TWO_T[f3_df$TWO_R == "LH"]), (f3_df$TWO_T[f3_df$TWO_R == "CT"]), alternative = "greater", exact = FALSE, paired = FALSE)$p.value
wilcox.test((f3_df$TWO_T[f3_df$TWO_R == "LL"]), (f3_df$TWO_T[f3_df$TWO_R == "CT"]), alternative = "less"   , exact = FALSE, paired = FALSE)$p.value

jonckheere.test(f3_df$ONE_T, as.numeric(f3_df$TWO_R), alternative = "decreasing")

cliff.delta(f3_df[f3_df$TWO_R == "HH", "TWO_T"], f3_df[f3_df$TWO_R == "CT", "TWO_T"])
cliff.delta(f3_df[f3_df$TWO_R == "HL", "TWO_T"], f3_df[f3_df$TWO_R == "CT", "TWO_T"])
cliff.delta(f3_df[f3_df$TWO_R == "LH", "TWO_T"], f3_df[f3_df$TWO_R == "CT", "TWO_T"])
cliff.delta(f3_df[f3_df$TWO_R == "LL", "TWO_T"], f3_df[f3_df$TWO_R == "CT", "TWO_T"])