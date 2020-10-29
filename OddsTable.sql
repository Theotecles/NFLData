DROP TABLE NFLDATABASE1.dbo.Odds

CREATE TABLE NFLDATABASE1.dbo.Odds (
					Sort int,
					Game_Id varchar(255),
					Home_Team varchar(255),
					Away_Team varchar(255),
					Favorite varchar(255),
					Underdog varchar(255),
					Spread numeric,
					Total numeric,
					Season int,
					Game_Week int,
					Odds_Favorite numeric,
					Odds_Underdog numeric,
					Money_Line_Favorite numeric,
					Money_Line_Underdog numeric,
					Odds_Over numeric,
					Odds_Under numeric
);