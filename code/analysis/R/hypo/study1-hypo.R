library("multcomp");
library("clinfun");
library("effsize");

#the kruskal test shows that there is likely not a difference between test one groups
kruskal.test(ONE_T ~ TWO_R, data = f1_df)
kruskal.test(TWO_T ~ TWO_R, data = f1_df)

kruskal.test(TWO_T ~ TWO_R, data = f1_df[f1_df$TWO_R != "LL" & f1_df$TWO_R != "LH",])
kruskal.test(TWO_T ~ TWO_R, data = f1_df[f1_df$TWO_R != "HH" & f1_df$TWO_R != "HL",])

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

cliff.delta(f1_df$TWO_T[f1_df$TWO_R == "HH"], f1_df$TWO_T[f1_df$TWO_R == "CT"])$estimate
cliff.delta(f1_df$TWO_T[f1_df$TWO_R == "HL"], f1_df$TWO_T[f1_df$TWO_R == "CT"])$estimate
cliff.delta(f1_df$TWO_T[f1_df$TWO_R == "LH"], f1_df$TWO_T[f1_df$TWO_R == "CT"])$estimate
cliff.delta(f1_df$TWO_T[f1_df$TWO_R == "LL"], f1_df$TWO_T[f1_df$TWO_R == "CT"])$estimate