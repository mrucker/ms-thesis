library("plyr"); #for revalue()

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