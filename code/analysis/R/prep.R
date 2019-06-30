library("plyr"); #for revalue()

figs_path = "C:/Users/Mark/Desktop"

source("theme.R");

#study results
a1_df = read.csv("../../../data/studies/_misc/studies1.csv", header = TRUE, sep = ",")
a2_df = read.csv("../../../data/studies/_misc/studies2.csv", header = TRUE, sep = ",")
a3_df = read.csv("../../../data/studies/_misc/studies3.csv", header = TRUE, sep = ",")

clean_a_df <- function(a_df) {
    a_df$TWO_R = revalue(a_df$TWO_R, c("c4op" = "LL", "b4op" = "LH", "1" = "CT", "a3op" = "HL", "b3op" = "HH"))
    a_df$TWO_R = factor(a_df$TWO_R, levels = c("HH", "HL", "CT", "LH", "LL"))

    a_df$ONE_DT = as.POSIXct(a_df$ONE_TS, tz = "", "%Y-%m-%dT%H:%M:%S")

    a_df$Clean_System = as.character(a_df$Clean_System)
    a_df$Clean_System[grepl("android", a_df$Clean_System)] = "android"
    a_df$Clean_System[grepl("ios", a_df$Clean_System)] = "ios"
    a_df$Clean_System[grepl("fedora", a_df$Clean_System)] = "linux"
    a_df$Clean_System[grepl("linux", a_df$Clean_System)] = "linux"
    a_df$Clean_System[grepl("ubuntu", a_df$Clean_System)] = "linux"
    a_df$Clean_System[grepl("windows 8", a_df$Clean_System)] = "windows other"
    a_df$Clean_System[grepl("windows server", a_df$Clean_System)] = "windows other"
    a_df$Clean_System[grepl("windows xp", a_df$Clean_System)] = "windows other"
    #a_df$Clean_System[grepl("ubuntu", a_df$Clean_System)] = "windows other"
    a_df$Clean_System = factor(a_df$Clean_System)

    return(a_df)
}

filter_a_df <- function(a_df) {

    f_df = a_df[
        a_df$First == "yes" &
        a_df$Input == "mouse" &
        a_df$ONE_O >= 430 &
        a_df$TWO_O >= 430 &
        a_df$ONE_F >= 20 &
        a_df$TWO_F >= 20
    ,]

    return(f_df)
}

a1_df = clean_a_df(a1_df)
a2_df = clean_a_df(a2_df)
a3_df = clean_a_df(a3_df)

f1_df = filter_a_df(a1_df)
f2_df = filter_a_df(a2_df)
f3_df = filter_a_df(a3_df)
#study results

#irl performance
p_irl = read.csv("../../../data/algorithm/perf-irl.csv", header = TRUE, sep = ",")

clean_p_irl <- function(p_irl) {
    p_irl$algorithm = revalue(p_irl$algorithm, c("an" = "PIRL", "algorithm5" = "KPIRL", "gpirl" = "GPIRL"))

    return (p_irl)
}

filter_p_irl <- function(p_irl) {
    p_irl = p_irl[p_irl$algorithm != "algorithm9",]

    return (p_irl)
}

p_irl = clean_p_irl(p_irl)
p_irl = filter_p_irl(p_irl)
#irl performance

#kla performance

#perf-adp1.csv is a comparison of KLA, LSPI and KLSPI with KLA set to 30 30 5 2 and using state_init = 20
#perf-adp2.csv is a comparison of KLA, LSPI and KLSPI with KLA set to 30 90 3 4 and using state_init = 3
#perf-adp3.csv is a comparison of KLA, LSPI and KLSPI with KLA set to 30 90 3 4 and using state_init = 20
#perf-adp4.csv is a comparison of KLA, LSPI and KLSPI with KLA set to 30 90 3 4 and using state_init = 20

kla2 = read.csv("../../../data/algorithm/perf-adp2.csv", header = TRUE, sep = ",");
kla2$algorithm = revalue(kla2$algorithm, c("algorithm_13k" = "KLA", "algorithm_lsp" = "LSPI", "algorithm_ksp" = "KLSPI"))

kla3 = read.csv("../../../data/algorithm/perf-adp3.csv", header = TRUE, sep = ",");
kla3$algorithm = revalue(kla3$algorithm, c("algorithm_13k" = "KLA", "algorithm_lsp" = "LSPI", "algorithm_ksp" = "KLSPI"))

kla4 = read.csv("../../../data/algorithm/perf-adp4.csv", header = TRUE, sep = ",");
kla4$algorithm = revalue(kla4$algorithm, c("algorithm_13ks" = "KLA", "algorithm_13kx" = "KLA", "algorithm_lsp" = "LSPI", "algorithm_ksp" = "KLSPI"))
#kla performance

#reward functions
HH = read.csv("../../../data/algorithm/b3op.csv", header = TRUE, sep = ",")
HH$worth_f = factor((HH$reward > HH$reward[1]) + 0, levels = c(0, 1), labels = c("not worth touching", "worth touching"))

LL = read.csv("../../../data/algorithm/c4op.csv", header = TRUE, sep = ",")
LL$worth_f = factor((LL$reward > LL$reward[1]) + 0, levels = c(0, 1), labels = c("not worth touching", "worth touching"))
#reward functions

#utility functions used for making plots
count_title <- function(title, f_df) {
    return(paste(title, " ", "(n=", prettyNum(dim(f_df)[1], big.mark = ","), ")", sep = ""))
}

median_summary <- function(f_df) {
    v1 = data.frame(T = c(f_df$ONE_T, f_df$TWO_T), S = rep(factor(c("Game 1", "Game 2")), each = dim(f_df)[1]), I = factor(c(as.character(f_df$Input), as.character(f_df$Input))), R = factor(c(as.character(f_df$TWO_R), as.character(f_df$TWO_R)), levels = c("HH", "HL", "CT", "LH", "LL")));
    v2 = ddply(v1, .(I, S, R), summarize, med = median(T), avg = mean(T), var = var(T));
    return(v2)
}
#utility functions used for making plots