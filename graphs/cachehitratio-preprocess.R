#!/usr/bin/env Rscript
#################################################################
#pre-process Script, Ertugrul Dogruluk- 2019
#Algorithmi Research Centree, Braga-Portugal, University of Minho
##################################################################
args = commandArgs(TRUE)
if (length(args) == 0) {
  cat ("ERROR: Scenario parameters should be specified\n")
  q(status = 1)
}

options(gsubfn.engine = "R")
suppressPackageStartupMessages (library(sqldf))
suppressPackageStartupMessages (library(ggplot2))
suppressPackageStartupMessages (library(reshape2))
suppressPackageStartupMessages (library(doBy))

prefix = args[1]
topo   = args[2]
evil   = args[3]
runs   = args[4]
folder = args[5]
if (is.na (folder)) {
  folder = "newrun"
}
good   = args[6]
producer = args[7]

name = paste (sep="-", prefix, "topo", topo, "evil", evil, "good", good, "producer", producer)

data.all = data.frame ()

for (run in strsplit(runs,",")[[1]]) {  
  filename <- paste (sep="", "results/", folder, "/", name, "-run-", run)
  cat ("Reading from", filename, "\n")

  input <- paste (sep="", filename, ".db")
  data.run <- sqldf("select * from data", dbname = input, stringsAsFactors=TRUE)

 # nodes.good     = levels(data.run$Node)[ grep ("^good-",     levels(data.run$Node)) ]
  nodes.evil     = levels(data.run$Node)[ grep ("^gw-", levels(data.run$Node)) ]
  #nodes.producer = levels(data.run$Node)[ grep ("^gw-", levels(data.run$Node)) ]

  run.ratios <- function (data) {
    data.evilmisses = subset (data, Node %in% nodes.evil & Type == "CacheMisses")
    data.evilmisses$Type <- NULL
    names(data.evilmisses)[names(data.evilmisses) == "Packets"] = "CacheMisses"
    
    
    data.evilhits      = subset (data, Node %in% nodes.evil & Type == "CacheHits")
    data.evilhits$Type <- NULL
    names(data.evilhits)[names(data.evilhits) == "Packets"] = "CacheHits"
    
    
    data.out = merge (data.evilmisses, data.evilhits)
    data.out$Run  = run
    data.out$Ratio = data.out$CacheHits / (data.out$CacheHits + data.out$CacheMisses)
 #   data.out$Ratio = 10 
    data.out
  }

  data.all = rbind (data.all, run.ratios (data.run))
}

## data.all$Type = factor(data.all$Type)
data.all$Run  = factor(data.all$Run)
data.all$Scenario = factor(prefix)
data.all$Evil     = factor(evil)


outputfile = paste(sep="", "results/",folder,"/process/", name, ".txt")
#unlink(paste(sep="", "results/",folder,"/process/"), recursive = TRUE)
dir.create (paste(sep="", "results/",folder,"/process/"), showWarnings = FALSE)

cat (">> Writing", outputfile, "\n")
## write.table(data.all, file = outputfile, row.names=FALSE, col.names=TRUE)
data = data.all
save (data, file=outputfile)

