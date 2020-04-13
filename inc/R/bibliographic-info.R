#!R --vanilla
require(bibliometrix)

A0 <- readFiles("~/proyectos/IUCN/RLE-publication-list/bibtex/WOS-search-20200413.bib")
M0 <- convert2df(A0, dbsource = "isi", format = "bibtex")

mis.dois <- read.csv("~/proyectos/IUCN/RLE-publication-list/input/DOI-check-list.txt",header=F,as.is=T)$V1
