#!R --vanilla
require(gdata)
require(bibtex)
require(RefManageR)
##require(RJSONIO)
require(rcrossref)
require(xml2)
library(ggplot2)
require(tidyverse)
library(ggplot2)
##library(plotly)
##library(stringr)
##library(dplyr)
##require(textcat)
##require(rAltmetric)
##library(tidyr)

mis.dois <- unique(tolower(read.csv("~/proyectos/IUCN/RLE-publication-list/input/DOI-check-list.txt",header=F,as.is=T)$V1))

ref.info <- ReadBib("~/proyectos/IUCN/RLE-publication-list/bibtex/RLE-collection-DOI-download.bib")

unlist(lapply(ref.info, function(x) x$doi))
table(mis.dois %in% tolower(unlist(lapply(ref.info, function(x) x$doi))))
faltan <- subset(mis.dois,!mis.dois %in% unlist(lapply(ref.info, function(x) x$doi)))
print(ref.info,.opts=list(style='markdown',bib.style='authoryear'))

ref.info <- GetBibEntryWithDOI(faltan,temp.file="~/proyectos/IUCN/RLE-publication-list/bibtex/tempfile.bib",delete.file=F)

ref.info <- cr_works(dois = mis.dois,.progress="text")

ref.info$data$title
 print.AsIs(ref.info$data[,c("doi","title")])

system("mkdir -p ~/proyectos/IUCN/RLE-publication-list/Rdata")
save(file="~/proyectos/IUCN/RLE-publication-list/Rdata/CR-biblio-info.rda",ref.info)

## Intro en https://poldham.github.io/abs/crossref.html
ref.info$data %>% count(subject, sort = TRUE)
ref.info$data %>% separate_rows(subject, sep = ",") %>%
  count(subject=trim(subject), sort = TRUE) -> subjects  # output subjects

subjects %>%
  ggplot2::ggplot(aes(subject, n, fill = subject)) +
  geom_bar(stat = "identity", show.legend = FALSE) +
  coord_flip()
ref.info$data$year <- as.numeric(substr(ref.info$data$issued,0,4))
ref.info$data %>%
    count(year) %>%
        ggplot(aes(x = year, y = n, group = 1)) +
                geom_line() -> out # data out

out

ref.info$data %>%
    count(year) %>%
        ggplot(aes(x = year, y = n, group = 1)) +
                geom_bar(stat = "identity", show.legend = FALSE)  # data out

hist(ref.info$data$year)

# Remove null, unnest list column, create full_name

list.authors <- ref.info$data[ref.info$data$author != "NULL", ] %>%
  tidyr::unnest(., author) %>%
  tidyr::unite(auth_full_name, c(family, given), sep = " ", remove = FALSE) %>%
  rename("auth_family" = family, "auth_given" = given, "auth_aff" = affiliation.name)

# get initials...
list.authors$initials <- tolower(sapply(list.authors$auth_given,function(x) {
    y <- strsplit(x," ")[[1]]
    paste(substr(y,1,1),collapse="")
}))

## last name + initials
list.authors$valid_name <- trim(tolower(paste(list.authors$auth_family,list.authors$initials,sep=" ")))

length(unique(list.authors$valid_name))
length(unique(list.authors$auth_full_name))


list.authors %>% count(valid_name, sort = TRUE)

list.authors$auth_alt2 <- list.authors$valid_name
list.authors$auth_alt3 <- list.authors$valid_name
list.authors$auth_alt4 <- list.authors$valid_name
mtz.names <- adist(list.authors$valid_name)

for (k in unique(list.authors$valid_name)) {
    idx <- first(match(k,list.authors$auth_alt2))
    if (length(idx)==1) {
        list.authors$auth_alt2[which(mtz.names[idx,]<2)] <- k
        list.authors$auth_alt3[which(mtz.names[idx,]<3)] <- k
        list.authors$auth_alt4[which(mtz.names[idx,]<4)] <- k
    }
}

list.authors %>% count(auth_alt2, sort = TRUE) ## poco
list.authors %>% count(auth_alt3, sort = TRUE) ## mejor
subset(list.authors,auth_alt3 %in% "butchart s")$valid_name

## error en Ma Keeping y Ma...
subset(list.authors,auth_alt3 %in% "ma z")$valid_name

## dos autores diferentes
subset(list.authors,auth_alt3 %in% "lei g")$valid_name
subset(list.authors,auth_alt3 %in% "keith da")$valid_name

for (bsc in c("ma z","lei g","keith da","murray nj","regan tj","wilson al")) {
    list.authors[list.authors$auth_alt3 %in% bsc,"auth_alt3"] <- list.authors[list.authors$auth_alt3 %in% bsc,"valid_name"]
}

list.authors %>% count(auth_alt4, sort = TRUE) ## demasiado
list.authors <- subset(list.authors,!valid_name %in% "na na")

length(unique(list.authors$auth_alt3))
length(unique(list.authors$valid_name))







mi.key <- ""

##require(ROpenOffice)
##RLEpubs <- read.ods("~/Descargas/RLE Publications - 2018 List.ods")
##RLEpubs <- read.csv("~/Descargas/RLE_Publications.csv")
##
## https://www.iucnredlist.org/resources/list
## http://www.keybiodiversityareas.org/publications
