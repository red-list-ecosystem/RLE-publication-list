#!R --vanilla
require(bibliometrix)
require(readODS)
require(dplyr)
require(purrr)

here::i_am("inc/R/bibliographic-info.R")

A0 <- readFiles()
M0 <- convert2df(here::here("bibtex/WOS-search-20200413.bib"), 
                 dbsource = "isi", format = "bibtex")

mis.dois <- read.csv(
  here::here("input/DOI-check-list.txt"),
  header=F,as.is=T)$V1

load(here::here("Rdata/CR-biblio-info.rda"))

a.step <- read.csv(here::here("input/assessment-step.csv"),header=F,as.is=T)

a.units <- read_ods(here::here("input/List_assessment_units.ods"),sheet=1)

sort(table(a.units$ReferenceID))

a.sumr <- read_ods(here::here("input/Summary_RLE_database.ods"),sheet=1)

a.dois <- grep("^10",unique(a.sumr$DOI),value=T)


 subset(a.step,!V1 %in% mis.dois)$V1
 subset(a.dois,!a.dois %in% mis.dois)

#### pre assessment
slc <- subset(a.step,V2 %in% "pre assessment")$V1


ref.info$data %>% filter(doi %in% slc) %>% arrange(created) -> dts

dts %>% pull(author) %>% ## map(`[`,c("given","family")) %>%
 map(function(x) paste(gsub("[a-záéíóú\\. ]","",x$given),x$family,collapse=", ")) -> authors




#### assessment
slc <- subset(a.step,V2 %in% "assessment")$V1


ref.info$data %>% filter(doi %in% slc) %>% arrange(created) -> dts

dts %>% pull(author) %>% ## map(`[`,c("given","family")) %>%
 map(function(x) paste(gsub("[a-záéíóú\\. ]","",x$given),x$family,collapse=", ")) -> authors

with(dts,
     sprintf("* %1$s (%2$s) *%3$s* DOI:[%4$s](http://doi.org/%4$s)\n",
             unlist(authors), 
             substr(created,1,4),
             title,
             doi))

#### post-assessment
slc <- subset(a.step,V2 %in% "post assessment")$V1

output.arch <- "~/proyectos/IUCN/RLE-publication-list/docs/_listas/03-post-assessment.md"


ref.info$data %>% filter(doi %in% slc) %>% arrange(created) -> dts

dts %>% pull(author) %>% ## map(`[`,c("given","family")) %>%
 map(function(x) paste(gsub("[a-záéíóú\\. ]","",x$given),x$family,collapse=", ")) -> authors

