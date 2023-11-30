#!R --vanilla
require(gdata)
require(bibtex)
require(RefManageR)
require(rcrossref)
require(xml2)
library(ggplot2)
require(tidyverse)
library(ggplot2)

here::i_am("inc/R/query-and-update-bibliographic-info.R")

doi.checklist <- unique(tolower(read.csv(
  here::here("input","DOI-check-list.txt"),
  header=F, as.is=T)$V1))
doi.steps <- unique(tolower(read.csv(
  here::here("input","assessment-step.csv"),
  header=F,as.is=T)$V1))
doi.errors <- unique(tolower(read.csv(
  here::here("input","doi-errors.txt"),
  header=F,as.is=T)$V1))
mis.dois <- unique(c(doi.steps,doi.checklist))

mis.dois <- subset(mis.dois,!mis.dois %in% doi.errors)

if (dir.exists(here::here("bibTeX"))) {
  bibtex_folder <- "bibTeX"
} else {
  if (dir.exists(here::here("bibtex"))) {
    bibtex_folder <- "bibtex"
  } else {
    stop("folder for bibTeX file not found")
  }
}
ref.info <- ReadBib(
  here::here(bibtex_folder,"RLE-collection-DOI-download.bib")
)

listos <- unlist(lapply(ref.info, function(x) x$doi))
table(mis.dois %in% listos)

faltan <- mis.dois[!mis.dois %in% listos]

if (length(faltan)>0) {
  dwnl <- GetBibEntryWithDOI(faltan,
                             temp.file=here::here(bibtex_folder,"tempfile.bib"),
                             delete.file=F)
}



ref.doi <- unlist(lapply(ref.info, function(x) x$doi))

ref.info <- cr_works(dois = mis.dois,.progress="text")

save(file = here::here("Rdata","CR-biblio-info.rda"),
     ref.info)



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
