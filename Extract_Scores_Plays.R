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
              na.omit()

write.csv(scores,"E:/NFLDataProject/Local/CSVFiles/scores.csv")

upcoming_games <- schedule %>%
                    select(-surface, - roof)
                      
upcoming_games1 <- upcoming_games[!complete.cases(upcoming_games), ] %>%
                    select(-home_score, -away_score, -home_result)

write.csv(upcoming_games1,"E:/NFLDataProject/Local/CSVFiles/RawData/schedule.csv")

pbp <- purrr::map_df(seasons, function(x) {
  readRDS(
    url(
      glue::glue("https://raw.githubusercontent.com/guga31bb/nflfastR-data/master/data/play_by_play_{x}.rds")
    )
  )
})

write.csv(pbp, "E:/NFLDataProject/Local/CSVFiles/RawData/plays.csv")
