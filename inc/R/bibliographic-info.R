#!R --vanilla
require(bibliometrix)
require(readODS)

A0 <- readFiles("~/proyectos/IUCN/RLE-publication-list/bibtex/WOS-search-20200413.bib")
M0 <- convert2df(A0, dbsource = "isi", format = "bibtex")

mis.dois <- read.csv("~/proyectos/IUCN/RLE-publication-list/input/DOI-check-list.txt",header=F,as.is=T)$V1
load("~/proyectos/IUCN/RLE-publication-list/Rdata/CR-biblio-info.rda")

a.step <- read.csv("~/proyectos/IUCN/RLE-publication-list/input/assessment-step.csv",header=F,as.is=T)

a.units <- read_ods("~/proyectos/IUCN/RLE-publication-list/input/List_assessment_units.ods",sheet=1)

sort(table(a.units$ReferenceID))

a.sumr <- read_ods("~/proyectos/IUCN/RLE-publication-list/input/Summary_RLE_database.ods",sheet=1)

a.dois <- grep("^10",unique(a.sumr$DOI),value=T)


 subset(a.step,!V1 %in% mis.dois)$V1
 subset(a.dois,!a.dois %in% mis.dois)


output.arch <- "~/proyectos/IUCN/RLE-publication-list/docs/_posts/pre-assessment.md"
slc <- subset(a.step,V2 %in% "pre assessment")$V1
require(dplyr)
ref.info$data %>% filter(doi %in% slc) %>% arrange(created) -> dts
cat(file=output.arch,with(dts,sprintf("* %s (%s) [%s](http://doi.org/%s)\n",paste(author$family,collapse="; "), published.print,title,doi)))
