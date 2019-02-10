library("ggplot2");
library("plyr");

b3op = read.csv("data/b3op.csv", header = TRUE, sep = ",")
b3op$worth_f = factor((b3op$reward > b3op$reward[1]) + 0, levels = c(0, 1), labels = c("not worth touching", "worth touching"))

c4op = read.csv("data/c4op.csv", header = TRUE, sep = ",")
c4op$worth_f = factor((c4op$reward > c4op$reward[1]) + 0, levels = c(0, 1), labels = c("not worth touching", "worth touching"))

ggplot(c4op, aes(x = reward)) +
    geom_histogram(binwidth = .0005) +
    geom_vline(aes(xintercept = mean(reward)),color = "black", linetype = "dashed", size = 1)+
    labs(x = "Reward Value", y = "Count", title = "Reward Value Distribution for Worst (n=3,458)")

ggplot(b3op, aes(x = reward)) +
    geom_histogram(binwidth = .0005) +
    geom_vline(aes(xintercept = mean(reward)), color = "black", linetype = "dashed", size = 1) +
    labs(x = "Reward Value", y = "Count", title = "Reward Value Distribution for Best (n=3,458)")

ggplot(b3op, aes(x = reward, fill = worth_f)) +
    geom_histogram(binwidth = .0005) +
    scale_fill_grey() +
    labs(x = "Reward Value", y = "Count", title = "Targets Not Worth Touching -- Raw (n=3,458)", fill = "")

ggplot(b3op, aes(x = (reward-reward[1]), fill = worth_f)) +
    geom_histogram(binwidth = .0005) +
    scale_fill_grey() +
    labs(x = "Reward Value", y = "Count", title = "Targets Not Worth Touching -- Shifted (n=3,458)", fill = "")

ggplot(c4op, aes(x = ((reward * (reward < quantile(reward, .97)) + quantile(reward, .97) * (reward >= quantile(reward, .97)) - reward[1]) * (reward > reward[1])), fill = worth_f)) +
    geom_histogram(binwidth = .0001) +
    scale_fill_grey() +
    labs(x = "Reward Value", y = "Count", title = "Final Reward Function -- Worst (n=3,458)", fill = "")

ggplot(b3op, aes(x = ((reward * (reward < quantile(reward,.97)) + quantile(reward,.97)*(reward>=quantile(reward,.97)) - reward[1]) * (reward > reward[1])), fill = worth_f)) +
    geom_histogram(binwidth = .0005) +
    scale_fill_grey() +
    labs(x = "Reward Value", y = "Count", title = "Final Reward Function -- Best (n=3,458)", fill = "")


quantile (b3op$reward, .97)