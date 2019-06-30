library("ggplot2");
library("plyr");

ggplot(LL, aes(x = reward)) +
    geom_histogram(binwidth = .0005) +
    geom_vline(aes(xintercept = mean(reward)),color = "black", linetype = "dashed", size = 1)+
    labs(x = "Reward Value", y = "Count", title = "Raw Reward Distribution for LL")

ggplot(HH, aes(x = reward)) +
    geom_histogram(binwidth = .0005) +
    geom_vline(aes(xintercept = mean(reward)), color = "black", linetype = "dashed", size = 1) +
    labs(x = "Reward Value", y = "Count", title = "Raw Reward Distribution for HH")

ggplot(LL, aes(x = (reward - reward[1]), fill = worth_f)) +
    geom_histogram(binwidth = .0005) +
    scale_fill_grey() +
    labs(x = "Reward Value", y = "Count", title = "Shifted Reward Distribution for LL", fill = "")

ggplot(HH, aes(x = (reward-reward[1]), fill = worth_f)) +
    geom_histogram(binwidth = .0005) +
    scale_fill_grey() +
    labs(x = "Reward Value", y = "Count", title = "Shifted Reward Distribution for HH", fill = "")

ggplot(LL, aes(x = ((reward * (reward < quantile(reward, .97)) + quantile(reward, .97) * (reward >= quantile(reward, .97)) - reward[1]) * (reward > reward[1])), fill = worth_f)) +
    geom_histogram(binwidth = .0001) +
    scale_fill_grey() +
    labs(x = "Reward Value", y = "Count", title = "Clipped and Shifted Reward Distribution for LL", fill = "")

ggplot(HH, aes(x = ((reward * (reward < quantile(reward,.97)) + quantile(reward,.97)*(reward>=quantile(reward,.97)) - reward[1]) * (reward > reward[1])), fill = worth_f)) +
    geom_histogram(binwidth = .0005) +
    scale_fill_grey() +
    labs(x = "Reward Value", y = "Count", title = "Clipped and Shifted Reward Distribution for HH", fill = "")