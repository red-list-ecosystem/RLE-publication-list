#!R --vanilla
require(bibliometrix)
require(readODS)
require(dplyr)

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

#### pre assessment
slc <- subset(a.step,V2 %in% "pre assessment")$V1

output.arch <- "~/proyectos/IUCN/RLE-publication-list/docs/_listas/01-pre-assessment.md"

cat("---
title: Pre-assessment publications
---
References with information related to guidelines, methods and data gathering prior to the proper assessment.

",file=output.arch)

ref.info$data %>% filter(doi %in% slc) %>% arrange(created) -> dts
cat(file=output.arch,with(dts,sprintf("* %s (%s) [%s](http://doi.org/%s)\n",paste(author$family,collapse="; "), published.print,title,doi)),append=T)


#### assessment
slc <- subset(a.step,V2 %in% "assessment")$V1

output.arch <- "~/proyectos/IUCN/RLE-publication-list/docs/_listas/02-assessment.md"

cat("---
title: Assessment publications
---

Actual implementation of the assessment following one set of guidelines, and presenting a proper outcome for each assessment unit

",file=output.arch)

ref.info$data %>% filter(doi %in% slc) %>% arrange(created) -> dts
cat(file=output.arch,with(dts,sprintf("* %s (%s) [%s](http://doi.org/%s)\n",paste(author$family,collapse="; "), published.print,title,doi)),append=T)


#### post-assessment
slc <- subset(a.step,V2 %in% "post assessment")$V1

output.arch <- "~/proyectos/IUCN/RLE-publication-list/docs/_listas/03-post-assessment.md"

cat("---
title: Post-assessment publications
---

Publications that summarize assessment outcomes.

",file=output.arch)

ref.info$data %>% filter(doi %in% slc) %>% arrange(created) -> dts
cat(file=output.arch,with(dts,sprintf("* %s (%s) [%s](http://doi.org/%s)\n",paste(author$family,collapse="; "), published.print,title,doi)),append=T)
