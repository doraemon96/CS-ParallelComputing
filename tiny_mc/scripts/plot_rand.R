# R Script to print comparison between running times
# of different sources (compilers, versions, etc).

library(ggplot2)


SOURCE_FILE <- "out_tiny_mc.txt"


# Set working directory to data folder
setwd("../tiny_mc_rand")
wd <- getwd()
print(paste0("Working on directory: ",wd))

# Load CSV file
data   <- read.csv(paste0(wd,"/",SOURCE_FILE), header=FALSE)
names(data) <- c("Libreria", "MetricaNorm")
agData <- aggregate(data$MetricaNorm, by=list(data$Libreria),
                FUN = function(x) c(mean = mean(x), sd = sd(x), n = length(x)))
agData <- do.call(data.frame, agData)

agData$se <- agData$x.sd / sqrt(agData$x.n)
colnames(agData) <- c("Libreria", "mean", "sd", "n", "se")


limits <- aes(ymax = agData$mean + agData$se,
              ymin = agData$mean - agData$se)

p <- ggplot( data = agData, aes(x = Libreria, y = mean))
p + geom_bar( stat = "identity", position = position_dodge(0.9)) +
    labs( x = "Libreria", y = "iteraciones/ms") +

ggsave("plot.png")
