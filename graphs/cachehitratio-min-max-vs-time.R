#!/usr/bin/env Rscript
#################################################################
#min.max.cache hit ratios, Ertugrul Dogruluk- 2019
#Algorithmi Research Centree, Braga-Portugal, University of Minho
##################################################################
args = commandArgs(TRUE)
if (length(args) == 0) {
  cat ("ERROR: Scenario parameters should be specified\n")
  q(status = 1)
}

prefixes = args[1]
topo     = args[2]
evils    = args[3]
runs     = args[4]
folder   = args[5]
good     = args[6]
producer = args[7]

suppressPackageStartupMessages (library(ggplot2))
suppressPackageStartupMessages (library(reshape2))
suppressPackageStartupMessages (library(doBy))
suppressPackageStartupMessages (library(plyr))
suppressPackageStartupMessages (library(scales))
suppressPackageStartupMessages (library(dplyr))
suppressPackageStartupMessages (library(gridExtra))



source ("graphs/graph-style.R")

name = paste (sep="-", prefixes, "topo", topo, "evil", evils, "producer", producer)
filename = paste(sep="", "results/",folder,"/process/", name, "-all-data.dat")

if (file_test("-f", filename)) {
  cat ("Loading data from", filename, "\n")
  load (filename)
  
} else {
  data.all = data.frame ()
  for (evil in strsplit(evils,",")[[1]]) {
    for (prefix in strsplit(prefixes,",")[[1]]) {
      name = paste (sep="-", prefix, "topo", topo, "evil", evil, "good", good, "producer", producer)
      filename = paste(sep="", "results/",folder,"/process/", name, ".txt")
      cat ("Reading from", filename, "\n")
      ## data = read.table (filename, header=TRUE)
      load (filename)
      
      data.all <- rbind (data.all, data)
    }
  }
  
  name = paste (sep="-", prefixes, "topo", topo, "evil", evils, "producer", producer)
  filename = paste(sep="", "results/",folder,"/process/", name, "-all-data.dat")
  
  cat ("Saving data to", filename, "\n")
  save (data.all, file=filename)
}

data.all$Evil = factor(data.all$Evil)

name2 = paste (sep="-", topo, "good", good, "producer", producer)

data.all$Scenario = ordered (data.all$Scenario,
                             c("Lru", "Fifo","Lfu", "Freshness","Probability","Random" ))

levels(data.all$Scenario) <- sub("^Random$", "Randomly Cache", levels(data.all$Scenario))
levels(data.all$Scenario) <- sub("^Probability$", "Probabilistically Cache", levels(data.all$Scenario))
levels(data.all$Scenario) <- sub("^Freshness$", "Freshness Cache", levels(data.all$Scenario))
levels(data.all$Scenario) <- sub("^Lfu$", "Lfu", levels(data.all$Scenario))
levels(data.all$Scenario) <- sub("^Fifo$", "Fifo", levels(data.all$Scenario))
levels(data.all$Scenario) <- sub("^Lru$", "Lru", levels(data.all$Scenario))

cat (sep="", "Writing to ", paste(sep="","graphs/pdfs/", folder, "/",name2,".pdf"))
pdf (paste(sep="","graphs/pdfs/", folder, "/",name2,".pdf"), width=4, height=7)

#minTime = 300
minTime=0
attackTime = 30

#gdata = subset(data.all, minTime-0 <= Time & Time < minTime+attackTime+0)
gdata = data.all

g <- ggplot (gdata) +
#g <-  ggplot (gdata , aes(x=Time, y = Ratio, fill=Node, stat= "identity", color= Scenario)) +
#  geom_point (size=0.5) +
   stat_summary(aes(x=Time-minTime, y=Ratio, color=Scenario), geom="line", fun.y=mean, size=0.4) +
   stat_summary(aes(x=Time-minTime, y=Ratio, color=Scenario),
                 geom="errorbar",
                 fun.y=mean,
                 fun.ymin=min,
                 fun.ymax=function(x) {
                  min (1, max(x)) # don't pretend that we can do very good
                 },
                data = gdata[sample(nrow(gdata), length(gdata$Time)/70),],
                 size=0.1, width=1, alpha=0.5) +

 # theme_custom () +
  theme_bw(base_size = 8)+
  theme(legend.position="bottom")+ #or "none"
  xlab ("Simulation Time, seconds") +
  ylab ("min. and max. Cache Hit ratios") +
  # ggtitle ("AT&T Cache Hit Ratio dynamics during the attack (~30% attackers)") +
  scale_colour_brewer(palette="Dark2") +
  #scale_fill_brewer(palette="Greens") + #here is problematic!!!
  scale_y_continuous (limits=c(0,1), breaks=seq(0,1,0.25), labels=percent_format ()) + #also here is problematic!!!!
  #scale_y_continuous(labels = scales::percent, limits=c(0,1))+
  facet_wrap (~Scenario, nrow = 6, ncol = 1) 
  # geom_vline(xintercept = attackTime) +
 # theme (legend.key.size = unit(0.8, "lines"),
#         legend.position="none", #c(1.0, 0.0),
#         legend.justification=c(1,0),
#         legend.background = element_rect (fill="white", colour="black", size=0.1))  

print (g)

x = dev.off ()
