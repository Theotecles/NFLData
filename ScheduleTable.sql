DROP TABLE NFLDATABASE1.dbo.Schedule

CREATE TABLE NFLDATABASE1.dbo.Schedule(
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
		Stadium varchar(255),
		Neutral varchar(255),
		Old_Game_Id int
);
