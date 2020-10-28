DROP TABLE NFLDATABASE1.dbo.Scores;

CREATE TABLE NFLDATABASE1.dbo.Scores (
			 Sort int,
			 Game_Id varchar(255),
			 Season int,
			 Game_Type varchar(255),
			 Game_Week int,
			 Game_Date date,
			 Week_Day varchar(255),
			 Start_Time time,
			 Away_Team varchar(255),
			 Home_Team varchar(255),
			 Away_Score int,
			 Home_Score int,
			 Home_Result int,
			 Stadium varchar(255),
			 Neutral varchar(255),
			 Old_Game_Id int);