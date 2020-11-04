# IMPORT PACKAGES NEEDED

library(odbc)
library(tidyverse)
library(stringr)
library(lpSolve)
library(lpSolveAPI)

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

# PULL WEEK 8 NFL LINES
# CALCULATE EXPECTED POINTS AND PAYOFF PER DOLLAR

lines_df <- dbGetQuery(con,
                       "SELECT Favorite,
                        Underdog,
                        Spread,
                        Total,
                        Odds_Favorite,
                        Odds_Underdog,
                        (Total/2-Spread/2) AS Implied_Points_Favorite,
                        (Total/2+Spread/2) AS Implied_Points_Underdog,
                        ((100-Odds_Favorite)/-Odds_Favorite) AS Payout_Per_Dollar_Favorite,
                        ((100-Odds_Underdog)/-Odds_Underdog) AS Payout_Per_Dollar_Underdog,
                        CASE 
                        WHEN Favorite = Home_Team THEN 1
                        ELSE 0
                        END AS Home_Favorite
                        FROM NFLDATABASE1.dbo.Odds
                        WHERE Game_Week = 8")

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

ggplot(score_df, aes(Away_Score)) +
  geom_histogram(binwidth = 7) +
  facet_wrap(~Home_Team)

ggplot(score_df, aes(Home_Score)) +
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

mean_std <- inner_join(home_team_means_sd, away_team_means_sd,
                         by = c("Home_Team" = "Away_Team"))
# JOIN THE MEANS AND STANDARD DEVIATIONS ON THE LINES DF

favorite_means_std <- left_join(lines_df, mean_std,
                                by = c("Favorite" = "Home_Team"))

lines_means_std <- left_join(favorite_means_std, mean_std,
                             by = c("Underdog" = "Home_Team")) %>%
                                  select(-Total,
                                         -Odds_Favorite,
                                         -Odds_Underdog)

# RENAME COLUMNS

col_names <- c("Favorite",
               "Underdog",
               "Spread",
               "Implied_Points_Favorite",
               "Implied_Points_Underdog",
               "Payout_Per_Dollar_Favorite",
               "Payout_Per_Dollar_Underdog",
               "Home_Favorite",
               "Mean_Home_Points_Favorite",
               "Sd_Home_Points_Favorite",
               "Mean_Home_Points_Allowed_Favorite",
               "Sd_Home_Points_Allowed_Favorite",
               "Mean_Away_Points_Favorite",
               "Sd_Away_Points_Favorite",
               "Mean_Away_Points_Allowed_Favorite",
               "Sd_Away_Points_Allowed_Favorite",
               "Mean_Home_Points_Underdog",
               "Sd_Home_Points_Underdog",
               "Mean_Home_Points_Allowed_Underdog",
               "Sd_Home_Points_Allowed_Underdog",
               "Mean_Away_Points_Underdog",
               "Sd_Away_Points_Underdog",
               "Mean_Away_Points_Allowed_Underdog",
               "Sd_Away_Points_Allowed_Underdog")

names(lines_means_std) <- col_names

# CONVERT HOME_FAVORITE COLUMN TO A BOOLEAN COLUMN

lines_means_std$Home_Favorite <- as.logical(lines_means_std$Home_Favorite)

# CREATE Z SCORE FUNCTION

calc_zscore <- function(x, mean, std, ...){
                  output <- (x-mean)/std
}

# CALCULATE Z SCORES USING THE IMPLIED POINTS

zscores <- lines_means_std %>%
              mutate(
                
               Favorite_Z_Score = ifelse(Home_Favorite == TRUE,
                                  calc_zscore(Implied_Points_Favorite,
                                              Mean_Home_Points_Favorite,
                                              Sd_Home_Points_Favorite),
                                  calc_zscore(Implied_Points_Favorite,
                                              Mean_Away_Points_Favorite,
                                              Sd_Away_Points_Favorite)),
               
               Favorite_Z_Score_Allowed = ifelse(Home_Favorite == TRUE,
                                          calc_zscore(Implied_Points_Underdog,
                                                      Mean_Home_Points_Allowed_Favorite,
                                                      Sd_Home_Points_Allowed_Favorite),
                                          calc_zscore(Implied_Points_Underdog,
                                                      Mean_Away_Points_Allowed_Favorite,
                                                      Sd_Away_Points_Allowed_Favorite)),
               
               Underdog_Z_Score = ifelse(Home_Favorite == TRUE,
                                         calc_zscore(Implied_Points_Underdog,
                                                     Mean_Away_Points_Underdog,
                                                     Sd_Away_Points_Underdog),
                                         calc_zscore(Implied_Points_Underdog,
                                                     Mean_Home_Points_Underdog,
                                                     Sd_Home_Points_Underdog)),
               
               Underdog_Z_Score_Allowed = ifelse(Home_Favorite == TRUE,
                                                 calc_zscore(Implied_Points_Favorite,
                                                             Mean_Away_Points_Allowed_Underdog,
                                                             Sd_Away_Points_Allowed_Underdog),
                                                 calc_zscore(Implied_Points_Favorite,
                                                             Mean_Home_Points_Allowed_Underdog,
                                                             Sd_Home_Points_Allowed_Underdog))
              )

# CALCULATE PERCENT CHANCE THESE DIFFERENT IMPLIED POINTS WILL BE REALIZED USING
# THE ZSCORES AND THE DISTRIBUTIONS
# TAKE AVERAGE OF ALL FOUR PERCENTAGES AND CREATE EXPECTED PAYOUTS FOR EACH
# POSSIBLE BET BASED OFF OF THOSE PERCENTAGES AND THE PAYOUT PER DOLLAR


expected_payouts <- zscores %>%
                                mutate(Favorite_Implied_Percent = pnorm(-Favorite_Z_Score),
                                       Favorite_Allowed_Percent = pnorm(Favorite_Z_Score_Allowed),
                                       Underdog_Implied_Percent = pnorm(Underdog_Z_Score),
                                       Underdog_Allowed_Percent = pnorm(-Underdog_Z_Score_Allowed))%>%
  
                                mutate(Favorite_Expected_Cover = (Favorite_Implied_Percent +
                                                                 Favorite_Allowed_Percent +
                                                                 Underdog_Implied_Percent +
                                                                 Underdog_Allowed_Percent) / 4) %>% 

                                mutate(Underdog_Expected_Cover = 1-Favorite_Expected_Cover) %>%
  
                                mutate(Expected_Payout_Favorite = Favorite_Expected_Cover * 
                                                                  Payout_Per_Dollar_Favorite,
                                       Expected_Payout_Underdog = Underdog_Expected_Cover * 
                                                                  Payout_Per_Dollar_Underdog)

expected_payouts1 <- expected_payouts[ ,c(1:3, 35:36)]

# SETUP OPTIMIZATION MODEL
# CREATE COEFFICIENTS FOR DECISION VARIABLES

objective_in <- c(expected_payouts1$Expected_Payout_Favorite, expected_payouts1$Expected_Payout_Underdog)

# CREATE AND SOLVE LINEAR PROGRAMMING

lprec <- make.lp(0, length(objective_in))

lp.control(lprec, sense = "max")

set.objfn(lprec, objective_in)

budget = 100

add.constraint(lprec, rep(1, length(objective_in)), "<=", budget)

set.bounds(lprec, upper = rep(budget*.1, length(objective_in)), columns = (1:length(objective_in)))

lprec

solve(lprec)

get.objective(lprec)

bets_df <- as.data.frame(matrix(get.variables(lprec),
                                nrow = length(objective_in)/2,
                                byrow = FALSE))
names(bets_df) <- c("Favorite_Bet",
                    "Underdog_Bet")

# ADD OUTPUT TO DF AND EXPORT

final_output <- cbind(expected_payouts, bets_df)

final_output1 <- final_output[ ,c(1:3,6,7,37,38)]

write.csv(final_output1, "E:/NFLDataProject/Local/Bets and Results/RResults/Week8.csv")
