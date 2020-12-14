
require(rcrossref)
rslt <- cr_works(doi="10.1016/j.biocon.2020.108834")

cat(sprintf("{{cite journal
%1$s
| date       = %2$s
| title      =  %3$s
| url        =  %4$s
| journal    =  %5$s
| volume     =  %6$s
| pages      =  %7$s
| doi        =  %8$s
| access-date =  %9$s
}}",
paste(sprintf("| last%1$s = %2$s | first%1$s = %3$s",1:length(rslt$data$author[[1]]$family),rslt$data$author[[1]]$family,ifelse(is.na(rslt$data$author[[1]]$given),"",rslt$data$author[[1]]$given)),collapse=""),
strsplit(rslt$data$published.online,"-")[[1]][1],
rslt$data$title,
rslt$data$url,
rslt$data$container.title,
rslt$data$volume,
rslt$data$page,
rslt$data$doi,
format(Sys.time(), "%Y-%m-%d")
))
