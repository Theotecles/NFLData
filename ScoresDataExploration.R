# IMPORT PACKAGES NEEDED

library(odbc)
library(tidyverse)
library(stringr)

# CREATE SQL CONNECTION

con <- dbConnect(odbc(),
                 Driver = "SQL Server",
                 Server = "*****",
                 Database = "*****",
                 UID = "*****",
                 PWD = "*****",
                 Port = 1433)

# PULL ALL REGULAR SEASON DATA FROM 2012 - 2020

score_df <- dbGetQuery(con,
           "SELECT Home_Team,
	                 Away_Team,
	                 Home_Score,
	                 Away_Score
            FROM NFLDATABASE1.dbo.Scores
            WHERE Season >= 2012 AND
	                Game_Type = 'REG'")

# DISCONNECT FROM DATABASE

dbDisconnect(con)

# FIND AND REPLACE OLD TEAM NAMES WITH NEW NAMES

score_df$Home_Team <- str_replace(score_df$Home_Team, "OAK", "LV")
score_df$Home_Team <- str_replace(score_df$Home_Team, "SD", "LAC")
score_df$Home_Team <- str_replace(score_df$Home_Team, "STL", "LA")

score_df$Away_Team <- str_replace(score_df$Away_Team, "OAK", "LV")
score_df$Away_Team <- str_replace(score_df$Away_Team, "SD", "LAC")
score_df$Away_Team <- str_replace(score_df$Away_Team, "STL", "LA")

# CREATE BASIC HISTOGRAM FOR EACH TEAM HOME AND WAY SCORES

ggplot(score_df, aes(Home_Score)) +
  geom_histogram(binwidth = 7) +
  facet_wrap(~Home_Team)

ggplot(score_df, aes(Away_Score)) +
  geom_histogram(binwidth = 7) +
  facet_wrap(~Away_Team)

# IT APPEARS MOST TEAMS HAVE CLOSE TO A NORMAL DISTRIBUTION
# CALCULATE MEANS AND STANDARD DEVIATIONS FOR HOME AND AWAY SPLITS
# FOR BOTH POINTS SCORED AND POINTS ALLOWED FOR EACH TEAM

home_team_means_sd <- score_df %>%
                    group_by(Home_Team) %>%
                      summarize(Avg_Home_Points_Scored = mean(Home_Score),
                                Sd_Home_Points_Scored = sd(Home_Score),
                                Avg_Home_Points_Allowed = mean(Away_Score),
                                Sd_Home_Points_Allowed = sd(Away_Score))

away_team_means_sd <- score_df %>%
                    group_by(Away_Team) %>%
                      summarize(Avg_Away_Points_Scored = mean(Away_Score),
                                Sd_Away_Points_Scored = sd(Away_Score),
                                Avg_Away_Points_Allowed = mean(Home_Score),
                                Sd_Away_Points_Allowed = sd(Home_Score))

# JOIN THE TWO DFS TOGETHER

final_calc <- inner_join(home_team_means_sd, away_team_means_sd,
                         by = c("Home_Team" = "Away_Team"))

# EXPORT FINAL DATAFRAME TO CSV FILE

write.csv(final_calc, "E:/NFLDataProject/CSVFiles/SummaryCalculations/homeawayavgssd.csv")
