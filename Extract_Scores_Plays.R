library(nflfastR)
library(tidyverse)

seasons <- 2010:2020
schedule <- purrr::map_df(seasons, function(x) {
  readRDS(
    url(
      glue::glue("https://raw.githubusercontent.com/guga31bb/nflfastR-data/master/schedules/sched_{x}.rds")
    )
  )
})

scores <- schedule %>%
            select(-surface, - roof) %>%
              na.omit(schedule)

write.csv(scores,"E:/NFLDataProject/CSVFiles/scores.csv")

pbp <- purrr::map_df(seasons, function(x) {
  readRDS(
    url(
      glue::glue("https://raw.githubusercontent.com/guga31bb/nflfastR-data/master/data/play_by_play_{x}.rds")
    )
  )
})

write.csv(pbp, "E:/NFLDataProject/CSVFiles/RawData/plays.csv")