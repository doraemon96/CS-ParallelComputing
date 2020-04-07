# R Script to print comparison between running times
# of different sources (compilers, versions, etc).

library(ggplot2)


SOURCE_FILE <- "out_tiny_mc_photons.txt"


# Set working directory to data folder
setwd("./data")
wd <- getwd()
print(paste0("Working on directory: ",wd))

# Load CSV file
data   <- read.csv(paste0(wd,"/",SOURCE_FILE), header=FALSE)
names(data) <- c("Num", "Phot", "MetricaNorm")
agData <- aggregate(data$MetricaNorm, by=list(comp=data$Num, opt=data$Phot),
                FUN = function(x) c(mean = mean(x), sd = sd(x), n = length(x)))
agData <- do.call(data.frame, agData)

agData$se <- agData$x.sd / sqrt(agData$x.n)
colnames(agData) <- c("Num", "Phot", "mean", "sd", "n", "se")


limits <- aes(ymax = agData$mean + agData$se,
              ymin = agData$mean - agData$se)

p <- ggplot( data = agData, aes(x = Phot, y = mean, group = factor(Num), color = factor(Num)) )
p + geom_line(size=1) +
    geom_point() +
    geom_errorbar(limits, position = position_dodge(0.05), width = 0.25) +
    scale_x_discrete( name="PHOTONS", limits=seq(30000,230000,20000), expand=c(0.1, 0.1) ) +
    labs( x="PHOTONS", y="iteraciones/ms") +
    scale_colour_discrete( name="Optim." ) +
    scale_fill_brewer(palette="Spectral")


# Plot barplot with error bars

ggsave("plot_tini_mc_photons.png")
