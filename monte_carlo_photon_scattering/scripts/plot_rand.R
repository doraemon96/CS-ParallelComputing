# R Script to print comparison between running times
# of different sources (compilers, versions, etc).

library(ggplot2)


SOURCE_FILE <- "out_tiny_mc_rand.txt"

# Set working directory to data folder
setwd("./data")
wd <- getwd()
print(paste0("Working on directory: ",wd))

# Load CSV file
data   <- read.csv(paste0(wd,"/",SOURCE_FILE), header=FALSE)
names(data) <- c("Libreria", "MetricaNorm")
agData <- aggregate(data$MetricaNorm, by=list(comp=data$Libreria),
                FUN = function(x) c(mean = mean(x), sd = sd(x), n = length(x)))
agData <- do.call(data.frame, agData)

agData$se <- agData$x.sd / sqrt(agData$x.n)
colnames(agData) <- c("Libreria", "mean", "sd", "n", "se")


limits <- aes(ymax = agData$mean + agData$se,
              ymin = agData$mean - agData$se)

ggplot( data = agData, aes(x = factor(Libreria), y = mean, fill=factor(Libreria)) ) +
    geom_bar(stat = "identity", position = position_dodge(0.9)) +
    geom_errorbar(limits, position = position_dodge(0.9), width = 0.25) +
    labs( x = "Libreria", y = "iteraciones/ms") +
    #ggtitle("Metrica según compilador y optimización") +
    #scale_fill_discrete(name = "Optimización") +
    scale_fill_brewer(palette="Spectral")



# Plot barplot with error bars
ggsave("plot_tiny_mc_rand.png")
